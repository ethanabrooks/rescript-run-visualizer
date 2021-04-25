open Belt
type state = Editing(string) | Visualizing(Js.Json.t)
@react.component
let make = (~data: list<Js.Json.t>, ~spec: Js.Json.t) => {
  let (state, setState) = React.useState(_ => Editing(spec->Js.Json.stringifyWithSpace(2)))
  switch state {
  | Visualizing(spec) => <>
      <Chart data spec />
      <div className="flex justify-end">
        <span className="relative z-0 inline-flex shadow-sm rounded-md">
          <button
            type_="button"
            onClick={_ => setState(_ => Editing(spec->Js.Json.stringifyWithSpace(2)))}
            className="relative inline-flex items-center px-4 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500">
            {"Edit chart"->React.string}
          </button>
          <button
            type_="button"
            className="-ml-px relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500">
            {"Copy spec"->React.string}
          </button>
          <button
            type_="button"
            className="-ml-px relative inline-flex items-center px-4 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500">
            {"Copy spec with some data"->React.string}
          </button>
        </span>
      </div>
    </>
  | Editing(text) => {
      let spec = try text->Js.Json.parseExn->Result.Ok catch {
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
          onChange={evt => setState(_ => Editing(ReactEvent.Form.target(evt)["value"]))}
          className={textAreaClassName}
          placeholder={"Enter new vega spec"}
          value={text}
        />
        <div className="pt-5">
          <div className="flex justify-end">
            {switch spec {
            | Result.Error(Some(e)) =>
              <p className="flex-1 mt-2 text-sm text-red-600" id="email-error">
                {e->React.string}
              </p>
            | _ => <> </>
            }}
            <button
              type_="submit"
              disabled={spec->Result.isError}
              onClick={_ =>
                switch spec {
                | Result.Ok(spec) => setState(_ => Visualizing(spec))
                | _ => ()
                }}
              className={"ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white focus:outline-none"->Js.String2.concat(
                switch spec {
                | Result.Ok(_) => " bg-indigo-600 hover:bg-indigo-700"
                | Result.Error(_) => " bg-gray-400 cursor-default"
                },
              )}>
              {"Submit"->React.string}
            </button>
          </div>
        </div>
      </div>
    }
  }
}
