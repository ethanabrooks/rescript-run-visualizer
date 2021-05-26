open Belt

module Subscription = %graphql(`
subscription logs($runId: Int!) {
  run_log(where: {run: {id: {_eq: $runId}}}) {
    id
    log
    run_id
    run {
      metadata
      charts {
        spec
      }
    }
  }
}
`)

let useAccumulator = () => {
  let (state, setState) = React.useState(() => None->Result.Ok)
  let onError = error => setState(_ => error->Result.Error)
  let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) =>
    switch (value, state) {
    | ({error: Some(error)}, _) => error->onError
    | ({data: {run_log}}, Result.Ok(oldData)) =>
      setState(_ =>
        run_log
        ->Array.map(({id, log, run: {metadata, charts: spec}}): Data.t => {
          specs: spec->Array.map(({spec}) => spec)->Set.fromArray(~id=module(Data.JsonComparator)),
          metadata: metadata,
          logs: list{(id, log)},
        })
        ->Array.reduce(oldData, Data.merge)
        ->Result.Ok
      )
    | _ => ()
    }
  (state, onNext, onError)
}

@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (state, onNext, onError) = useAccumulator()
  client.subscribe(~subscription=module(Subscription), {runId: runId}).subscribe(
    ~onNext,
    ~onError,
    (),
  )->ignore
  <Display
    state={switch state {
    | Ok(Some({specs, logs, metadata})) => Data({specs: specs, logs: logs, metadata: metadata})
    | Ok(None) => Loading
    | Error({message}) => Error(message)
    }}
  />
}
