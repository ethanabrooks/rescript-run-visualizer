open Belt
module Deletion = %graphql(`
mutation deletion($ids: [Int!]) {
  delete_run_log(where: {run_id: {_in: $ids}}) {
    affected_rows
  }
  delete_run(where: {id: {_in: $ids}}) {
    affected_rows
  }
  delete_chart(where: {run_id: {_in: $ids}}) {
    affected_rows
  }
  delete_parameter_choices(where: {sweep_id: {_in: $ids}}) {
    affected_rows
  }
  delete_sweep(where: {id: {_in: $ids}}) {
    affected_rows
  }
}
`)

@react.component
let make = (~sweepIds: Set.Int.t, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.Deletion_inner.t>,
  ) = Deletion.use()

  let _in = sweepIds->Set.Int.toArray

  let variables1 = {
    open Subscribe1
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
    let variables: Subscription.t_variables = {condition: condition}
    variables
  }

  let variables2 = {
    open Subscribe2
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
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
  let onClick = _ => delete({ids: sweepIds->Set.Int.toArray->Some})->ignore
  <> <Subscribe1 variables1 variables2 client /> <DeleteButton deleted onClick /> </>
}
