open Belt
open Util

let _make = (
  ~logs: jsonMap,
  ~specs: specs,
  ~metadata: jsonArray,
  ~insertChartButton: (~parseResult: Util.parseResult, ~chartIds: Set.Int.t) => React.element,
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
  let makeSpecEditor = SpecEditor._make(~setSpecs)

  <>
    {reverseSpecs
    ->Map.toArray
    ->Array.mapWithIndex((i, (spec, chartIds)) => {
      let insertChartButton = insertChartButton(~chartIds)
      let makeSpecEditor = makeSpecEditor(~chartIds, ~insertChartButton)
      <div key={i->Int.toString} className="py-5">
        <ChartOrTextbox initialSpec={spec->Some} data makeSpecEditor />
      </div>
    })
    ->Array.concat([
      // empty chart
      <div key={reverseSpecs->Map.size->Int.toString} className="py-5">
        {
          let initialSpec = None
          let chartIds = Set.Int.empty
          let insertChartButton = insertChartButton(~chartIds)
          let makeSpecEditor = makeSpecEditor(~chartIds, ~insertChartButton)
          <ChartOrTextbox initialSpec data makeSpecEditor />
        }
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

@react.component
let make = (~logs, ~specs, ~metadata, ~insertChartButton) => {
  _make(~logs, ~specs, ~metadata, ~insertChartButton)
}
