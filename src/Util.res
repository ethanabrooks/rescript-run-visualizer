open Belt

@module("js-yaml") external yaml: Js.Json.t => string = "dump"

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

let splitHash = Js.String.split("/")
let jsonToMap = json =>
  json->Js.Json.decodeObject->Option.map(dict => dict->Js.Dict.entries->Map.String.fromArray)
let mapToJson = map => map->Map.String.toArray->Js.Dict.fromArray->Js.Json.object_

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>
type jsonMap = Map.Int.t<Js.Json.t>
type jsonArray = array<Js.Json.t>

let merge = (_, old, new) =>
  switch (old, new) {
  | (None, None) => None
  | (Some(x), _)
  | (None, Some(x)) =>
    Some(x)
  }

module ErrorPage = {
  @react.component
  let make = (~message: string) => <p> {message->React.string} </p>
}
