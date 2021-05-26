open Belt

module Subscription = %graphql(`
subscription logs($sweepId: Int!) {
  run_log(where: {sweep: {id: {_eq: $sweepId}}}) {
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

let convertToData = (data: Subscription.t): array<Data.t> =>
  data.run_log->Array.map(({id, log, run: {metadata, charts: spec}}): Data.t => {
    specs: spec->Array.map(({spec}) => spec)->Set.fromArray(~id=module(Data.JsonComparator)),
    metadata: metadata,
    logs: list{(id, log)},
  })

@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (state, onNext, onError) = Data.useAccumulator(~convertToData)
  client.subscribe(~subscription=module(Subscription), {sweepId: sweepId}).subscribe(
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
