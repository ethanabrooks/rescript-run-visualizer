open Routes
open Belt

type filterArgs = {
  obj: option<string>,
  path: option<string>,
  pattern: option<string>,
}

let makeFilterArgs = (~obj, ~path, ~pattern) => {
  obj: obj->Option.map(j => j->Js.Json.stringifyWithSpace(2)),
  path: path->Option.map(path => path->Js.Array2.joinWith(",")),
  pattern: pattern,
}

@react.component
let make = (
  ~ids: Set.Int.t,
  ~granularity,
  ~archived,
  ~obj: option<Js.Json.t>,
  ~pattern,
  ~path: option<array<string>>,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let initialObj = obj
  let initialPath = path
  let initialPattern = pattern

  let ({obj: objString, path: pathString, pattern}, setFilterArgs) = React.useState(_ =>
    makeFilterArgs(~obj, ~path, ~pattern)
  )

  React.useEffect3(() => {
    setFilterArgs(_ => makeFilterArgs(~obj=initialObj, ~path=initialPath, ~pattern=initialPattern))
    None
  }, (initialObj, initialPath, initialPattern))

  let objJson = objString->Option.map(Util.parseJson)
  let pathArray = pathString->Option.map(Js.String.split(","))

  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~obj,
    ~pattern,
    ~path=pathArray,
    ~client,
  )

  let route = Valid({
    granularity: granularity,
    ids: ids,
    archived: archived,
    obj: obj,
    pattern: pattern,
    path: pathArray,
  })
  let href = route->routeToHref
  let textAreaClassName = "h-10 border p-4 shadow-sm block w-full sm:text-sm border-gray-300"

  <div className="pb-10 resize-x w-1/3 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    <div className="pb-5 -space-y-px">
      <label className="text-sm font-sm text-gray-700">
        <a href>
          {
            let metadataContainsString = `metadata @> ${obj
              ->Option.map(Js.Json.stringify)
              ->Option.getWithDefault("obj")}`
            let pathLikeString = `metadata#>>'{${pathString->Option.getWithDefault(
                "path",
              )}}' like '${pattern->Option.getWithDefault("pattern")}'`
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
        placeholder={objString->Option.getWithDefault("obj")}
        onChange={evt =>
          setFilterArgs(args => {...args, obj: ReactEvent.Form.target(evt)["value"]})}
        className={`${textAreaClassName}
            rounded-t-md
        ${objJson->Option.mapWithDefault(false, Result.isError)
            ? " text-red-600 "
            : " focus:ring-indigo-500 "}`}
        value={objString->Option.getWithDefault("")}
      />
      <div className="flex flex-row -space-x-px">
        <input
          type_={"text"}
          placeholder={pathString->Option.getWithDefault("path")}
          onChange={evt =>
            setFilterArgs(args => {...args, path: ReactEvent.Form.target(evt)["value"]->Some})}
          className={`${textAreaClassName} rounded-bl-md`}
          value={pathString->Option.getWithDefault("")}
        />
        <input
          type_={"text"}
          placeholder={pattern->Option.getWithDefault("pattern")}
          onChange={evt =>
            setFilterArgs(args => {...args, pattern: ReactEvent.Form.target(evt)["value"]->Some})}
          className={`${textAreaClassName} rounded-br-md`}
          value={pattern->Option.getWithDefault("")}
        />
      </div>
    </div>
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | Error(message) => <ErrorPage message />
      | Ok(items) => <Sidebar items ids />
      }
    )}
  </div>
}
