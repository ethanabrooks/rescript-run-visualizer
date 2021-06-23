open Belt
open SpecEditor

@module external copy: string => bool = "copy-to-clipboard"

module InsertChart = %graphql(`
  mutation insert_chart($objects: [chart_insert_input!]!) {
    insert_chart(objects: $objects, on_conflict: {update_columns: [id], constraint: chart_pkey}) {
      affected_rows
    }
  }
`)

type runOrSweepIds = Sweep(Set.Int.t) | Run(Set.Int.t)
let setToList = set => set->Set.Int.toArray->List.fromArray

let insertChartObjects = (
  ~spec: Js.Json.t,
  ~chartIds: Set.Int.t,
  ~runOrSweepIds: runOrSweepIds,
): array<InsertChart.t_variables_chart_insert_input> =>
  switch runOrSweepIds {
  | Sweep(sweepOrRunIds)
  | Run(sweepOrRunIds) =>
    sweepOrRunIds
    ->setToList
    ->List.map((sweepOrRunId): list<InsertChart.t_variables_chart_insert_input> => {
      let chartIds = chartIds->setToList
      let chartIds: list<option<int>> =
        chartIds->Js.List.isEmpty ? list{None} : chartIds->List.map(x => x->Some)
      chartIds->List.map((chartId): InsertChart.t_variables_chart_insert_input => {
        id: chartId,
        archive: false->Some,
        run: None,
        sweep: None,
        spec: spec->Some,
        run_id: switch runOrSweepIds {
        | Run(_) => sweepOrRunId->Some
        | _ => None
        },
        sweep_id: switch runOrSweepIds {
        | Sweep(_) => sweepOrRunId->Some
        | _ => None
        },
      })
    })
  }
  ->List.flatten
  ->List.toArray

@react.component
let make = (
  ~data: array<Js.Json.t>,
  ~initialState: state,
  ~setSpecs,
  ~insertChartObjects: (~spec: Js.Json.t) => array<InsertChart.t_variables_chart_insert_input>,
) => {
  let (state, setState) = React.useState(_ => initialState)
  let (mutate, mutated) = InsertChart.use()
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
        mutate({objects: insertChartObjects(~spec)})->ignore
        spec->setSpecs->ignore
        setState(_ => Rendering(spec))
      }

      <SpecEditor initialSpec onSubmit setState />
    }
  }
  let mutationResult = switch mutated {
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({insert_chart: Some(_)})} => <p> {"Inserted chart."->React.string} </p>
  | {error: None} => <> </>
  }
  <> {mutationResult} {mainWindow} </>
}
