module RunSubscription = %graphql(`
  subscription search_runs(
    $path: _text = null,
    $pattern: String = "%",
    $obj: jsonb = null,
    $archived: Boolean! 
  ) {
    filter_runs(args: {object: $obj, path: $path, pattern: $pattern}, 
    where: {archived: {_eq: $archived}}) {
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

module ArchiveSubscription = %graphql(`
  subscription queryArchived($condition: run_bool_exp!) {
    run(where: $condition) {
      archived
    }
  }
`)

@react.component
let make = (~client, ~ids, ~archived, ~obj, ~pattern, ~path) => {
  open Belt
  let idsSet = ids
  let ids = ids->Set.Int.toArray

  let condition1 = {
    open Subscribe1
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let condition = Subscription.makeInputObjectrun_bool_exp(~id, ())
    condition
  }

  let condition2 = {
    open Subscribe2
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    condition
  }

  let archiveButton = {
    let id = ArchiveSubscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let condition = ArchiveSubscription.makeInputObjectrun_bool_exp(~id, ())
    let {error, loading, data} = ArchiveSubscription.use({condition: condition})
    let queryResult: ArchiveButton.queryResult = {
      error: error->Option.map(({message}) => message),
      loading: loading,
      data: data->Option.map(({run}) => run->Array.map(({archived}) => archived)),
    }
    let (
      archive,
      {called, error, data}: ApolloClient__React_Types.MutationResult.t<SetArchived.t>,
    ) = SetArchived.use()

    let onClick = archived => archive({ids: ids->Some, archived: !archived})

    let archiveResult: ArchiveButton.archiveResult = {
      called: called,
      error: error,
      dataMessage: switch data {
      | Some({update_run: Some({affected_rows: runsArchived})}) =>
        Some(`Archived  ${runsArchived->Int.toString} runs.`)
      | _ => None
      },
    }

    <ArchiveButton queryResult archiveResult onClick />
  }
  let display = <> <Subscribe1 condition1 condition2 client /> {archiveButton} </>

  let {loading, error, data} = RunSubscription.use({
    archived: archived,
    obj: obj, // Js.Json.parseExn("{\"config\": {\"seed\": [0]}}")->Some,
    pattern: pattern, //"%breakout%"->Some,
    path: path
    // ->Option.map(path => `{${path->Js.Array2.joinWith(",")}}`)
    ->Option.map(Js.Array.joinWith(","))
    ->Option.map(path => `"${path}"`)
    ->Option.map(Js.Json.string),
    // "{name}"->Js.Json.string->Some,
  })

  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({filter_runs}) =>
      filter_runs->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}
  let ids = idsSet
  let defaultListFilters = "name,parameters"
  <ListAndDisplay queryResult ids display defaultListFilters />
}
