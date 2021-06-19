open SpecEditor
open Belt

@module external copy: string => bool = "copy-to-clipboard"

type submit = Js.Json.t => unit

type specState =
  | Spec({spec: Js.Json.t, submit: submit})
  | NoSpec({submit: submit})

type state =
  | Rendering(Js.Json.t)
  | Editing

@react.component
let make = (~data: array<Js.Json.t>, ~specState) => {
  let (state, setState) = React.useState(_ =>
    switch specState {
    | Spec({spec}) => Rendering(spec)
    | NoSpec(_) => Editing
    }
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
      let (initialText, makeButtons) = switch specState {
      | Spec({spec, submit}) => {
          let initialText = spec->Js.Json.stringifyWithSpace(2)
          let makeButtons = (parseResult: parseResult) => [
            <Button
              text={"Submit"}
              onClick={_ =>
                parseResult->Result.mapWithDefault((), spec => {
                  spec->submit
                  setState(_ => Rendering(spec))
                })}
              disabled={parseResult->Result.isError}
            />,
            <Button
              text={"Cancel"}
              onClick={_ => setState(_ => Rendering(spec))}
              disabled={parseResult->Result.isError}
            />,
          ]

          (initialText, makeButtons)
        }
      | NoSpec({submit}) => {
          let initialText = "{}"
          let makeButtons = (parseResult: parseResult) => [
            <Button
              text={"Submit"}
              onClick={result =>
                parseResult->Result.mapWithDefault((), spec => {
                  setState(_ => Rendering(spec))
                  spec->submit
                })}
              disabled={parseResult->Result.isError}
            />,
          ]

          (initialText, makeButtons)
        }
      }
      <SpecEditor initialText makeButtons />
    }
  }
}
