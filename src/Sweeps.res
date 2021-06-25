open Belt

module SweepSubscription = %graphql(`
  subscription($archived: Boolean!) {
      sweep(where: {archived: {_eq: $archived}}) {
          id
          metadata
      }
  }
`)

module SetArchived = %graphql(`
  mutation set_archived($ids: [Int!], $archived: Boolean!) {
    update_sweep(_set: {archived: $archived}, where: {id: {_in: $ids}}) {
      affected_rows
    }
    update_run(_set: {archived: $archived}, where: {sweep: {id: {_in: $ids}}}) {
      affected_rows
    }
  }
`)

module ArchiveQuery = %graphql(`
  query queryArchived($condition: sweep_bool_exp!) {
    sweep(where: $condition) {
      archived
    }
  }
`)

@react.component
let make = (~client, ~ids, ~archived) => {
  let {loading, error, data} = SweepSubscription.use({archived: archived})
  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({sweep}) =>
      sweep->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}

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

  let archiveButton = {
    let id = ArchiveQuery.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = ArchiveQuery.makeInputObjectsweep_bool_exp(~id, ())
    let {error, loading, data} = ArchiveQuery.use({condition: condition})
    let queryResult: ArchiveButton.queryResult = {
      error: error->Option.map(({message}) => message),
      loading: loading,
      data: data->Option.map(({sweep}) => sweep->Array.map(({archived}) => archived)),
    }
    let (
      archive,
      {called, error, data}: ApolloClient__React_Types.MutationResult.t<SetArchived.t>,
    ) = SetArchived.use()

    let onClick = archived => archive({ids: ids->Set.Int.toArray->Some, archived: !archived})

    let archiveResult: ArchiveButton.archiveResult = {
      called: called,
      error: error,
      dataMessage: switch data {
      | Some({
          update_run: Some({affected_rows: runsArchived}),
          update_sweep: Some({affected_rows: sweepsArchived}),
        }) =>
        Some(
          `Archived ${sweepsArchived->Int.toString} sweeps and ${runsArchived->Int.toString} runs.`,
        )
      | _ => None
      },
    }

    <ArchiveButton queryResult archiveResult onClick />
  }

  let display = <> <Subscribe1 condition1 condition2 client /> {archiveButton} </>

  <ListAndDisplay queryResult ids display />
}
