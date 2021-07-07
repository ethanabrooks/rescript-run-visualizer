open Belt

// type ajvArgs = {
//   allowUnionTypes: bool,
//   strictTypes: bool,
//   strictTuples: bool,
// }
// type ajv
// type ajvRef
// @module("ajv-formats") external addFormats: ajv => unit = "addFormats"
// @module("ajv/lib/refs/json-schema-draft-06.json") external draft6Schema: ajvRef = "draft6Schema"
// @new @module external newAjv: ajvArgs => ajv = "Ajv"
// @send external addFormat: (ajv, string, unit => bool) => unit = "addFormat"
// @send external addMetaSchema: (ajv, ajvRef) => unit = "addMetaSchema"
// @send external addKeyword: (ajv, string) => unit = "addKeyword"
// @send external compile: (ajv, Js.Json.t, Js.Json.t) => bool = "compile"

@react.component
let make = (~initialSpec, ~dispatch) => {
  let (schema, setSchema) = React.useState(_ => None)
  let (text, setText) = React.useState(_ => initialSpec->Js.Json.stringifyWithSpace(2))

  // https://github.com/vega/vega-lite/blob/b61b13c2cbd4ecde0448544aff6cdaea721fd22a/examples/examples.test.ts
  // let ajv = newAjv({allowUnionTypes: true, strictTypes: false, strictTuples: false})
  // ajv->addFormat("color-hex", () => true)
  // // addFormats(ajv)
  // // ajv->addMetaSchema(draft6Schema)
  // ajv->addKeyword("defs")
  // ajv->addKeyword("refs")

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

  let spec = text->Util.parseJson
  let valid = switch (spec, schema) {
  | (Result.Error(_), _) => false
  // | (Result.Ok(parsed), Some(schema)) => {
  //     let validate = ajv->compile(schema)
  //     Js.log(validate(parsed))
  //     true
  //   }

  | _ => true
  }

  // let submitButton = switch parseResult {
  // | Result.Error(_) => <Button text={"Submit"} onClick={_ => ()} disabled={true} />
  // | Result.Ok(spec) => <Button text={"Submit"} onClick={_ => spec->onSubmit} disabled={false} />
  // }
  let buttons = [
    <Button
      text={"Submit"}
      onClick={_ => dispatch(Util.Submit(spec->Result.getExn))}
      disabled={spec->Result.isError}
    />,
    <Button
      text={"Cancel"} onClick={_ => dispatch(Util.ToggleRender(initialSpec))} disabled={false}
    />,
  ]

  let textAreaClassName =
    "focus:outline-none border shadow w-full rounded-md"->Js.String2.concat(
      valid ? " focus:border-indigo-500 " : " focus:border-red-300",
    )

  <div className="sm:gap-4 sm:items-start">
    <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
    <textarea
      rows=10
      onChange={evt => {
        let text = ReactEvent.Form.target(evt)["value"]
        setText(_ => text)
      }}
      className={textAreaClassName}
      placeholder={"Enter new vega spec"}
      value={text}
    />
    <div className="pt-5">
      {switch spec {
      | Result.Error(Some(e)) =>
        <p className="flex-1 mt-2 text-sm text-red-600" id="json-error"> {e->React.string} </p>
      | _ => <> </>
      }}
      <Buttons buttons />
    </div>
  </div>
}
