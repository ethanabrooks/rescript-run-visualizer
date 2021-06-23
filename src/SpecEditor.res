open Belt

type ajvArgs = {
  allowUnionTypes: bool,
  strictTypes: bool,
  strictTuples: bool,
}
type ajv
type ajvRef
@module("ajv-formats") external addFormats: ajv => unit = "addFormats"
@module("ajv/lib/refs/json-schema-draft-06.json") external draft6Schema: ajvRef = "draft6Schema"
@new @module external newAjv: ajvArgs => ajv = "Ajv"
@send external addFormat: (ajv, string, unit => bool) => unit = "addFormat"
@send external addMetaSchema: (ajv, ajvRef) => unit = "addMetaSchema"
@send external addKeyword: (ajv, string) => unit = "addKeyword"
@send external compile: (ajv, Js.Json.t, Js.Json.t) => bool = "compile"

type state =
  | Rendering(Js.Json.t)
  | Editing(Js.Json.t)

@react.component
let make = (~initialSpec, ~onSubmit, ~onCancel) => {
  let (schema, setSchema) = React.useState(_ => None)

  // https://github.com/vega/vega-lite/blob/b61b13c2cbd4ecde0448544aff6cdaea721fd22a/examples/examples.test.ts
  let ajv = newAjv({allowUnionTypes: true, strictTypes: false, strictTuples: false})
  ajv->addFormat("color-hex", () => true)
  // addFormats(ajv)
  // ajv->addMetaSchema(draft6Schema)
  ajv->addKeyword("defs")
  ajv->addKeyword("refs")

  React.useEffect1(() => {
    initialSpec
    ->Js.Json.decodeObject
    ->Option.flatMap(object => object->Js.Dict.get("$schema")->Option.flatMap(Js.Json.decodeString))
    ->Option.mapWithDefault((), url =>
      (Fetch.fetch(url)
      |> Js.Promise.then_(Fetch.Response.json)
      |> Js.Promise.then_(value => setSchema(_ => Some(value)) |> Js.Promise.resolve))->ignore
    )
    None
  }, [initialSpec])

  let initialText = initialSpec->Js.Json.stringifyWithSpace(2)
  let parse = text =>
    try text->Js.Json.parseExn->Result.Ok catch {
    | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
    }
  let valid = text => {
    switch (text->parse, schema) {
    | (Result.Error(_), _) => false
    | (Result.Ok(parsed), Some(schema)) => {
        let validate = ajv->compile(schema)
        Js.log(validate(parsed))
        true
      }

    | _ => true
    }
  }
  let (text, textbox) = TextBox.useText(~valid, ~initialText)

  let parseResult = text->parse
  let submitButton = switch parseResult {
  | Result.Error(_) => <Button text={"Submit"} onClick={_ => ()} disabled={true} />
  | Result.Ok(spec) => <Button text={"Submit"} onClick={_ => spec->onSubmit} disabled={false} />
  }
  let cancelButton =
    <Button text={"Cancel"} onClick={onCancel} disabled={parseResult->Result.isError} />
  let buttons = [submitButton, cancelButton]

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
