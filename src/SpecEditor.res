open Belt

@react.component
let make = (~initialSpec: Js.Json.t, ~dispatch) => {
  let (text, setText) = React.useState(_ => initialSpec->Js.Json.stringifyWithSpace(2))

  let spec = text->Util.parseJson
  let valid = spec->Result.isOk

  let buttons = [
    <Button
      text={"Submit"}
      onClick={_ => {
        dispatch(Util.Submit(spec->Result.getExn))
        setText(_ => "")
      }}
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
