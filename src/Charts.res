open Belt
open ChartOrTextbox

@react.component
let make = (~logs: Data.pairSet, ~specs, ~metadata) => {
  let (specs, setSpecs) = React.useState(_ => specs)
  let data = logs->Set.toArray->Array.map(((_, log)) => log)
  let charts = specs->Array.mapWithIndex((i, spec) =>
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
  let emptyChart =
    <div key={charts->Array.length->Int.toString} className="py-5">
      <ChartOrTextbox
        data
        specState={NoSpec({
          submit: spec => {
            setSpecs(_ => specs->Array.concat([spec]))
          },
        })}
      />
    </div>

  let charts = charts->Array.concat([emptyChart])

  <>
    {metadata->Option.mapWithDefault(<> </>, metadata =>
      <pre className="p-4"> {metadata->Js.Json.stringifyWithSpace(2)->React.string} </pre>
    )}
    {charts->React.array}
  </>
}
