open Routes
open Belt

type queryResult = {loading: bool, error: option<string>, data: option<array<MenuList.entry>>}

module RunSubscription = %graphql(`
  subscription search_runs(
    $path: _text = null,
    $pattern: String = "%",
    $obj: jsonb = null,
    $archived: Boolean! 
  ) {
    filter_runs(args: {object: $obj, path: $path, pattern: $pattern}, 
    where: {_and: [{archived: {_eq: $archived}}, {sweep_id: {_is_null: true}}]}) {
      id
      metadata
    }
  }
`)

module SweepSubscription = %graphql(`
  subscription search_sweeps(
    $path: _text = null,
    $pattern: String = "%",
    $obj: jsonb = null,
    $archived: Boolean! 
  ) {
    filter_sweeps(args: {object: $obj, path: $path, pattern: $pattern}, 
    where: {archived: {_eq: $archived}}) {
      id
      metadata
    }
  }
`)

@react.component
let make = (~client, ~granularity, ~ids, ~archived, ~obj, ~pattern, ~path) => {
  let subscriptionState = Subscribe1.useSubscription(~client, ~granularity, ~ids)

  let path =
    path
    // ->Option.map(path => `{${path->Js.Array2.joinWith(",")}}`)
    ->Option.map(Js.Array.joinWith(","))
    ->Option.map(path => `"${path}"`)
    ->Option.map(Js.Json.string)
  // "{name}"->Js.Json.string->Some
  // ->Option.map(path => `{${path->Js.Array2.joinWith(",")}}`)

  let queryResult = switch granularity {
  | Run =>
    let {loading, error, data} = RunSubscription.use({
      archived: archived,
      obj: obj, // Js.Json.parseExn("{\"config\": {\"seed\": [0]}}")->Some,
      pattern: pattern, //"%breakout%"->Some,
      path: path,
    })

    {
      loading: loading,
      error: error->Option.map(({message}) => message),
      data: data->Option.map(({filter_runs}) =>
        filter_runs->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
      ),
    }
  | Sweep =>
    let {loading, error, data} = SweepSubscription.use({
      archived: archived,
      obj: obj, // Js.Json.parseExn("{\"config\": {\"seed\": [0]}}")->Some,
      pattern: pattern, //"%breakout%"->Some,
      path: path,
    })

    {
      loading: loading,
      error: error->Option.map(({message}) => message),
      data: data->Option.map(({filter_sweeps}) =>
        filter_sweeps->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
      ),
    }
  }
  let defaultListFilters = "name"

  switch queryResult {
  | {loading: true} => "Loading..."->React.string
  | {error: Some(message)} => `Error loading data: ${message}`->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some(items)} =>
    <div className={"flex flex-row"}>
      <MenuList items ids defaultListFilters />
      <div className={"flex flex-grow flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
        {switch subscriptionState {
        | Waiting => <p> {"Waiting for data..."->React.string} </p>
        | NoData => <p> {"No data."->React.string} </p>
        | Error({message}) => <ErrorPage message />
        | Data({logs, specs, metadata, runIds}) =>
          <Charts logs specs metadata runIds client granularity />
        }}
        <ArchiveButton granularity ids />
      </div>
    </div>
  }
}
