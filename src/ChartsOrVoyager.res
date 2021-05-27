open Belt
open ChartOrTextbox

@react.component
let make = (~state: Data.state) => {
  let (specs, setSpecs) = React.useState(_ => list{}->Some)
  React.useEffect1(() => {
    switch state {
    | Data({specs}) => setSpecs(_ => specs->Set.toList->Some)
    | _ => ()
    }
    None
  }, [state])
  switch state {
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Data({logs, metadata}) => {
      let data = logs->List.map(((_, log)) => log)
      <>
        {metadata->Option.mapWithDefault(<> </>, metadata =>
          <pre className="p-4"> {metadata->Js.Json.stringifyWithSpace(2)->React.string} </pre>
        )}
        {specs->Option.mapWithDefault(<Voyager data={data->List.toArray} />, specs =>
          specs
          ->List.reverse
          ->List.mapWithIndex((i, spec) =>
            <div key={i->Int.toString} className="py-5">
              <ChartOrTextbox data specState={InCharts(spec)} />
            </div>
          )
          ->List.add(
            <div key={"last"} className="py-5">
              <ChartOrTextbox
                data
                specState={NotInCharts(
                  spec => {
                    setSpecs(_ => list{spec, ...specs}->Some)
                  },
                )}
              />
            </div>,
          )
          ->List.reverse
          ->List.toArray
          ->React.array
        )}
      </>
    }
  }
}
