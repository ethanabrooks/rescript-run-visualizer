open Belt
open SpecEditor

@module external copy: string => bool = "copy-to-clipboard"

@react.component
let make = (
  ~data: array<Js.Json.t>,
  ~initialState: state,
  ~insertChartButton: (~spec: Js.Json.t) => React.element,
  ~onSubmit: Js.Json.t => unit,
) => {
  let (state, setState) = React.useState(_ => initialState)

  let insertChartButton = switch state {
  | Rendering(spec) => insertChartButton(~spec)
  | Editing(_) => insertChartButton(~spec=Js.Json.null) // dummy required by React
  }
  switch state {
  | Rendering(spec) =>
    let specString = spec->Js.Json.stringifyWithSpace(2)
    let first10datapoints = data->Js.Array2.slice(~start=0, ~end_=10)->Js.Json.array
    let jsonToMap = json =>
      json->Js.Json.decodeObject->Option.map(dict => dict->Js.Dict.entries->Map.String.fromArray)
    let mapToJson = map => map->Map.String.toArray->Js.Dict.fromArray->Js.Json.object_
    let specWithData: option<Js.Json.t> =
      spec
      ->jsonToMap
      ->Option.flatMap((specMap: Map.String.t<Js.Json.t>) =>
        specMap
        ->Map.String.get("data")
        ->Option.flatMap((dataJson: Js.Json.t) => {
          dataJson
          ->jsonToMap
          ->Option.map((dataMap: Map.String.t<Js.Json.t>) => {
            let dataObject = dataMap->Map.String.set("values", first10datapoints)->mapToJson
            specMap->Map.String.set("data", dataObject)->mapToJson
          })
        })
      )

    let buttons = list{
      insertChartButton,
      <Button text={"Edit chart"} onClick={_ => setState(_ => Editing(spec))} disabled={false} />,
      <Button text={"Copy spec"} onClick={_ => specString->copy->ignore} disabled={false} />,
    }

    let copyButton = specWithData->Option.map(s => {
      <Button
        text={"Copy spec with first 10 datapoints"}
        onClick={_ => s->Js.Json.stringifyWithSpace(2)->copy->ignore}
        disabled={false}
      />
    })

    let buttons =
      copyButton
      ->Option.mapWithDefault(buttons, button => list{buttons, list{button}}->List.flatten)
      ->List.toArray

    <> <Chart data spec /> <Buttons buttons /> </>

  | Editing(initialSpec) => {
      let onSubmit = spec => {
        spec->onSubmit->ignore
        setState(_ => Rendering(spec))
      }
      <SpecEditor initialSpec onSubmit setState />
    }
  }
}
