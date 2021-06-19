open Belt

type parseResult = Result.t<Js.Json.t, option<string>>

@react.component
let make = (~initialText, ~makeButtons: parseResult => array<React.element>) => {
  let parse = text =>
    try text->Js.Json.parseExn->Result.Ok catch {
    | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
    }
  let valid = text => text->parse->Result.isOk
  let (text, textbox) = TextBox.useText(~valid, ~initialText)

  let parseResult = text->parse
  let buttons = parseResult->makeButtons

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
