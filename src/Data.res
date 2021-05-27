open Belt

@decco
type runId = int

@decco
type logId = int

type logEntry = (int, Js.Json.t)

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  let cmp = Pervasives.compare
})

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>

type t = list<(int, Js.Json.t)>

type state =
  | NoMatch
  | Loading
  | Error(string)
  | Data({logs: t, specs: jsonSet, metadata: option<Js.Json.t>})

type queryResult = {metadata: option<Js.Json.t>, specs: array<Js.Json.t>}

let getState = (
  ~logs: Result.t<option<t>, ApolloClient__Errors_ApolloError.t>,
  ~runs: option<array<queryResult>>,
) =>
  switch (logs, runs) {
  | (Ok(Some(logs)), Some(runs)) =>
    runs
    ->Array.reduce(None, (aggregated, {metadata, specs}): option<(array<Js.Json.t>, jsonSet)> => {
      // metadata // specs
      let specs: jsonSet = specs->Set.fromArray(~id=module(JsonComparator))
      let metadata = metadata->Option.mapWithDefault([], m => [m])
      aggregated
      ->Option.mapWithDefault((metadata, specs), ((m, s)) => {
        let m = metadata->Array.concat(m)
        let s = specs->Set.union(s)
        (m, s)
      })
      ->Some
    })
    ->Option.mapWithDefault(NoMatch, ((metadata, specs)) => {
      let metadata = switch metadata {
      | [] => None
      | [metadata] => metadata->Some
      | metadata => metadata->Js.Json.array->Some
      }
      Data({specs: specs, logs: logs, metadata: metadata})
    })
  | (Ok(None), _)
  | (_, None) =>
    Loading
  | (Error({message}), _) => Error(message)
  }
