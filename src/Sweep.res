open Belt
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
  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.Deletion_inner.t>,
  ) = Deletion.use()

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

  let deleted: DeleteButton.deleted = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({
        delete_run: Some({affected_rows: runsDeleted}),
        delete_sweep: Some({affected_rows: sweepsDeleted}),
      }) =>
      `Deleted ${sweepsDeleted->Int.toString} sweeps and ${runsDeleted->Int.toString} rows.`->Some
    | _ => None
    },
  }
  let onClick = _ => delete({id: sweepId})->ignore
  <> <Subscribe1 variables1 variables2 client /> <DeleteButton deleted onClick /> </>
}
