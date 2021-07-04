open Belt

type route =
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

let splitHash = Js.String.split("/")
let urlToRoute = (url: ReasonReactRouter.url) => {
  let hashParts = url.hash->splitHash->List.fromArray

  let ids = switch hashParts {
  | list{_, _, ids}
  | list{_, ids} =>
    ids->processIds
  | _ => Set.Int.empty
  }

  let archived = switch hashParts {
  | list{_, "archived", ..._} => true
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

let routeToUrl = (route: route) => {
  let idSetToString = set => set->Set.Int.toArray->Js.Array2.joinWith(",")
  let completeUrl = (base, ids, archived) =>
    `${base}/${archived ? "archived/" : ""}${ids->idSetToString}`
  switch route {
  | Sweeps({ids, archived}) => "sweeps"->completeUrl(ids, archived)
  | Runs({ids, archived}) => "runs"->completeUrl(ids, archived)
  | Redirect => ""
  | NotFound(hash) => hash
  }
}
