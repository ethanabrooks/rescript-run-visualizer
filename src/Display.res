open Belt

type data = {specs: list<Js.Json.t>, metadata: option<Js.Json.t>, logs: list<(int, Js.Json.t)>}

@react.component
let make = (~state: Data.state<data>) => {
  switch state {
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Data({specs, logs}) => {
      Js.log(specs)
      <>
        {specs
        ->List.mapWithIndex((i, spec) => {
          <div className="py-5">
            <ChartWrapper key={i->Int.toString} data={logs->List.map(((_, log)) => log)} spec />
          </div>
        })
        ->List.toArray
        ->React.array}
      </>
    }
  }
}
