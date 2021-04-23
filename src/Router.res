open Belt

@react.component
let make = () => {
  let url = ReasonReactRouter.useUrl()
  let notFound = <p> {React.string("Not found")} </p>

  switch url.hash->Js.String2.split("/") {
  | [sweepIdString] =>
    switch sweepIdString->Int.fromString {
    | None => notFound
    | Some(sweepId) => <GetChartData sweepId />
    }
  | _ => notFound
  }
}
