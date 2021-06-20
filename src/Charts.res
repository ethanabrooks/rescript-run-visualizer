open Belt
open Util
open SubmitSpecButton

@react.component
let make = (~logs: jsonMap, ~specs: specs, ~metadata: jsonArray, ~runOrSweepIds: runOrSweepIds) => {
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
    ->Array.mapWithIndex((i, (spec, chartIds)) =>
      <div key={i->Int.toString} className="py-5">
        <ChartOrTextbox initialSpec={spec->Some} chartIds runOrSweepIds data setSpecs />
      </div>
    )
    ->Array.concat([
      // empty chart
      <div key={reverseSpecs->Map.size->Int.toString} className="py-5">
        <ChartOrTextbox data initialSpec={None} chartIds={Set.Int.empty} runOrSweepIds setSpecs />
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
