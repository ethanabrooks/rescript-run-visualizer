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
let make = (~ids: Set.Int.t, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.Deletion_inner.t>,
  ) = Deletion.use()

  let _in = ids->Set.Int.toArray

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
  let ids = ids->Set.Int.toArray->Some
  let onClick = _ => delete({ids: ids})->ignore
  <div className={"flex flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
    <Subscribe1 variables1 variables2 client /> <DeleteButton deleted onClick />
  </div>
}
