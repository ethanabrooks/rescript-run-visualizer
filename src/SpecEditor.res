open Belt

type parseResult = Result.t<Js.Json.t, option<string>>

type button = {
  text: string,
  callback: parseResult => unit,
  disabled: parseResult => bool,
}
@react.component
let make = (~initialText, ~buttons) => {
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
        {buttons
        ->Array.map(({text, callback, disabled}) =>
          <button
            type_="submit"
            onClick={_ => parsed->callback}
            className={"button"}
            disabled={parsed->disabled}>
            {text->React.string}
          </button>
        )
        ->React.array}
      </div>
    </div>
  </div>
}
