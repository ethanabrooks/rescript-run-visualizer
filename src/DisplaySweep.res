open Belt

@decco
type runId = int

@decco
type logId = int

type logEntry = (int, Js.Json.t)

module SweepQuery = %graphql(`
query logs($sweepId: Int!) {
  sweep(where: {id: {_eq: $sweepId}}) {
    runs {
      id
      run_logs {
        id
        log
      }
      metadata
    }
    charts {
      spec
    }
  }
}
`)

module LogSubscription = %graphql(`
subscription logs($sweepId: Int!, $minLogId: Int!) {
  run_log(where: {run: {sweep_id: {_eq: $sweepId}}, id: {_gt: $minLogId}}, limit: 1) {
    id
    log
    run_id
  }
}
`)

@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  module DataSource = {
    type subscriptionData = list<logEntry>
    type data = {specs: list<Js.Json.t>, logs: subscriptionData}
    let initial = (): Data.state<data> => {
      let queryResult = SweepQuery.use({sweepId: sweepId})
      switch queryResult {
      | {loading: true} => Data.Loading
      | {error: Some(e)} => Error(e.message)
      | {data: None, error: None, loading: false} => Error("Log query is in a hung state.")
      | {data: Some({sweep})} => {
          let specs: list<Js.Json.t> =
            sweep
            ->List.fromArray
            ->List.map(({charts}) => charts->List.fromArray->List.map(({spec}) => spec))
            ->List.flatten

          let data: Result.t<list<logEntry>, Decco.decodeError> =
            sweep
            ->List.fromArray
            ->List.map(({runs}) =>
              runs
              ->List.fromArray
              ->List.map(({id: runId, run_logs}) =>
                run_logs
                ->List.fromArray
                ->List.map(({id: logId, log}) => {
                  switch log->Js.Json.decodeObject {
                  | None => Decco.error("Unable to decode as object", log)
                  | Some(dict) => {
                      dict->Js.Dict.set("runId", runId->runId_encode)
                      dict->Js.Dict.set("logId", logId->logId_encode)
                      (logId, dict->Js.Json.object_)->Result.Ok
                    }
                  }
                })
              )
            )
            ->List.flatten
            ->List.flatten
            ->List.reduce(Result.Ok(list{}), (list, result) => {
              list->Result.flatMap(list => result->Result.map(list->List.add))
            })
            ->Result.map(list => list->List.sort(((logId1, _), (logId2, _)) => logId2 - logId1))
          switch data {
          | Result.Error(e) => Error(e.message)
          | Result.Ok(logs) => Data({specs: specs, logs: logs})
          }
        }
      }
    }

    let encodeLog = (log: Js.Json.t, ~runId: int, ~logId: int) =>
      switch log->Js.Json.decodeObject {
      | None => Decco.error("Unable to decode as object", log)
      | Some(dict) => {
          dict->Js.Dict.set("runId", runId->runId_encode)
          dict->Js.Dict.set("logId", logId->logId_encode)
          (logId, dict->Js.Json.object_)->Result.Ok
        }
      }

    let subscribe = (
      ~currentData: data,
      ~addData: subscriptionData => unit,
      ~setError: string => unit,
    ) => {
      let (minLogId, _) = currentData.logs->List.headExn
      client.subscribe(
        ~subscription=module(LogSubscription),
        {sweepId: sweepId, minLogId: minLogId},
      ).subscribe(
        ~onNext=({data: {run_log}}) => {
          let data =
            run_log
            ->List.fromArray
            ->List.map(({id: logId, log, run_id: runId}) => log->encodeLog(~runId, ~logId))
            ->List.reduce(Result.Ok(list{}), (list, result) =>
              list->Result.flatMap(list =>
                result->Result.map((r: (int, Js.Json.t)) => list->List.add(r))
              )
            )
          switch data {
          | Result.Error(e) => setError(e.message)
          | Result.Ok(list) => list->List.sort(((id1, _), (id2, _)) => id1 - id2)->addData
          }
        },
        ~onError=error => setError(error.message),
        (),
      )
    }
    let update = ({specs, logs: currentLogs}, newLogs) => {
      {specs: specs, logs: List.concat(newLogs, currentLogs)}
    }
  }
  module DisplayCharts = Data.Stream(DataSource)

  switch DisplayCharts.useData() {
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Data({specs, logs}) => <>
      {specs
      ->List.mapWithIndex((i, spec) =>
        <Chart key={i->Int.toString} data={logs->List.map(((_, log)) => log)} spec />
      )
      ->List.toArray
      ->React.array}
    </>
  }
}
