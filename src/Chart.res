open Belt

@module("./Chart.jsx")
external make: (~data: array<Js.Json.t>, ~spec: Js.Json.t) => React.element = "make"
@react.component
let make = (~logs, ~spec) => make(~data=logs->Map.Int.valuesToArray, ~spec)
