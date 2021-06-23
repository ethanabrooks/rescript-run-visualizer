open Belt

module SweepSubscription = %graphql(`
  subscription {
      sweep(where: {archived: {_eq: false}}) {
          id
          metadata
      }
  }
`)

module ArchiveMutation = %graphql(`
  mutation archive($ids: [Int!], $bool: Boolean!) {
    update_sweep(_set: {archived: $bool}, where: {id: {_in: $ids}}) {
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
    archive,
    {called, error, data}: ApolloClient__React_Types.MutationResult.t<ArchiveMutation.t>,
  ) = ArchiveMutation.use()

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

  let archived: ArchiveButton.archived = {
    called: called,
    error: error,
    dataMessage: switch data {
    | Some({update_sweep: Some({affected_rows: sweepsDeleted})}) =>
      Some(sweepsDeleted == 0 ? "" : `Archived ${sweepsDeleted->Int.toString} sweeps.`)
    | _ => None
    },
  }
  let onClick = archived => archive({ids: ids->Set.Int.toArray->Some, bool: !archived})->ignore
  let condition = {
    open ArchiveButton
    let sweep_id = ArchiveQuery.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = ArchiveQuery.makeInputObjectrun_bool_exp(~sweep_id, ())
    condition
  }
  let display =
    <>
      <Subscribe1 condition1 condition2 runOrSweepIds client />
      <ArchiveButton archived onClick condition />
    </>

  <ListAndDisplay queryResult ids display />
}
