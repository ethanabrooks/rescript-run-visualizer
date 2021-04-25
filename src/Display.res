open Belt
open ChartWrapper

type data = {specs: list<Js.Json.t>, metadata: option<Js.Json.t>, logs: list<(int, Js.Json.t)>}

@react.component
let make = (~state: Data.state<data>) => {
  let (specs, setSpecs) = React.useState(_ => list{})
  React.useEffect1(() => {
    switch state {
    | Data({specs}) => setSpecs(_ => specs)
    | _ => ()
    }
    None
  }, [state])
  switch state {
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Data({logs}) => {
      let data = logs->List.map(((_, log)) => log)
      <>
        {specs
        ->List.reverse
        ->List.mapWithIndex((i, spec) =>
          <div key={i->Int.toString} className="py-5">
            <ChartWrapper data specState={InCharts(spec)} />
          </div>
        )
        ->List.add(
          <div key={"last"} className="py-5">
            <ChartWrapper
              data
              specState={NotInCharts(
                spec => {
                  setSpecs(_ => list{spec, ...specs})
                },
              )}
            />
          </div>,
        )
        ->List.reverse
        ->List.toArray
        ->React.array}
      </>
    }
  }
}
