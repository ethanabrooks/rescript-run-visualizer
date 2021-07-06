open Belt
module Inner = {
  @module("./Chart.jsx")
  external make: (
    ~initialData: array<Js.Json.t>,
    ~data: array<Js.Json.t>,
    ~spec: Js.Json.t,
  ) => React.element = "make"

  @react.component
  let make = (~initialData, ~data, ~spec) => make(~initialData, ~data, ~spec)
}

@react.component
let make = (~logs, ~spec) => {
  let {current, new}: Util.currentAndNewLogs = logs
  let toArray = data => data->Map.Int.toArray->Array.map(((_, v)) => v)
  let (initialData, setInitialData) = React.useState(_ => None)
  let data = new->toArray
  React.useEffect1(() => {
    switch initialData {
    | None => setInitialData(_ => current->toArray->Some)
    | _ => ()
    }
    None
  }, [logs])
  switch initialData {
  | None => <> </>
  | Some(initialData) => <Inner initialData data spec />
  }
}
