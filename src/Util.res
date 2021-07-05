open Belt

@module("js-yaml") external yaml: Js.Json.t => string = "dump"

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

module OptionComparator = (M: Id.Comparable) => Belt.Id.MakeComparable({
  type t = option<M.t>
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

module OptionIntComparator = Belt.Id.MakeComparable({
  type t = option<int>
  @dead("JsonComparator.+cmp") let cmp = Pervasives.compare
})

let jsonToMap = json =>
  json->Js.Json.decodeObject->Option.map(dict => dict->Js.Dict.entries->Map.String.fromArray)
let mapToJson = map => map->Map.String.toArray->Js.Dict.fromArray->Js.Json.object_

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>
type jsonMap = Map.Int.t<Js.Json.t>
type jsonArray = array<Js.Json.t>
type specs = jsonMap
type parseResult = Result.t<Js.Json.t, option<string>>

let merge = (_, old, new) =>
  switch (old, new) {
  | (None, None) => None
  | (Some(x), _)
  | (None, Some(x)) =>
    Some(x)
  }

let mapError = (res: Result.t<'o, 'e>, f: 'e => 'f): Result.t<'o, 'f> =>
  switch res {
  | Ok(ok) => ok->Ok
  | Error(e) => e->f->Error
  }

let optionToResult = option => option->Option.mapWithDefault(Error(None), x => x->Ok)
let resultToOption = result => result->Result.mapWithDefault(None, x => x->Some)

let parseJson = string =>
  try string->Js.Json.parseExn->Result.Ok catch {
  | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
  }
