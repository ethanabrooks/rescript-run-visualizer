open Belt
module Inner = {
  @module("./Chart.jsx")
  external make: (
    ~data: array<Js.Json.t>,
    ~newData: array<Js.Json.t>,
    ~spec: Js.Json.t,
  ) => React.element = "make"

  @react.component
  let make = (~data, ~newData, ~spec) => make(~data, ~newData, ~spec)
}

@react.component
let make = (~logs, ~spec) => {
  let {old, new}: Util.oldAndNewLogs = logs
  let toArray = data => data->Map.Int.toArray->Array.map(((_, v)) => v)
  let (data, setData) = React.useState(_ => [])
  React.useEffect1(() => {
    setData(_ => old->toArray)
    None
  }, [old])
  let newData = new->toArray
  <Inner data newData spec />
}
