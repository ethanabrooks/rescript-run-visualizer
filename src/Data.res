open Belt

@decco
type runId = int

@decco
type logId = int

type logEntry = (int, Js.Json.t)

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>

type state =
  | NoMatch
  | Loading
  | Error(string)
  | Data({logs: list<(int, Js.Json.t)>, specs: jsonSet, metadata: option<Js.Json.t>})

type queryResult = {metadata: option<Js.Json.t>, specs: array<Js.Json.t>}
