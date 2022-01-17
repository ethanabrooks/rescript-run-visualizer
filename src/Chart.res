open Belt

type data = array<(int, Js.Json.t)>
let dictToMap = dict => dict->Js.Dict.entries->Map.String.fromArray
let mapToDict = map => map->Map.String.toArray->Js.Dict.fromArray
let mapToObject = map => map->mapToDict->Js.Json.object_

@module("./Chart.jsx")
external make: (
  ~spec: Js.Json.t,
  ~newData: array<(int, Js.Json.t)>,
  ~setPlotted: int => unit,
) => React.element = "make"
@react.component
let make = (~logs, ~spec, ~newLogs: Map.Int.t<Js.Json.t>) => {
  let (plotted, setPlotted) = React.useState(_ => logs->Map.Int.keysToArray->Set.Int.fromArray) // ids of logs added to Vega chart
  let newData = newLogs->Map.Int.keep((id, _) => !(plotted->Set.Int.has(id)))->Map.Int.toArray // logs in newLogs not already plotted
  let setPlotted = (id: int) => setPlotted(plotted => plotted->Set.Int.add(id)) // called when corresponding log is plotted

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
    spec => make(~spec, ~newData, ~setPlotted),
  )
}
