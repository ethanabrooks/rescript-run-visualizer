open QueryAndSubscribe
@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let _eq = sweepId
  let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
  let run = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
  let runLogBoolExp = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
  let subscriptionVariables: Subscription.t_variables = {condition: runLogBoolExp}

  let sweep_id = Query.makeInputObjectInt_comparison_exp(~_eq, ())
  let condition = Query.makeInputObjectrun_bool_exp(~sweep_id, ())
  let queryVariables: Query.t_variables = {condition: condition}

  <QueryAndSubscribe subscriptionVariables queryVariables client />
}
