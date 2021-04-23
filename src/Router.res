open Belt

@react.component
let make = () => {
  let url = ReasonReactRouter.useUrl()

  switch url.hash->Js.String2.split("/") {
  | [sweepIdString] =>
    switch sweepIdString->Int.fromString {
    | None => <p> {React.string("Not found")} </p>
    | Some(sweepId) => <GetChartData sweepId />
    }
  | _ => <p> {React.string("Not found")} </p>
  }
}
