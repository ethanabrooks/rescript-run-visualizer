open Belt
open Util
open SpecEditor

module ChartIdQuery = %graphql(`
  query queryChartIds {
    chart(limit: 1, order_by: [{id: desc}]) {
      id
    }
  }
`)

let _make = (~logs: jsonMap, ~specs: specs, ~metadata: jsonArray) => {
  let (specs: specs, setSpecs) = React.useState(_ => specs)
  switch ChartIdQuery.use() {
  | {loading: true} => <> </>
  | {error: Some(_error)} => "Error loading ArchiveQuery data"->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some({chart: [{id: chartId}]})} => {
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
          let initialState = Rendering(spec)
          let setSpecs = spec =>
            setSpecs(specs =>
              chartIds->Set.Int.reduce(specs, (specs, chartId) => specs->Map.Int.set(chartId, spec))
            )
          let chartIds = chartIds->Some

          <div key={i->Int.toString} className="py-5">
            <ChartOrTextbox initialState data setSpecs chartIds />
          </div>
        })
        ->Array.concat([
          // empty chart
          <div key={reverseSpecs->Map.size->Int.toString} className="py-5">
            {
              let initialState = Editing(Js.Json.null)
              let chartIds = None
              let setSpecs = spec => setSpecs(specs => specs->Map.Int.set(chartId, spec))
              <ChartOrTextbox initialState data setSpecs chartIds />
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
  | {data: Some({chart})} =>
    Js.Exn.raiseError(`Somehow query returned ${chart->Array.length->Int.toString} chart IDs`)
  }
}

@react.component
let make = (~logs, ~specs, ~metadata) => {
  _make(~logs, ~specs, ~metadata)
}
