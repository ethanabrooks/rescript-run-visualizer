open Belt
type action =
  | RevertToOriginalSpec({spec: Js.Json.t, callback: unit => unit})
  | AddSpecToCharts(Js.Json.t => unit)

@react.component
let make = (~action, ~visualize: Js.Json.t => unit) => {
  let initialText = switch action {
  | RevertToOriginalSpec({spec}) => spec->Js.Json.stringifyWithSpace(2)
  | _ => ""
  }

  let parse = text =>
    try text->Js.Json.parseExn->Result.Ok catch {
    | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
    }
  let valid = text => text->parse->Result.isOk
  let (text, textbox) = TextEditor.useText(~valid, ~initialText)
  let parsed = text->parse

  <div className="sm:gap-4 sm:items-start">
    <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
    {textbox}
    <div className="pt-5">
      <div className="flex justify-end">
        {switch parsed {
        | Result.Error(Some(e)) =>
          <p className="flex-1 mt-2 text-sm text-red-600" id="json-error"> {e->React.string} </p>
        | _ => <> </>
        }}
        {switch action {
        | RevertToOriginalSpec({callback}) =>
          <button type_="submit" onClick={_ => callback()} className={"button"}>
            {"Cancel"->React.string}
          </button>
        | AddSpecToCharts(callback) =>
          <button
            type_="submit"
            onClick={_ => parsed->Result.mapWithDefault((), callback)}
            className={"button"}>
            {"Add spec to charts"->React.string}
          </button>
        }}
        <button
          type_="submit"
          disabled={parsed->Result.isError}
          onClick={_ => parsed->Result.mapWithDefault((), visualize)}
          className={"button"}>
          {"Submit"->React.string}
        </button>
      </div>
    </div>
  </div>
}
