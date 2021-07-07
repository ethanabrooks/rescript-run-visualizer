open Routes
open Belt
open Util

@val external document: 'a = "document"

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

type queryResult = {loading: bool, error: option<string>, data: option<array<Sidebar.entry>>}
type filterPathLikeArgs = {path: option<string>, pattern: option<string>}

@react.component
let make = (~ids: Set.Int.t, ~granularity, ~archived, ~obj: option<Js.Json.t>, ~pattern, ~path) => {
  let (metadataDisplayKeywords, setMetadataDisplayKeywords) = React.useState(_ => "name")
  let (filterContainsObj, setFilterContainsObj) = React.useState(_ =>
    obj->Option.map(j => j->Js.Json.stringifyWithSpace(2))
  )
  let ({path, pattern}, setFilterPathLike) = React.useState(_ => {
    path: path->Option.map(path => `{${path->Js.Array2.joinWith(",")}}`),
    pattern: pattern,
  })

  let keywords =
    ","->Js.String.split(metadataDisplayKeywords)->Set.String.fromArray->Set.String.remove("")
  let newObj =
    filterContainsObj->Option.map(parseJson)->Option.map(resultToOption)->Option.getWithDefault(obj)
  let pathArray = path->Option.map(Js.String.split(","))
  let pathJson =
    pathArray
    ->Option.map(Js.Array.filter(t => t != ""))
    ->Option.map(Js.Array.joinWith(","))
    ->Option.map(path => `{${path}}`)
    ->Option.map(Js.Json.string)

  let route = Valid({
    granularity: granularity,
    ids: ids,
    archived: archived,
    obj: obj,
    pattern: pattern,
    path: pathArray,
  })
  let href = route->routeToHref

  let queryResult = {
    switch granularity {
    | Run =>
      let {loading, error, data} = RunSubscription.use({
        archived: archived,
        obj: newObj,
        pattern: pattern,
        path: pathJson,
      })

      {
        loading: loading,
        error: error->Option.map(({message}) => message),
        data: data->Option.map(({filter_runs}) =>
          filter_runs->Array.map(({id, metadata}): Sidebar.entry => {id: id, metadata: metadata})
        ),
      }
    | Sweep =>
      let {loading, error, data} = SweepSubscription.use({
        archived: archived,
        obj: newObj,
        pattern: pattern,
        path: pathJson,
      })

      {
        loading: loading,
        error: error->Option.map(({message}) => message),
        data: data->Option.map(({filter_sweeps}) =>
          filter_sweeps->Array.map(({id, metadata}): Sidebar.entry => {
            id: id,
            metadata: metadata,
          })
        ),
      }
    }
  }

  let textAreaClassName = "h-10 border p-4 shadow-sm block w-full sm:text-sm border-gray-300"

  <div className="pb-10 w-1/3 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    <div className="pb-5">
      <label className="text-sm font-sm text-gray-700">
        {"Filter metadata keywords"->React.string}
      </label>
      <input
        type_={"text"}
        onChange={evt => setMetadataDisplayKeywords(_ => ReactEvent.Form.target(evt)["value"])}
        className={`${textAreaClassName} rounded-md`}
        value={metadataDisplayKeywords}
      />
    </div>
    <div className="pb-5 -space-y-px">
      <label className="text-sm font-sm text-gray-700">
        <a href>
          {
            let metadataContainsString = `metadata @> ${obj
              ->Option.map(Js.Json.stringify)
              ->Option.getWithDefault("obj")}`
            let pathLikeString = `metadata#>>${path->Option.getWithDefault(
                "path",
              )} like ${pattern->Option.getWithDefault("pattern")}`
            let filterString = switch (obj, path, pattern) {
            | (Some(_), None, None) => metadataContainsString
            | (Some(_), _, _)
            | (None, None, None) =>
              `${metadataContainsString} and ${pathLikeString}`
            | (None, _, _) => pathLikeString
            }
            `Filter by ${filterString}`->React.string
          }
        </a>
      </label>
      <input
        type_={"text"}
        placeholder={filterContainsObj->Option.getWithDefault("obj")}
        onChange={evt => setFilterContainsObj(_ => ReactEvent.Form.target(evt)["value"])}
        className={`${textAreaClassName}
            rounded-t-md
        ${filterContainsObj
          ->Option.map(Util.parseJson)
          ->Option.mapWithDefault(false, Result.isError)
            ? " text-red-600 "
            : " focus:ring-indigo-500 "}`}
        value={filterContainsObj->Option.getWithDefault("")}
      />
      <div className="flex flex-row -space-x-px">
        <input
          type_={"text"}
          placeholder={path->Option.getWithDefault("path")}
          onChange={evt =>
            setFilterPathLike(x => {...x, path: ReactEvent.Form.target(evt)["value"]->Some})}
          className={`${textAreaClassName} rounded-bl-md`}
          value={path->Option.getWithDefault("")}
        />
        <input
          type_={"text"}
          placeholder={pattern->Option.getWithDefault("pattern")}
          onChange={evt =>
            setFilterPathLike(x => {...x, pattern: ReactEvent.Form.target(evt)["value"]->Some})}
          className={`${textAreaClassName} rounded-br-md`}
          value={pattern->Option.getWithDefault("")}
        />
      </div>
    </div>
    {switch queryResult {
    | {loading: true} => "Loading..."->React.string
    | {error: Some(message)} => `Error loading data: ${message}`->React.string
    | {data: None, error: None, loading: false} =>
      "You might think this is impossible, but depending on the situation it might not be!"->React.string
    | {data: Some(items)} => <Sidebar items ids keywords />
    }}
  </div>
}
