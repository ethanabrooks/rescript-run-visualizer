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
let make = (~sweepId: int) => {
  module DataSource = {
    type data = {specs: list<Js.Json.t>, logs: list<logEntry>}
    type subscriptionData = {logs: list<logEntry>}
    let initial = () => {
      switch SweepQuery.use({sweepId: sweepId}) {
      | {loading: true} => Data.Loading
      | {error: Some(e)} => Error(e.message)
      | {data: None, error: None, loading: false} => Hanging
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

    let subscription = ({logs}: data): Data.state<subscriptionData> => {
      let (minLogId, _) = logs->List.headExn
      switch LogSubscription.use({sweepId: sweepId, minLogId: minLogId}) {
      | {loading: true} => Loading
      | {error: Some(e)} => Error(e.message)
      | {data: None, error: None, loading: false} => Hanging
      | {data: Some({run_log})} =>
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
        | Result.Error(e) => Error(e.message)
        | Result.Ok(list) => {
            let logs = list->List.sort(((id1, _), (id2, _)) => id1 - id2)
            Data({logs: logs})
          }
        }
      }
    }
    let update = ({specs, logs: currentLogs}, {logs: newLogs}) => {
      {specs: specs, logs: List.concat(newLogs, currentLogs)}
    }
  }
  module DisplayCharts = Data.Stream(DataSource)

  switch DisplayCharts.useData() {
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Hanging => <p> {"Hanging..."->React.string} </p>
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
