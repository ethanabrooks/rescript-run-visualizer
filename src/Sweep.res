open Belt
open Data

@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let _eq = sweepId
  let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
  let run = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
  let runLogBoolExp = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
  let variables: Subscription.t_variables = {condition: runLogBoolExp}

  let convertData = (data: Subscription.t): array<(int, Js.Json.t)> =>
    data.run_log->Array.map(({id, log}): (int, Js.Json.t) => (id, log))
  let (logs, onNext, onError) = Data.useAccumulator(~convertData)

  client.subscribe(~subscription=module(Subscription), variables).subscribe(
    ~onNext,
    ~onError,
    (),
  )->ignore

  let sweep_id = Query.makeInputObjectInt_comparison_exp(~_eq, ())
  let run = Query.makeInputObjectrun_bool_exp(~sweep_id, ())
  let runLogBoolExp = Query.makeInputObjectrun_log_bool_exp(~run, ())
  let variables: Query.t_variables = {condition: runLogBoolExp}

  switch Query.use(variables) {
  | {data: runs} => {
      let runs = runs->Option.map(({run}) =>
        run->Array.map(({charts, metadata}): Data.queryResult => {
          specs: charts->Array.map(({spec}) => spec),
          metadata: metadata,
        })
      )
      <Charts state={Data.getState(~logs, ~runs)} />
    }
  }
}
