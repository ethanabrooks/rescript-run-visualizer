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
      let className =
        "shadow block w-full focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border-gray-300 rounded-md"->Js.String2.concat(
          switch spec {
          | Result.Error(e) => " border-red-300 focus:ring-red-500 focus:border-red-500"
          | _ => ""
          },
        )
      Js.log(className)
      <div className="sm:gap-4 sm:items-start">
        <label className="text-gray-700"> {"Edit Vega Spec"->React.string} </label>
        <textarea
          rows=20
          onChange={evt => setState(_ => Editing(ReactEvent.Form.target(evt)["value"]))}
          className={"focus:outline-none focus:ring focus:ring-red-300 shadow w-full rounded-md"}
          placeholder={"Enter new vega spec"}
          value={text}
        />
        <div className="pt-5">
          <div className="flex justify-end">
            <button
              type_="submit"
              className="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
              {"Submit"->React.string}
            </button>
          </div>
        </div>
      </div>
    }
  }
}
