@module("copy-to-clipboard") external copy: string => bool = "copy"

@react.component
let make = (~data: list<Js.Json.t>, ~spec: Js.Json.t, ~edit: Js.Json.t => unit) => {
  let specString = spec->Js.Json.stringifyWithSpace(2)
  <>
    <Chart data spec />
    <div className="flex justify-end">
      <span className="relative z-0 inline-flex">
        <button type_="button" onClick={_ => spec->edit} className="button">
          {"Edit chart"->React.string}
        </button>
        <button type_="button" onClick={_ => specString->copy->ignore} className="button">
          {"Copy spec"->React.string}
        </button>
        <button type_="button" className="button">
          {"Copy spec with some data"->React.string}
        </button>
      </span>
    </div>
  </>
}
