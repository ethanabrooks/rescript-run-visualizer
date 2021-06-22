open Belt
open Util
open SpecEditor

let _make = (
  ~logs: jsonMap,
  ~specs: specs,
  ~metadata: jsonArray,
  ~insertChartButton: (~spec: Js.Json.t, ~chartIds: Set.Int.t) => React.element,
) => {
  let (specs: specs, setSpecs) = React.useState(_ => specs)
  let data = logs->Map.Int.valuesToArray
  let reverseSpecs = specs->Map.Int.reduce(Map.make(~id=module(JsonComparator)), (
    map,
    id,
    spec,
  ) => {
    let ids = map->Map.get(spec)->Option.getWithDefault(Set.Int.empty)->Set.Int.add(id)
    map->Map.set(spec, ids)
  })

  <>
    {reverseSpecs
    ->Map.toArray
    ->Array.mapWithIndex((i, (spec, chartIds)) => {
      let insertChartButton = insertChartButton(~chartIds)
      let initialState = Rendering(spec)
      let onSubmit = spec =>
        setSpecs(specs =>
          chartIds->Set.Int.reduce(specs, (specs, chartId) => specs->Map.Int.set(chartId, spec))
        )
      <div key={i->Int.toString} className="py-5">
        <ChartOrTextbox initialState data insertChartButton onSubmit />
      </div>
    })
    // ->Array.concat([
    //   // empty chart
    //   <div key={reverseSpecs->Map.size->Int.toString} className="py-5">
    //     {
    //       let initialState = ChartOrTextbox.Editing(Js.Json.null)
    //       let chartIds = Set.Int.empty
    //       let insertChartButton = insertChartButton(~chartIds)
    //       let onSubmit = spec => {

    //       }
    //       <ChartOrTextbox initialState data insertChartButton  />
    //     }
    //   </div>,
    // ])
    ->React.array}
    {metadata
    ->Array.mapWithIndex((i, m) =>
      <pre key={i->Int.toString} className="p-4"> {m->Util.yaml->React.string} </pre>
    )
    ->React.array}
  </>
}

@react.component
let make = (~logs, ~specs, ~metadata, ~insertChartButton) => {
  _make(~logs, ~specs, ~metadata, ~insertChartButton)
}
