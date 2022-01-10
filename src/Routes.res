open Belt
open Util

@decco
type granularity = Sweep | Run

@dead("+collectResult")
let collectResult = (array: array<Result.t<'o, 'e>>): Result.t<array<'o>, 'e> => {
  array
  ->Array.reduce(list{}->Ok, (list, res) =>
    switch (list, res) {
    | (Ok(list), Ok(res)) => list{res, ...list}->Ok
    | (Error(e), _)
    | (_, Error(e)) =>
      Error(e)
    }
  )
  ->Result.map(List.toArray)
}

module Predicate = {
  type rec t<'a> =
    | And(array<t<'a>>)
    | Or(array<t<'a>>)
    | Just('a)

  let rec map = (t: t<'a>, f: 'a => 'b) =>
    switch t {
    | And(a) => And(a->Array.map(x => x->map(f)))
    | Or(a) => Or(a->Array.map(x => x->map(f)))
    | Just(x) => Just(x->f)
    }

  let rec zip = (t1: t<'a>, t2: t<'b>): t<('a, 'b)> =>
    switch (t1, t2) {
    | (And(a1), And(a2)) => And(Array.zip(a1, a2)->Array.map(((t1, t2)) => zip(t1, t2)))
    | (Or(a1), Or(a2)) => Or(Array.zip(a1, a2)->Array.map(((t1, t2)) => zip(t1, t2)))
    | (Just(a1), Just(a2)) => Just((a1, a2))
    | _ => Js.Exn.raiseError("structures do not match")
    }
}

module Hasura = {
  @decco
  type condition = MetadataContains(Js.Json.t) | IdLessThan(int)
  type where = Predicate.t<condition>

  @decco
  type _where =
    | And_(array<Js.Json.t>)
    | Or_(array<Js.Json.t>)
    | Just_(condition)

  let rec where_encode = (where: where): Js.Json.t =>
    switch where {
    | And(array) => And_(array->Array.map(where_encode))->_where_encode
    | Or(array) => Or_(array->Array.map(where_encode))->_where_encode
    | Just(metadata) => Just_(metadata)->_where_encode
    }

  @dead("Hasura.+where_decode")
  let rec where_decode = (json: Js.Json.t): Result.t<where, Decco.decodeError> => {
    json
    ->_where_decode
    ->Result.flatMap(_where =>
      switch _where {
      | And_(array) =>
        array->Array.map(where_decode)->collectResult->Result.map((x): where => And(x))
      | Or_(array) => array->Array.map(where_decode)->collectResult->Result.map((x): where => Or(x))
      | Just_(metadata) => metadata->Just->Ok
      }
    )
  }
}

@decco
type urlParams = {
  granularity: granularity,
  @decco.default(Set.Int.empty) checkedIds: @decco.codec(Decco.Codecs.magic) Set.Int.t,
  @decco.default(false) archived: bool,
  @decco.default(None) where: option<Hasura.where>,
}

type route =
  | Valid(urlParams)
  | Redirect
  | NotFound(string)

let makeRoute = (
  ~granularity,
  ~checkedIds=Set.Int.empty,
  ~archived=false,
  ~where=None: option<Hasura.where>,
  (),
) => Valid({
  granularity: granularity,
  checkedIds: checkedIds,
  archived: archived,
  where: where,
})

let hashToRoute = (hash: string) =>
  switch hash {
  | "" => Redirect
  | _ =>
    switch hash->Int.fromString {
    | Some(runId) => makeRoute(~granularity=Run, ~checkedIds=[runId]->Set.Int.fromArray, ())
    | _ =>
      hash
      ->Js.Global.decodeURI
      ->parseJson
      ->Result.flatMap(res => res->urlParams_decode->mapError(({message}) => message->Some))
      ->Result.flatMap(params => Valid(params)->Ok)
      ->Result.getWithDefault(NotFound(hash))
    }
  }

let routeToHash = (route: route): string =>
  switch route {
  | Valid(urlParams) => urlParams->urlParams_encode->Js.Json.stringify->Js.Global.encodeURI
  | Redirect => ""
  | NotFound(hash) => hash
  }

let hashToHref = hash => `#${hash}`
let routeToHref = route => route->routeToHash->hashToHref
let urlToRoute = (url: RescriptReactRouter.url) => url.hash->hashToRoute
