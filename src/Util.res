open Belt

type options = {sortKeys: bool}
@module("js-yaml") external yaml: (Js.Json.t, options) => string = "dump"

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
type jsonArray = array<Js.Json.t>
type parseResult = Result.t<Js.Json.t, option<string>>

let merge = (_, old, new) =>
  switch (old, new) {
  | (None, None) => None
  | (Some(x), _)
  | (None, Some(x)) =>
    Some(x)
  }

let resultToOption = result => result->Result.mapWithDefault(None, x => x->Some)
let mapError = (res: Result.t<'o, 'e>, f: 'e => 'f): Result.t<'o, 'f> =>
  switch res {
  | Ok(ok) => ok->Ok
  | Error(e) => e->f->Error
  }

let parseJson = string =>
  try string->Js.Json.parseExn->Result.Ok catch {
  | Js.Exn.Error(e) => Result.Error(e->Js.Exn.message)
  }

let setArray = (a, i, x) => a->Array.mapWithIndex((j, y) => i == j ? x : y)

let joinWith = (a, x) =>
  a->Array.reduce([], (a, y) =>
    switch a {
    | [] => [y]
    | _ => a->Array.concat([x, y])
    }
  )

type queryResult<'a> = Loading | Error(string) | Stuck | Data('a)
type chartState = {rendering: bool, ids: Set.Int.t, order: int, needsUpdate: bool}
type chartAction =
  ToggleRender(Js.Json.t) | Submit(Js.Json.t) | Insert(Js.Json.t, Set.Int.t) | Remove(Js.Json.t)
type mutationResult<'a> = Loading | Error(string) | NotCalled | Data('a)
type subscriptionState<'a> = NoData | Waiting | Error(ApolloClient__Errors_ApolloError.t) | Data('a)
