open Belt
open ViewChart
type action =
  | RevertToOriginalSpec({spec: Js.Json.t, callback: unit => unit})
  | AddSpecToCharts(Js.Json.t => unit)

@react.component
let make = (~action, ~visualize: Js.Json.t => unit) => {
  let (text, setText) = React.useState(_ =>
    switch action {
    | RevertToOriginalSpec({spec}) => spec->Js.Json.stringifyWithSpace(2)
    | _ => ""
    }
  )

  let parsed = try text->Js.Json.parseExn->Result.Ok catch {
  | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
  }
  let textAreaClassName = "focus:outline-none border shadow w-full rounded-md"->Js.String2.concat(
    switch parsed {
    | Result.Ok(_) => " focus:border-indigo-500 "
    | Result.Error(_) => " focus:border-red-300"
    },
  )
  <div className="sm:gap-4 sm:items-start">
    <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
    <textarea
      rows=20
      onChange={evt => setText(_ => ReactEvent.Form.target(evt)["value"])}
      className={textAreaClassName}
      placeholder={"Enter new vega spec"}
      value={text}
    />
    <div className="pt-5">
      <div className="flex justify-end">
        {switch parsed {
        | Result.Error(Some(e)) =>
          <p className="flex-1 mt-2 text-sm text-red-600" id="json-error"> {e->React.string} </p>
        | _ => <> </>
        }}
        {switch action {
        | RevertToOriginalSpec({callback}) =>
          <button type_="submit" onClick={_ => callback()} className={buttonClassName}>
            {"Cancel"->React.string}
          </button>
        | AddSpecToCharts(callback) =>
          <button
            type_="submit"
            onClick={_ => parsed->Result.mapWithDefault((), callback)}
            className={buttonClassName}>
            {"Add spec to charts"->React.string}
          </button>
        }}
        <button
          type_="submit"
          disabled={parsed->Result.isError}
          onClick={_ => parsed->Result.mapWithDefault((), visualize)}
          className={buttonClassName}>
          {"Submit"->React.string}
        </button>
      </div>
    </div>
  </div>
}
