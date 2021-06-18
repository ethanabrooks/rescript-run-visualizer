open Util

module Deletion = %graphql(`
mutation deletion($id: Int!) {
  delete_chart(where: {sweep_id: {_eq: $id}}) {
    affected_rows
  }
  delete_parameter_choices(where: {sweep_id: {_eq: $id}}) {
    affected_rows
  }
  delete_run_log(where: {run: {sweep_id: {_eq: $id}}}) {
    affected_rows
  }
  delete_run(where: {sweep_id: {_eq: $id}}) {
    affected_rows
  }
  delete_sweep(where: {id: {_eq: $id}}) {
    affected_rows
  }
}
`)

@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (delete, deleted) = Deletion.use()

  let _eq = sweepId

  let variables1 = {
    open Subscribe1
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  let variables2 = {
    open Subscribe2
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_eq, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  switch deleted {
  | {called: false} => <>
      <Subscribe1 variables1 variables2 client />
      <button type_="button" onClick={_ => delete({id: sweepId})->ignore} className="button">
        {"Delete"->React.string}
      </button>
    </>
  | {data: Some(_), error: None} => <p> {"Deleted"->React.string} </p>
  | {data: None, error: None, called: true} => <p> {"Deleting..."->React.string} </p>
  | {loading: true} => <p> {"Deleting..."->React.string} </p>
  | {error: Some({message})} => <ErrorPage message />
  }
}
