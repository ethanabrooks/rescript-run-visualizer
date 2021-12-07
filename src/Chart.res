open Belt

let dictToMap = dict => dict->Js.Dict.entries->Map.String.fromArray
let mapToDict = map => map->Map.String.toArray->Js.Dict.fromArray
let mapToObject = map => map->mapToDict->Js.Json.object_

@module("./Chart.jsx")
external make: (~spec: Js.Json.t, ~newData: array<Js.Json.t>) => React.element = "make"
@react.component
let make = (~logs, ~spec, ~newData: array<Js.Json.t>) => {
  // Add logs to spec
  spec
  ->Js.Json.decodeObject
  ->Option.flatMap(specObject => {
    let specMap = specObject->dictToMap
    specMap
    ->Map.String.get("data")
    ->Option.flatMap(data =>
      data
      ->Js.Json.decodeObject
      ->Option.flatMap(dataObject => {
        dataObject
        ->dictToMap
        ->Map.String.set("values", logs->Map.Int.valuesToArray->Js.Json.array)
        ->mapToObject
        ->Some
      })
    )
    ->Option.map(data => specMap->Map.String.set("data", data)->mapToObject)
  })
  ->Option.mapWithDefault(
    <ErrorPage message={`Invalid spec: ${spec->Js.Json.stringifyWithSpace(2)}`} />,
    spec => make(~spec, ~newData),
  )
}
