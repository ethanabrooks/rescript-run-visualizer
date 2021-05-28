@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let _eq = runId

  let variables1 = {
    open Subscribe1
    let id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  let variables2 = {
    open Subscribe2
    let id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  <Subscribe1 variables1 variables2 client />
}
