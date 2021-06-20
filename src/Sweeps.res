open Belt
open SubmitSpecButton

module SweepSubscription = %graphql(`
  subscription {
      sweep {
          id
          metadata
      }
  }
`)

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
let make = (~client, ~ids) => {
  let {loading, error, data} = SweepSubscription.use()
  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({sweep}) =>
      sweep->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}

  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.t>,
  ) = Deletion.use()

  let _in = ids->Set.Int.toArray

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
  let runOrSweepIds = Sweep(ids)

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
  let onClick = _ => delete({ids: ids->Set.Int.toArray->Some})->ignore
  let display =
    <>
      <Subscribe1 variables1 variables2 runOrSweepIds client /> <DeleteButton deleted onClick />
    </>

  <ListAndDisplay queryResult ids display />
}
