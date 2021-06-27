open Belt
open SpecEditor
open Util

@module external copy: string => bool = "copy-to-clipboard"

module SetSpec = %graphql(`
  mutation set_spec($chartIds: [Int!], $spec: jsonb!) {
    update_chart(_set: {spec: $spec}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

module SetArchived = %graphql(`
  mutation set_archived($chartIds: [Int!]) {
    update_chart(_set: {archived: true}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

type runOrSweepIds = Sweep(Set.Int.t) | Run(Set.Int.t)
let setToList = set => set->Set.Int.toArray->List.fromArray

module CopyButton = {
  @react.component
  let make = (~text, ~copyString, ~className) => {
    let (copied, setCopied) = React.useState(_ => false)
    <button
      className
      onClick={_ => {
        setCopied(_ => true)
        Js.Global.setTimeout(_ => setCopied(_ => false), 1000)->ignore
        copyString->copy->ignore
      }}
      disabled={false}>
      {(copied ? "Copied" : text)->React.string}
    </button>
  }
}

@react.component
let make = (~logs: jsonMap, ~newLogs: jsonMap, ~initialState: state, ~setSpecs, ~chartIds) => {
  let (state, setState) = React.useState(_ => initialState)
  let (numCopyDataPoints, setNumCopyDataPoints) = React.useState(_ => 30)
  let (setSpec, setSpecResult) = SetSpec.use()
  let (archiveChart, archiveChartResult) = SetArchived.use()
  let mainWindow = switch state {
  | Rendering(spec) =>
    let specString = spec->Js.Json.stringifyWithSpace(2)
    let (firstNDatapoints, _) =
      Array.range(0, numCopyDataPoints)->Array.reduce((list{}, 0), ((datapoints, minKey), _) =>
        logs
        ->Map.Int.findFirstBy((k, _) => minKey <= k)
        ->Option.mapWithDefault((datapoints, minKey), ((k, v)) => (list{v, ...datapoints}, k + 1))
      )
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
            let dataObject =
              dataMap
              ->Map.String.set("values", firstNDatapoints->List.toArray->Js.Json.array)
              ->mapToJson
            specMap->Map.String.set("data", dataObject)->mapToJson
          })
        })
      )

    let chartIds: option<array<int>> = chartIds->Option.map(Set.Int.toArray)

    let archiveChartButton = switch archiveChartResult {
    | {error: Some({message})} => <ErrorPage message />
    | {data: Some({update_chart: Some({affected_rows})})} =>
      <p> {`Updated ${affected_rows->Int.toString} chart.`->React.string} </p>
    | {error: None} =>
      <Button
        text={"Archive"} onClick={_ => archiveChart({chartIds: chartIds})->ignore} disabled={false}
      />
    }
    let buttons = list{
      <Button text={"Edit chart"} onClick={_ => setState(_ => Editing(spec))} disabled={false} />,
      archiveChartButton,
      <CopyButton text={"Copy spec"} copyString=specString className={Button.className} />,
    }

    let copyButtons =
      specWithData->Option.mapWithDefault(list{}, s => list{
        <div className="w-80 m-1 z-0 inline-flex shadow-sm -space-x-px" ariaLabel="Pagination">
          <button
            className="-space-x-px px-3 py-2 rounded-l-md border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
            onClick={_ => setNumCopyDataPoints(n => n - 5)}
            disabled={numCopyDataPoints == 0}>
            <svg
              className="h-5 w-5"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              ariaHidden=true>
              <path
                fillRule="evenodd"
                d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                clipRule="evenodd"
              />
            </svg>
          </button>
          <CopyButton
            text={`Copy with first ${numCopyDataPoints->Int.toString} datapoints`}
            copyString={s->Js.Json.stringifyWithSpace(2)}
            className="flex-grow px-3 py-2 border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
          />
          <div
            className="px-3 py-2 rounded-r-md border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
            onClick={_ => setNumCopyDataPoints(n => n + 5)}>
            <svg
              className="h-5 w-5"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              ariaHidden=true>
              <path
                fillRule="evenodd"
                d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                clipRule="evenodd"
              />
            </svg>
          </div>
        </div>,
      })

    let buttons = list{buttons, copyButtons}->List.flatten->List.toArray
    <> <Chart logs newLogs spec /> <Buttons buttons /> </>

  | Editing(initialSpec) => {
      let onSubmit = spec => {
        chartIds
        ->Option.map(Set.Int.toArray)
        ->Option.map(a => a->Some)
        ->Option.mapWithDefault((), (chartIds: option<array<int>>) =>
          setSpec({spec: spec, chartIds: chartIds})->ignore
        )
        spec->setSpecs->ignore
        setState(_ => Rendering(spec))
      }

      let onCancel = _ => setState(_ => Rendering(initialSpec))
      <SpecEditor initialSpec onSubmit onCancel />
    }
  }
  let setSpecResult = switch setSpecResult {
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({update_chart: Some({affected_rows})})} =>
    <p> {`Updated ${affected_rows->Int.toString} chart.`->React.string} </p>
  | {error: None} => <> </>
  }
  <> {setSpecResult} {mainWindow} </>
}
