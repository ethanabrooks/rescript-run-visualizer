open Belt
open SpecEditor

@module external copy: string => bool = "copy-to-clipboard"

type submit = Js.Json.t => unit

@react.component
let make = (~data: array<Js.Json.t>, ~initialSpec: option<Js.Json.t>, ~makeSpecEditor) => {
  let (state, setState) = React.useState(_ =>
    initialSpec->Option.mapWithDefault(Editing, x => Rendering(x))
  )

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
    let buttons = [
      <Button text={"Edit chart"} onClick={_ => setState(_ => Editing)} disabled={false} />,
      <Button text={"Copy spec"} onClick={_ => specString->copy->ignore} disabled={false} />,
    ]
    let buttons =
      specWithData
      ->Option.map(s => {
        <Button
          text={"Copy spec with first 10 datapoints"}
          onClick={_ => s->Js.Json.stringifyWithSpace(2)->copy->ignore}
          disabled={false}
        />
      })
      ->Option.map(b => [b])
      ->Option.mapWithDefault(buttons, buttons->Js.Array2.concat)
    <> <Chart data spec /> <Buttons buttons /> </>

  | Editing => {
      let initialText =
        initialSpec->Option.mapWithDefault("{}", spec => spec->Js.Json.stringifyWithSpace(2))
      let onCancel = initialSpec->Option.map((spec, _) => setState(_ => Rendering(spec)))
      {makeSpecEditor(~initialText, ~onCancel)}
    }
  }
}
