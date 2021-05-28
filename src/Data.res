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

type pair = (int, Js.Json.t)

module PairComparator = Belt.Id.MakeComparable({
  type t = (int, Js.Json.t)
  @dead("PairComparator.+cmp") let cmp = ((n1, _), (n2, _)) => Pervasives.compare(n1, n2)
})

type pairSet = Set.t<pair, PairComparator.identity>

type queryResult = {
  metadata: option<Js.Json.t>,
  specs: array<Js.Json.t>,
  logs: pairSet,
}

type state =
  | NoMatch
  | Loading
  | Error(string)
  | Data({logs: pairSet, specs: jsonSet, metadata: option<Js.Json.t>})
