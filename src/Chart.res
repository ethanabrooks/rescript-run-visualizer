open Belt
@module("./Chart.jsx")
external innerMake: (
  ~data: array<Js.Json.t>,
  ~newData: array<Js.Json.t>,
  ~spec: Js.Json.t,
) => React.element = "make"

@react.component
let make = (~logs, ~newLogs, ~spec) => {
  let (initialData, setInitialData) = React.useState(_ => None)
  let mapToArray = l => l->Map.Int.toArray->Array.map(((_, v)) => v)
  let newData = newLogs->mapToArray
  React.useEffect1(() => {
    setInitialData(initialData => initialData->Option.getWithDefault(logs->mapToArray)->Some)
    None
  }, [logs])
  let data = initialData->Option.getWithDefault([])
  innerMake(~data, ~newData, ~spec)
}
