open Util

module Deletion = %graphql(`
mutation deletion($id: Int!) {
  delete_run_log(where: {run_id: {_eq: $id}}) {
    affected_rows
  }
  delete_chart(where: {run_id: {_eq: $id}}) {
    affected_rows
  }
  delete_run(where: {id: {_eq: $id}}) {
    affected_rows
  }
}
`)

@react.component
let make = (~runId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (delete, deleted) = Deletion.use()

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

  switch deleted {
  | {called: false} => <>
      <Subscribe1 variables1 variables2 client />
      <button type_="button" onClick={_ => delete({id: runId})->ignore} className="button">
        {"Delete"->React.string}
      </button>
    </>
  | {data: Some(_), error: None} => <p> {"Deleted"->React.string} </p>
  | {data: None, error: None, called: true} => <p> {"Deleting..."->React.string} </p>
  | {loading: true} => <p> {"Deleting..."->React.string} </p>
  | {error: Some({message})} => <ErrorPage message />
  }
}
