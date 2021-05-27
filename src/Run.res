open QueryAndSubscribe

@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let _eq = runId
  let id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
  let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
  let runLogBoolExp = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
  let subscriptionVariables: Subscription.t_variables = {condition: runLogBoolExp}

  let id = Query.makeInputObjectInt_comparison_exp(~_eq, ())
  let run = Query.makeInputObjectrun_bool_exp(~id, ())
  let runLogBoolExp = Query.makeInputObjectrun_log_bool_exp(~run, ())
  let queryVariables: Query.t_variables = {condition: runLogBoolExp}

  <QueryAndSubscribe subscriptionVariables queryVariables client />
}
