open Routes
@react.component
let make = (~client) => {
  let route = ReasonReactRouter.useUrl().hash->hashToRoute
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-default"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-pointer"
  let sweeps = makeRoute(~granularity=Sweep, ())->routeToHref
  let runs = makeRoute(~granularity=Run, ())->routeToHref

  React.useEffect1(_ => {
    switch route {
    | Redirect => ReasonReactRouter.push(runs)
    | _ => ()
    }
    None
  }, [route])

  <nav className="bg-white border-b border-gray-200">
    <div className="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="flex justify-between h-16">
        <div className="flex">
          <div className="hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8">
            <a
              className={switch route {
              | Valid({granularity: Sweep}) => activeClassName
              | _ => inactiveClassName
              }}
              href={sweeps}>
              {"Sweeps"->React.string}
            </a>
            <a
              className={switch route {
              | Valid({granularity: Run}) => activeClassName
              | _ => inactiveClassName
              }}
              href={runs}>
              {"Runs"->React.string}
            </a>
          </div>
        </div>
      </div>
      {switch route {
      | Valid({granularity, ids, archived, obj, pattern, path}) =>
        // let obj = Js.Json.parseExn("{\"config\": {\"seed\": [0]}}")->Some
        // let pattern = "%breakout%"->Some
        // let path = ["name"]->Some
        <div className={"flex flex-row"}>
          <SidebarWrapper ids granularity archived obj pattern path />
          <div
            className={"flex flex-grow flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
            <div
              className={"flex flex-grow flex-col max-h-screen overflow-y-scroll overscroll-contain"}>
              <ChartsSubscriptionWrapper client granularity ids /> <ArchiveButton granularity ids />
            </div>
          </div>
        </div>
      | NotFound(url) => <p> {React.string(`URL "${url}" not found`)} </p>
      | Redirect => <p> {React.string("Redirecting...")} </p>
      }}
    </div>
  </nav>
}
