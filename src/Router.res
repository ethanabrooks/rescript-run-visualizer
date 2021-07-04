open Routes
@react.component
let make = (~client) => {
  let route = ReasonReactRouter.useUrl()->urlToRoute
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-default"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-pointer"

  React.useEffect1(_ => {
    switch route {
    | Redirect => ReasonReactRouter.push("#runs")
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
              | Sweeps(_) => activeClassName
              | _ => inactiveClassName
              }}
              href={"/#sweeps"}>
              {"Sweeps"->React.string}
            </a>
            <a
              className={switch route {
              | Runs(_) => activeClassName
              | _ => inactiveClassName
              }}
              href={"/#runs"}>
              {"Runs"->React.string}
            </a>
          </div>
        </div>
      </div>
      {switch route {
      | Sweeps({ids, archived}) => <Sweeps ids archived client />
      | Runs({ids, archived}) => <Runs ids archived client />
      | NotFound(url) => <p> {React.string(`URL "${url}" not found`)} </p>
      | Redirect => <p> {React.string("Redirecting...")} </p>
      }}
    </div>
  </nav>
}
