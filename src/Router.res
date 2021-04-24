open Belt

type path = Loading | Sweeps | Sweep(int) | Runs | Run(int) | NotFound

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
  <>
    <div className="tabs">
      <ul>
        <li
          onClick={_ => ReasonReactRouter.replace("#sweeps")}
          className={switch path {
          | Sweeps => "is-active"
          | _ => ""
          }}>
          <a> {"Sweeps"->React.string} </a>
        </li>
        <li
          onClick={_ => ReasonReactRouter.replace("#runs")}
          className={switch path {
          | Runs => "is-active"
          | _ => ""
          }}>
          <a> {"Runs"->React.string} </a>
        </li>
      </ul>
    </div>
    {switch path {
    | Loading => <p> {"Loading"->React.string} </p>
    | Sweeps => <ListSweeps />
    | Sweep(sweepId) => <DisplaySweep sweepId client />
    | Runs => <ListRuns />
    | Run(runId) => <DisplayRun runId client />
    | NotFound => <p> {React.string("Not found")} </p>
    }}
  </>
}
