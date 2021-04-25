let buttonClassName = "inline-flex items-center m-1 px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md bg-white text-gray-700 hover:bg-gray-50 focus:outline-none disabled:opacity-50 disabled:cursor-default"

@react.component
let make = (~data: list<Js.Json.t>, ~spec: Js.Json.t, ~edit: Js.Json.t => unit) => {
  <>
    <Chart data spec />
    <div className="flex justify-end">
      <span className="relative z-0 inline-flex">
        <button type_="button" onClick={_ => spec->edit} className=buttonClassName>
          {"Edit chart"->React.string}
        </button>
        <button type_="button" className=buttonClassName> {"Copy spec"->React.string} </button>
        <button type_="button" className=buttonClassName>
          {"Copy spec with some data"->React.string}
        </button>
      </span>
    </div>
  </>
}
