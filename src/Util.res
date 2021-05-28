open Belt

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>
type jsonMap = Map.Int.t<Js.Json.t>
type jsonArray = array<Js.Json.t>
