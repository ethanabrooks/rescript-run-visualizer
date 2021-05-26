open Belt

module SweepQuery = %graphql(`
query logs($sweepId: Int!) {
  sweep(where: {id: {_eq: $sweepId}}) {
    metadata
    runs {
      id
      run_logs {
        id
        log
      }
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
    type subscriptionData = Data.subscriptionData
    type data = {specs: list<Js.Json.t>, metadata: option<Js.Json.t>, logs: subscriptionData}
    let initial = (): Data.state<data> => {
      let queryResult = SweepQuery.use({sweepId: sweepId})
      switch queryResult {
      | {loading: true} => Data.Loading
      | {error: Some(e)} => Error(e.message)
      | {data: None, error: None, loading: false} => Error("Log query is in a hung state.")
      | {data: Some({sweep})} => {
          let {metadata} = sweep->Array.getExn(0)
          let specs: list<Js.Json.t> =
            sweep
            ->List.fromArray
            ->List.map(({charts}) => charts->List.fromArray->List.map(({spec}) => spec))
            ->List.flatten

          let data: Result.t<list<Data.logEntry>, Decco.decodeError> =
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
                      dict->Js.Dict.set("runId", runId->Data.runId_encode)
                      dict->Js.Dict.set("logId", logId->Data.logId_encode)
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
          | Result.Ok(logs) => Data({specs: specs, logs: logs, metadata: metadata})
          }
        }
      }
    }

    let subscribe = (
      ~currentData: data,
      ~addData: subscriptionData => unit,
      ~setError: string => unit,
    ) => {
      currentData.logs
      ->List.head
      ->Option.map(((minLogId, _)) =>
        client.subscribe(
          ~subscription=module(LogSubscription),
          {sweepId: sweepId, minLogId: minLogId},
        ).subscribe(
          ~onNext=({data: {run_log}}) => {
            let data =
              run_log
              ->List.fromArray
              ->List.map(({id: logId, log, run_id: runId}) => log->Data.encodeLog(~runId, ~logId))
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
      )
    }
    let update = ({specs, metadata, logs: currentLogs}, newLogs) => {
      {specs: specs, metadata: metadata, logs: List.concat(newLogs, currentLogs)}
    }
  }
  module DisplayCharts = Data.Stream(DataSource)

  <> </>
  // <Display
  //   state={switch DisplayCharts.useData() {
  //   | Data({specs, logs, metadata}) => Data({specs: specs, logs: logs, metadata: metadata})
  //   | Loading => Loading
  //   | Error(e) => Error(e)
  //   }}
  // />
}
