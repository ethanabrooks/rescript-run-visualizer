open Belt
open Util

@decco
type granularity = Sweep | Run

@decco
type valid = {
  granularity: granularity,
  @decco.default(Set.Int.empty) ids: @decco.codec(Decco.Codecs.magic) Set.Int.t,
  @decco.default(false) archived: bool,
  @decco.default(None) obj: option<Js.Json.t>,
  @decco.default(None) pattern: option<string>,
  @decco.default(None) path: option<array<string>>,
}

type route =
  | Valid({
      granularity: granularity,
      ids: Set.Int.t,
      archived: bool,
      obj: option<Js.Json.t>,
      pattern: option<string>,
      path: option<array<string>>,
    })
  | Redirect
  | NotFound(string)

let makeRoute = (
  ~granularity,
  ~ids=Set.Int.empty,
  ~archived=false,
  ~obj=None,
  ~pattern=None,
  ~path=None,
  (),
) => Valid({
  granularity: granularity,
  ids: ids,
  archived: archived,
  obj: obj,
  pattern: pattern,
  path: path,
})

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

let hashToRoute = (hash: string) =>
  switch hash {
  | "" => Redirect
  | _ =>
    hash
    ->Js.Global.decodeURI
    ->parseJson
    ->Result.flatMap(res => res->valid_decode->mapError(({message}) => message->Some))
    ->Result.flatMap(valid =>
      Valid({
        granularity: valid.granularity,
        ids: valid.ids,
        archived: valid.archived,
        obj: valid.obj,
        pattern: valid.pattern,
        path: valid.path,
      })->Ok
    )
    ->Result.getWithDefault(NotFound(hash))
  }

let routeToHash = (route: route): string =>
  switch route {
  | Valid({granularity, ids, archived, obj, pattern, path}) =>
    {
      granularity: granularity,
      ids: ids,
      archived: archived,
      obj: obj,
      pattern: pattern,
      path: path,
    }
    ->valid_encode
    ->Js.Json.stringify
    ->Js.Global.encodeURI

  | Redirect => ""
  | NotFound(hash) => hash
  }

let hashToHref = hash => `#${hash}`
let routeToHref = route => route->routeToHash->hashToHref
let urlToRoute = (url: ReasonReactRouter.url) => url.hash->hashToRoute
