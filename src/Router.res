open Belt

type path =
  | Sweeps({ids: Set.Int.t, archived: bool})
  | Runs({ids: Set.Int.t, archived: bool})
  | Redirect
  | NotFound(string)

let processIds = (ids: string) =>
  ids
  ->Js.String2.split(",")
  ->List.fromArray
  ->List.map(Int.fromString)
  ->List.reduce(list{}, (list, option) =>
    switch option {
    | None => list
    | Some(int) => list{int, ...list}
    }
  )
  ->List.toArray
  ->Set.Int.fromArray

let urlToPath = (url: ReasonReactRouter.url) => {
  let hashParts = url.hash->Util.splitHash->List.fromArray

  let ids = switch hashParts {
  | list{_, "archived", ids}
  | list{_, ids} =>
    ids->processIds
  | _ => Set.Int.empty
  }

  let archived = switch hashParts {
  | list{_, "archived"} => true
  | _ => false
  }

  switch hashParts {
  | list{""} => Redirect
  | list{"runs", ..._} =>
    Runs({
      ids: ids,
      archived: archived,
    })
  | list{"sweeps", ..._} =>
    Sweeps({
      ids: ids,
      archived: archived,
    })
  | _ => NotFound(url.hash)
  }
}

@react.component
let make = (~client) => {
  let path = ReasonReactRouter.useUrl()->urlToPath
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-default"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-pointer"

  React.useEffect1(_ => {
    switch path {
    | Redirect => ReasonReactRouter.push("#runs")
    | _ => ()
    }
    None
  }, [path])

  <nav className="bg-white border-b border-gray-200">
    <div className="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="flex justify-between h-16">
        <div className="flex">
          <div className="hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8">
            <a
              className={switch path {
              | Sweeps(_) => activeClassName
              | _ => inactiveClassName
              }}
              href={"/#sweeps"}>
              {"Sweeps"->React.string}
            </a>
            <a
              className={switch path {
              | Runs(_) => activeClassName
              | _ => inactiveClassName
              }}
              href={"/#runs"}>
              {"Runs"->React.string}
            </a>
          </div>
        </div>
      </div>
      {switch path {
      | Sweeps({ids, archived}) => <Sweeps ids archived client />
      | Runs({ids, archived}) => <Runs ids archived client />
      | NotFound(url) => <p> {React.string(`URL "${url}" not found`)} </p>
      | Redirect => <p> {React.string("Redirecting...")} </p>
      }}
    </div>
  </nav>
}
