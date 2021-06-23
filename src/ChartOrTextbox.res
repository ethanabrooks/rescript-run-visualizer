open Belt
open SpecEditor

@module external copy: string => bool = "copy-to-clipboard"

module SetSpec = %graphql(`
  mutation set_spec($chartIds: [Int!], $spec: jsonb!) {
    update_chart(_set: {spec: $spec}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

module SetArchived = %graphql(`
  mutation set_archived($chartIds: [Int!], $spec: jsonb!) {
    update_chart(_set: {spec: $spec}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

type runOrSweepIds = Sweep(Set.Int.t) | Run(Set.Int.t)
let setToList = set => set->Set.Int.toArray->List.fromArray

@react.component
let make = (~data: array<Js.Json.t>, ~initialState: state, ~setSpecs, ~chartIds) => {
  let (state, setState) = React.useState(_ => initialState)
  let (mutate, mutated) = SetSpec.use()
  let mainWindow = switch state {
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
        chartIds
        ->Option.map(Set.Int.toArray)
        ->Option.map(a => a->Some)
        ->Option.mapWithDefault((), (chartIds: option<array<int>>) =>
          mutate({spec: spec, chartIds: chartIds})->ignore
        )
        spec->setSpecs->ignore
        setState(_ => Rendering(spec))
      }

      <SpecEditor initialSpec onSubmit setState />
    }
  }
  let mutationResult = switch mutated {
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({update_chart: Some({affected_rows})})} =>
    <p> {`Updated ${affected_rows->Int.toString} chart.`->React.string} </p>
  | {error: None} => <> </>
  }
  <> {mutationResult} {mainWindow} </>
}
