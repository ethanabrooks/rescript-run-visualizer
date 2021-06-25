module RunSubscription = %graphql(`
  subscription($archived: Boolean!) {
      run(where: {archived: {_eq: $archived}}) {
          id
          metadata
      }
  }
`)

module SetArchived = %graphql(`
  mutation set_archived($ids: [Int!], $archived: Boolean!) {
    update_run(_set: {archived: $archived}, where: {id: {_in: $ids}}) {
      affected_rows
    }
  }
`)

module ArchiveQuery = %graphql(`
  query queryArchived($condition: run_bool_exp!) {
    run(where: $condition) {
      archived
    }
  }
`)

@react.component
let make = (~client, ~ids, ~archived) => {
  open Belt
  let {loading, error, data} = RunSubscription.use({archived: archived})
  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({run}) =>
      run->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}

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

  let archiveButton = {
    let id = ArchiveQuery.makeInputObjectInt_comparison_exp(~_in, ())
    let condition = ArchiveQuery.makeInputObjectrun_bool_exp(~id, ())
    let {error, loading, data} = ArchiveQuery.use({condition: condition})
    let queryResult: ArchiveButton.queryResult = {
      error: error->Option.map(({message}) => message),
      loading: loading,
      data: data->Option.map(({run}) => run->Array.map(({archived}) => archived)),
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
      | Some({update_run: Some({affected_rows: runsArchived})}) =>
        Some(`Archived  ${runsArchived->Int.toString} runs.`)
      | _ => None
      },
    }

    open Util
    let makePath = archived => Runs({ids: ids, archived: !archived})
    <ArchiveButton queryResult archiveResult onClick makePath />
  }
  let display = <> <Subscribe1 condition1 condition2 client /> {archiveButton} </>

  <ListAndDisplay queryResult ids display />
}
