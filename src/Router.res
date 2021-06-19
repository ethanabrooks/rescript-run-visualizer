open Belt

type path = Sweeps(Set.Int.t) | Sweep(int) | Runs(Set.Int.t) | Run(int) | NotFound(string)

let processIds = (ids: list<string>) =>
  ids
  ->List.map(Int.fromString)
  ->List.reduce(list{}, (list, option) =>
    switch option {
    | None => list
    | Some(int) => list{int, ...list}
    }
  )
  ->List.toArray
  ->Set.Int.fromArray

let urlToPath = (url: ReasonReactRouter.url) =>
  switch url.hash->Util.splitHash->List.fromArray {
  | list{"sweeps", ...sweepIds} => Sweeps(sweepIds->processIds)
  | list{"runs", ...runIds} => Runs(runIds->processIds)
  | _ => NotFound(url.hash)
  }

@react.component
let make = (~client) => {
  let path = ReasonReactRouter.useUrl()->urlToPath
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-default"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-pointer"
  let singleton = Set.Int.empty->Set.Int.add

  <div className="min-h-screen bg-white">
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
        | Sweeps(ids) => <Sweeps ids client />
        | Runs(ids) => <Runs ids client />
        | Sweep(id) => <Sweep ids={id->singleton} client />
        | Run(id) => <Run ids={id->singleton} client />
        | NotFound(url) => <p> {React.string(`URL "${url}" not found`)} </p>
        }}
      </div>
    </nav>
  </div>
}
