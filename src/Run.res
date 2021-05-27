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

@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (state, onNext, onError) = Data.useAccumulator(~convertToData)
  let runLogBoolExp: Subscription.t_variables_run_log_bool_exp = Subscription.makeInputObjectrun_log_bool_exp(
    ~run=Subscription.makeInputObjectrun_bool_exp(
      ~id=Subscription.makeInputObjectInt_comparison_exp(~_eq=runId, ()),
      (),
    ),
    (),
  )
  let variables: Subscription.t_variables = {condition: runLogBoolExp}

  client.subscribe(~subscription=module(Subscription), variables).subscribe(
    ~onNext,
    ~onError,
    (),
  )->ignore
  <Charts
    state={switch state {
    | Ok(Some({specs, logs, metadata})) => Data({specs: specs, logs: logs, metadata: metadata})
    | Ok(None) => Loading
    | Error({message}) => Error(message)
    }}
  />
}
