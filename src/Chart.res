open Belt
@module("./Chart.jsx")
external innerMake: (~data: array<Js.Json.t>, ~spec: Js.Json.t) => React.element = "make"
@react.component
let make = (~data, ~spec) => {
  innerMake(~data=data->List.toArray, ~spec)
}
