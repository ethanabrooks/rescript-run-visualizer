open Util

module ChartIdQuery = %graphql(`
  query queryChartIds {
    chart(limit: 1, order_by: [{id: desc}]) {
      id
    }
  }
`)

@react.component
let make = (~logs: jsonMap, ~newLogs: jsonMap, ~specs: specs, ~metadata: jsonMap, ~runIds) => {
  let (specs: specs, setSpecs) = React.useState(_ => specs)
  open Belt
  switch ChartIdQuery.use() {
  | {loading: true} => <> </>
  | {error: Some(_error)} => "Error loading ArchiveQuery data"->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some({chart: [{id: chartId}]})} => {
      let reverseSpecs = specs->Map.Int.reduce(Map.make(~id=module(JsonComparator)), (
        map,
        id,
        spec,
      ) => {
        let ids = map->Map.get(spec)->Option.getWithDefault(Set.Int.empty)->Set.Int.add(id)
        map->Map.set(spec, ids)
      })

      open SpecEditor
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
            <ChartOrTextbox initialState logs newLogs setSpecs chartIds runIds />
          </div>
        })
        ->Array.concat([
          // empty chart
          <div key={reverseSpecs->Map.size->Int.toString} className="py-5">
            {
              let initialState = Editing(Js.Json.null)
              let chartIds = None
              let setSpecs = spec => setSpecs(specs => specs->Map.Int.set(chartId, spec))
              <ChartOrTextbox initialState logs newLogs setSpecs chartIds runIds />
            }
          </div>,
        ])
        ->React.array}
        {metadata
        ->Map.Int.valuesToArray
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
