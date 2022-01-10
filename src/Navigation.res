open Routes
@react.component
let make = (~route) => {
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
  let sweeps = makeRoute(~granularity=Sweep, ())->routeToHref
  let runs = makeRoute(~granularity=Run, ())->routeToHref

  React.useEffect1(_ => {
    switch route {
    | Redirect => RescriptReactRouter.push(runs)
    | _ => ()
    }
    None
  }, [route])

  <nav className="flex justify-between h-16">
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
  </nav>
}
