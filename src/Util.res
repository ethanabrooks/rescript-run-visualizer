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

let splitHash = Js.String.split("/")
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

type path =
  | Sweeps({ids: Set.Int.t, archived: bool})
  | Runs({ids: Set.Int.t, archived: bool})
  | Redirect
  | NotFound(string)

let processIds = (ids: string) =>
  ids
  ->Js.String2.split(",")
  ->List.fromArray
  ->List.map(Int.fromString)
  ->List.reduce(list{}, (list, option) =>
    switch option {
    | None => list
    | Some(int) => list{int, ...list}
    }
  )
  ->List.toArray
  ->Set.Int.fromArray

let urlToPath = (url: ReasonReactRouter.url) => {
  let hashParts = url.hash->splitHash->List.fromArray

  let ids = switch hashParts {
  | list{_, "archived", ids}
  | list{_, ids} =>
    ids->processIds
  | _ => Set.Int.empty
  }

  let archived = switch hashParts {
  | list{_, "archived"} => true
  | _ => false
  }

  switch hashParts {
  | list{""} => Redirect
  | list{"runs", ..._} =>
    Runs({
      ids: ids,
      archived: archived,
    })
  | list{"sweeps", ..._} =>
    Sweeps({
      ids: ids,
      archived: archived,
    })
  | _ => NotFound(url.hash)
  }
}

let pathToUrl = (path: path) => {
  let idSetToString = set => set->Set.Int.toArray->Js.Array2.joinWith(",")
  let completeUrl = (base, ids, archived) =>
    `${base}/${archived ? "archived/" : ""}${ids->idSetToString}`
  switch path {
  | Sweeps({ids, archived}) => "sweeps"->completeUrl(ids, archived)
  | Runs({ids, archived}) => "runs"->completeUrl(ids, archived)
  | Redirect => ""
  | NotFound(hash) => hash
  }
}
