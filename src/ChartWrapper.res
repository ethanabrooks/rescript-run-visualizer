open Belt
type state = Editing({current: string, original: option<Js.Json.t>}) | Visualizing(Js.Json.t)
@react.component
let make = (~data: list<Js.Json.t>, ~spec: option<Js.Json.t>) => {
  let (state, setState) = React.useState(_ =>
    switch spec {
    | None => Editing({current: "", original: None})
    | Some(spec) => Visualizing(spec)
    }
  )
  let buttonClassName = "inline-flex items-center m-1 px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md bg-white text-gray-700 hover:bg-gray-50 focus:outline-none disabled:opacity-50 disabled:cursor-default"
  switch state {
  | Visualizing(spec) => <>
      <Chart data spec />
      <div className="flex justify-end">
        <span className="relative z-0 inline-flex">
          <button
            type_="button"
            onClick={_ =>
              setState(_ => {
                Editing({current: spec->Js.Json.stringifyWithSpace(2), original: spec->Some})
              })}
            className=buttonClassName>
            {"Edit chart"->React.string}
          </button>
          <button type_="button" className=buttonClassName> {"Copy spec"->React.string} </button>
          <button type_="button" className=buttonClassName>
            {"Copy spec with some data"->React.string}
          </button>
        </span>
      </div>
    </>
  | Editing({current, original}) => {
      let spec = try current->Js.Json.parseExn->Result.Ok catch {
      | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
      }
      Js.log(spec)
      let textAreaClassName =
        "focus:outline-none border shadow w-full rounded-md"->Js.String2.concat(
          switch spec {
          | Result.Ok(_) => " focus:border-indigo-500 "
          | Result.Error(_) => " focus:border-red-300"
          },
        )
      Js.log(textAreaClassName)
      <div className="sm:gap-4 sm:items-start">
        <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
        <textarea
          rows=20
          onChange={evt =>
            setState(_ => Editing({
              original: original,
              current: ReactEvent.Form.target(evt)["value"],
            }))}
          className={textAreaClassName}
          placeholder={"Enter new vega spec"}
          value={current}
        />
        <div className="pt-5">
          <div className="flex justify-end">
            {switch spec {
            | Result.Error(Some(e)) =>
              <p className="flex-1 mt-2 text-sm text-red-600" id="json-error">
                {e->React.string}
              </p>
            | _ => <> </>
            }}
            {original->Option.mapWithDefault(<> </>, original =>
              <button
                type_="submit"
                onClick={_ => setState(_ => Visualizing(original))}
                className={buttonClassName}>
                {"Cancel"->React.string}
              </button>
            )}
            <button
              type_="submit"
              disabled={spec->Result.isError}
              onClick={_ =>
                switch spec {
                | Result.Ok(spec) => setState(_ => Visualizing(spec))
                | _ => ()
                }}
              className={buttonClassName}>
              {"Submit"->React.string}
            </button>
          </div>
        </div>
      </div>
    }
  }
}
