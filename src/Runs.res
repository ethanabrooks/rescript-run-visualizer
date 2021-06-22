open Belt
module RunSubscription = %graphql(`
  subscription {
      run {
          id
          metadata
      }
  }
`)

module Deletion = %graphql(`
  mutation deletion($ids: [Int!]) {
    update_run_log(_set: {archived: true}, where: {run_id: {_in: $ids}}) {
      affected_rows
    }
    update_chart(_set: {archived: true}, where: {run_id: {_in: $ids}}) {
      affected_rows
    }
    update_run(_set: {archived: true}, where: {id: {_in: $ids}}) {
      affected_rows
    }
  }
`)

@react.component
let make = (~client, ~ids) => {
  let {loading, error, data} = RunSubscription.use()
  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({run}) =>
      run->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}

  let (
    delete,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<Deletion.t>,
  ) = Deletion.use()

  let _in = ids->Set.Int.toArray

  let condition1 = {
    open Subscribe1
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~id, ())
    condition
  }

  let condition2 = {
    open Subscribe2
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    condition
  }

  let deleted: DeleteButton.deleted = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({update_chart: Some({affected_rows: runsDeleted})}) =>
      `Deleted  ${runsDeleted->Int.toString} rows.`->Some
    | _ => None
    },
  }
  let runOrSweepIds = InsertChartButton.Run(ids)
  let onClick = _ => delete({ids: ids->Set.Int.toArray->Some})->ignore
  let display =
    <>
      <Subscribe1 condition1 condition2 runOrSweepIds client /> <DeleteButton deleted onClick />
    </>
  <ListAndDisplay queryResult ids display />
}
