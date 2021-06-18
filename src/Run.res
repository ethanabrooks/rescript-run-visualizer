open Belt

module Deletion = %graphql(`
mutation deletion($ids: [Int!]) {
  delete_run_log(where: {run_id: {_in: $ids}}) {
    affected_rows
  }
  delete_chart(where: {run_id: {_in: $ids}}) {
    affected_rows
  }
  delete_run(where: {id: {_in: $ids}}) {
    affected_rows
  }
}
`)

@react.component
let make = (~runIds: Set.Int.t, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.Deletion_inner.t>,
  ) = Deletion.use()

  let _in = runIds->Set.Int.toArray

  let variables1 = {
    open Subscribe1
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  let variables2 = {
    open Subscribe2
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
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
  let ids = runIds->Set.Int.toArray->Some
  let onClick = _ => delete({ids: ids})->ignore
  <> <Subscribe1 variables1 variables2 client /> <DeleteButton deleted onClick /> </>
}
