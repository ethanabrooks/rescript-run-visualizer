open Belt

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
  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.Deletion_inner.t>,
  ) = Deletion.use()

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

  let deleted: DeleteButton.deleted = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({delete_run: Some({affected_rows: runsDeleted})}) =>
      `Deleted  ${runsDeleted->Int.toString} rows.`->Some
    | _ => None
    },
  }
  let onClick = _ => delete({id: runId})->ignore
  <> <Subscribe1 variables1 variables2 client /> <DeleteButton deleted onClick /> </>
}
