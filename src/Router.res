open Belt

type path = Sweeps | Sweep(int) | NotFound

let urlToPath = (url: ReasonReactRouter.url) =>
  switch url.hash {
  | "" => Sweeps
  | sweepIdString =>
    switch sweepIdString->Int.fromString {
    | None => NotFound
    | Some(sweepId) => Sweep(sweepId)
    }
  }

@react.component
let make = () => {
  let (path, setPath) = React.useState(() => ReasonReactRouter.useUrl()->urlToPath)
  let _ = ReasonReactRouter.watchUrl(url => setPath(_ => url->urlToPath))

  switch path {
  | Sweeps => <GetSweeps />
  | Sweep(sweepId) => <GetChartData sweepId />
  | NotFound => <p> {React.string("Not found")} </p>
  }
}
