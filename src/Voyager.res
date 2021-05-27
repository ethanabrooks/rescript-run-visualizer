@module("./Voyager.jsx")
external innerMake: (~data: array<Js.Json.t>) => React.element = "make"

@react.component
let make = (~data) => innerMake(~data)
