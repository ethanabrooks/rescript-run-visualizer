open Belt
module RunSubscription = %graphql(`
  subscription {
      run(where: {archived: {_eq: false}}) {
          id
          metadata
      }
  }
`)

module Deletion = %graphql(`
  mutation deletion($ids: [Int!], $bool: Boolean!) {
    update_run(_set: {archived: $bool}, where: {id: {_in: $ids}}) {
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
    archive,
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

  let runOrSweepIds = InsertChartButton.Run(ids)

  let archived: ArchiveButton.archived = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({update_run: Some({affected_rows: runsDeleted})}) =>
      Some(runsDeleted == 0 ? "" : `Archived  ${runsDeleted->Int.toString} rows.`)
    | _ => None
    },
  }
  let onClick = archived => archive({ids: ids->Set.Int.toArray->Some, bool: !archived})->ignore
  let condition = {
    open ArchiveButton
    let id = ArchiveQuery.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = ArchiveQuery.makeInputObjectrun_bool_exp(~id, ())
    condition
  }
  let display =
    <>
      <Subscribe1 condition1 condition2 runOrSweepIds client />
      <ArchiveButton archived onClick condition />
    </>
  <ListAndDisplay queryResult ids display />
}
