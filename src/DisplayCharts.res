open Belt
module LogQuery = %graphql(`
query getSweepData($sweepId: Int!) {
  sweep(where: {id: {_eq: $sweepId}}, limit: 10) {
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

@decco
type runId = int

@decco
type logId = int

@react.component
let make = (~sweepId: int) => {
  switch LogQuery.use({sweepId: sweepId}) {
  | {loading: true} => "Loading..."->React.string
  | {error: Some(_error)} => "Error loading data"->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some({sweep})} => {
      let specs: list<Js.Json.t> =
        sweep
        ->List.fromArray
        ->List.map(({charts}) => charts->List.fromArray->List.map(({spec}) => spec))
        ->List.flatten

      let data: Result.t<list<Js.Json.t>, Decco.decodeError> =
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
        ->Result.map(list =>
          list
          ->List.sort(((logId1, _), (logId2, _)) => logId1 - logId2)
          ->List.map(((_, log)) => log)
        )
      switch data {
      | Result.Error(e) => <> <p> {e.message->React.string} </p> </>
      | Result.Ok(data) => <>
          {specs
          ->List.mapWithIndex((i, spec) => <Chart key={i->Int.toString} data spec />)
          ->List.toArray
          ->React.array}
        </>
      }
    }
  }
}
