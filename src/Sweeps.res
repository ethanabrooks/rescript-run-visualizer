open Belt

module SweepSubscription = %graphql(`
  subscription {
      sweep {
          id
          metadata
      }
  }
`)

module Deletion = %graphql(`
  mutation archive($ids: [Int!]) {
    update_run_log(_set: {archived: true}, where: {run_id: {_in: $ids}}) {
      affected_rows
    }
    update_run(_set: {archived: true}, where: {id: {_in: $ids}}) {
      affected_rows
    }
    update_chart(_set: {archived: true}, where: {run_id: {_in: $ids}}) {
      affected_rows
    }
    update_parameter_choices(_set: {archived: true}, where: {sweep_id: {_in: $ids}}) {
      affected_rows
    }
    update_sweep(_set: {archived: true}, where: {id: {_in: $ids}}) {
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

  let condition1 = {
    open Subscribe1
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
    condition
  }

  let condition2 = {
    open Subscribe2
    let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    condition
  }
  let runOrSweepIds = InsertChartButton.Sweep(ids)

  let deleted: DeleteButton.deleted = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({
        update_run: Some({affected_rows: runsDeleted}),
        update_sweep: Some({affected_rows: sweepsDeleted}),
      }) =>
      `Deleted ${sweepsDeleted->Int.toString} sweeps and ${runsDeleted->Int.toString} rows.`->Some
    | _ => None
    },
  }
  let onClick = _ => delete({ids: ids->Set.Int.toArray->Some})->ignore
  let display =
    <>
      <Subscribe1 condition1 condition2 runOrSweepIds client /> <DeleteButton deleted onClick />
    </>

  <ListAndDisplay queryResult ids display />
}
