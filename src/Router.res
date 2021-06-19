open Belt

type path = Sweeps | Sweep(int) | Runs | Run(int) | NotFound

let urlToPath = (url: ReasonReactRouter.url) =>
  switch url.hash->Js.String2.split("/") {
  | ["sweeps"] => Sweeps
  | ["sweep", sweepIdString] =>
    switch sweepIdString->Int.fromString {
    | None => NotFound
    | Some(sweepId) => Sweep(sweepId)
    }
  | ["runs"] => Runs
  | ["run", runIdString] =>
    switch runIdString->Int.fromString {
    | None => NotFound
    | Some(runId) => Run(runId)
    }
  | _ => NotFound
  }

@react.component
let make = (~client) => {
  let path = ReasonReactRouter.useUrl()->urlToPath
  let activeClassName = "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-default"
  let inactiveClassName = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium cursor-pointer"

  <div className="min-h-screen bg-white">
    <nav className="bg-white border-b border-gray-200">
      <div className="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <div className="hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8">
              <a
                className={switch path {
                | Sweeps => activeClassName
                | _ => inactiveClassName
                }}
                href={"/#sweeps"}>
                {"Sweeps"->React.string}
              </a>
              <a
                className={switch path {
                | Runs => activeClassName
                | _ => inactiveClassName
                }}
                href={"/#runs"}>
                {"Runs"->React.string}
              </a>
            </div>
          </div>
        </div>
        {switch path {
        | Sweeps => <Sweeps client />
        | Sweep(sweepId) => <Sweep sweepIds={Set.Int.empty->Set.Int.add(sweepId)} client />
        | Runs => <Runs client />
        | Run(runId) => <Run runIds={Set.Int.empty->Set.Int.add(runId)} client />
        | NotFound => <p> {React.string("Not found")} </p>
        }}
      </div>
    </nav>
  </div>
}
