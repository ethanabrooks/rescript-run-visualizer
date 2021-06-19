open Belt
open ChartOrTextbox
open Util

@react.component
let make = (~logs: jsonMap, ~specs: jsonSet, ~metadata: jsonArray, ~makeSubmitButton) => {
  let (specs: array<Js.Json.t>, setSpecs) = React.useState(_ => specs->Set.toArray)
  let data = logs->Map.Int.valuesToArray
  <>
    {specs
    ->Array.mapWithIndex((i, spec) =>
      <div key={i->Int.toString} className="py-5">
        <ChartOrTextbox
          data
          specState={Spec({
            spec: spec,
            submit: spec =>
              setSpecs(_ => {
                specs->Array.mapWithIndex((j, oldSpec) => i == j ? spec : oldSpec)
              }),
          })}
        />
      </div>
    )
    ->Array.concat([
      // empty chart
      <div key={specs->Array.length->Int.toString} className="py-5">
        <ChartOrTextbox data specState={NoSpec({makeSubmitButton: makeSubmitButton})} />
      </div>,
    ])
    ->React.array}
    {metadata
    ->Array.mapWithIndex((i, m) =>
      <pre key={i->Int.toString} className="p-4"> {m->Util.yaml->React.string} </pre>
    )
    ->React.array}
  </>
}
