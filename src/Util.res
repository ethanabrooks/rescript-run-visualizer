open Belt

@module external copy: string => bool = "copy-to-clipboard"

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
type chartAction = ToggleRender(Js.Json.t) | Submit(Js.Json.t) | Set(specs)
type oldAndNewLogs = {old: jsonMap, new: jsonMap}

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

let parseJson = string =>
  try string->Js.Json.parseExn->Result.Ok catch {
  | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
  }
