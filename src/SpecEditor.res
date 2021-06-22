open Belt

type state =
  | Rendering(Js.Json.t)
  | Editing

let _make = (
  ~initialText,
  ~chartIds,
  ~insertChartButton: (~parseResult: Util.parseResult) => React.element,
  ~onCancel,
  ~setSpecs,
) => {
  let parse = text =>
    try text->Js.Json.parseExn->Result.Ok catch {
    | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
    }
  let valid = text => text->parse->Result.isOk
  let (text, textbox) = TextBox.useText(~valid, ~initialText)

  let parseResult = text->parse
  let onClick = _ =>
    parseResult->Result.mapWithDefault((), parsed =>
      setSpecs(specs =>
        chartIds->Set.Int.reduce(specs, (specs, chartId) => specs->Map.Int.set(chartId, parsed))
      )
    )
  let buttons =
    [
      insertChartButton(~parseResult),
      <Button text={"Submit"} onClick disabled={parseResult->Result.isError} />,
    ]->Array.concat(
      onCancel->Option.mapWithDefault([], onCancel => [
        <Button text={"Cancel"} onClick={onCancel} disabled={parseResult->Result.isError} />,
      ]),
    )

  <div className="sm:gap-4 sm:items-start">
    <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
    {textbox}
    <div className="pt-5">
      {switch parseResult {
      | Result.Error(Some(e)) =>
        <p className="flex-1 mt-2 text-sm text-red-600" id="json-error"> {e->React.string} </p>
      | _ => <> </>
      }}
      <Buttons buttons />
    </div>
  </div>
}

@react.component
let make = (~initialText, ~chartIds, ~insertChartButton, ~onCancel, ~setSpecs) =>
  _make(~initialText, ~chartIds, ~insertChartButton, ~onCancel, ~setSpecs)
