open Belt

module Subscription = %graphql(`
  subscription logs($condition: run_log_bool_exp!) {
    run_log(where: $condition) {
      id
      log
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

type condition = {condition: Subscription.t_variables_run_log_bool_exp}

@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (state, onNext, onError) = Data.useAccumulator(~convertToData)
  let runLogBoolExp: Subscription.t_variables_run_log_bool_exp = {
    _and: None,
    _not: None,
    _or: None,
    id: None,
    log: None,
    run_id: None,
    run: Some({
      _not: None,
      _or: None,
      _and: None,
      sweep_id: None,
      charts: None,
      images: None,
      metadata: None,
      run_logs: None,
      sweep: None,
      id: Some({
        _eq: Some(runId),
        _gt: None,
        _gte: None,
        _in: None,
        _is_null: None,
        _lt: None,
        _lte: None,
        _neq: None,
        _nin: None,
      }),
    }),
  }
  let variables: Subscription.t_variables = {condition: runLogBoolExp}

  client.subscribe(~subscription=module(Subscription), variables).subscribe(
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
