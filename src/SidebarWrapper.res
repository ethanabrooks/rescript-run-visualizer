open Routes
open Belt

type whereResults = Predicate.t<Belt.Result.t<Hasura.metadata, option<string>>>

let whereToTexts = (where: Hasura.where) =>
  where->Predicate.map((Contains(json)) => json->Js.Json.stringify)

let whereOptionToTexts = (where: option<Hasura.where>) =>
  where->Option.getWithDefault(Just(Contains(Js.Dict.empty()->Js.Json.object_)))->whereToTexts

let textsToResults = (texts: Predicate.t<string>): whereResults =>
  texts
  ->Predicate.map(text => text->Util.parseJson)
  ->Predicate.map(res =>
    res->Result.map((metadata: Js.Json.t): Hasura.metadata => Contains(metadata))
  )

let rec textsToTextSetters = (texts: Predicate.t<string>): Predicate.t<
  string => Predicate.t<string>,
> => {
  let setArray = (a, i, x) => a->Array.mapWithIndex((j, y) => i == j ? x : y)
  switch texts {
  | And(a) =>
    a
    ->Array.mapWithIndex((i, _texts) =>
      _texts
      ->textsToTextSetters
      ->Predicate.map((set, text) => a->setArray(i, text->set)->Predicate.And)
    )
    ->Predicate.And
  | Or(a) =>
    a
    ->Array.mapWithIndex((i, _texts) =>
      _texts
      ->textsToTextSetters
      ->Predicate.map((set, text) => a->setArray(i, text->set)->Predicate.Or)
    )
    ->Predicate.Or
  | Just(_) => Just(t => t->Just)
  }
}

let rec componentsPredicateToComponent = (
  components: Predicate.t<React.element>,
): React.element => {
  switch components {
  | Just(x) => x
  | And(a) =>
    <div>
      <label className="text-sm font-sm text-gray-700"> {"And"->React.string} </label>
      <div> {a->Array.map(componentsPredicateToComponent)->React.array} </div>
    </div>
  | Or(a) =>
    <div>
      <label className="text-sm font-sm text-gray-700"> {"Or"->React.string} </label>
      <div> {a->Array.map(componentsPredicateToComponent)->React.array} </div>
    </div>
  }
}

let rec resultsToWhere = (whereResults: whereResults): option<Hasura.where> =>
  switch whereResults {
  | And(a) => a->Array.keepMap(resultsToWhere)->And->Some
  | Or(a) => a->Array.keepMap(resultsToWhere)->Or->Some
  | Just(metadata) => metadata->Util.resultToOption->Option.map(x => x->Predicate.Just)
  }

let rec whereToLabel = (where: Hasura.where) => {
  let f = a =>
    Array.zip(a, a->Array.map(whereToLabel))->Array.map(((where, label)) =>
      switch where {
      | Just(_) => label
      | _ => `(${label})`
      }
    )
  switch where {
  | Just(Contains(x)) => `metadata @> ${x->Js.Json.stringify}`
  | And(a) => a->f->Js.Array2.joinWith(" AND ")
  | Or(a) => a->f->Js.Array2.joinWith(" OR ")
  }
}

@react.component
let make = (
  ~ids: Set.Int.t,
  ~granularity,
  ~archived: bool,
  ~where: option<Hasura.where>,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let initialWhere = where
  let (whereTexts, setWhereTexts) = React.useState(_ => initialWhere->whereOptionToTexts)

  React.useEffect1(() => {
    setWhereTexts(_ => initialWhere->whereOptionToTexts)
    None
  }, [initialWhere])

  let whereResults = whereTexts->textsToResults
  let where = whereResults->resultsToWhere
  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~where,
    ~client,
  )

  let route = makeRoute(~granularity, ~ids, ~archived, ~where, ())
  let href = route->routeToHref
  let components = Predicate.zip(whereTexts, whereTexts->textsToTextSetters)->Predicate.map(((
    text,
    setter,
  )) => {
    let setText = text => setWhereTexts(_ => text->setter)
    <MetadataFilter text setText />
  })

  <div className="pb-10 resize-x w-1/3 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    <div className="pb-5 -space-y-px">
      {where->Option.mapWithDefault(<> </>, where =>
        <label className="text-sm font-sm text-gray-700">
          <a href> {`Filter by ${where->whereToLabel}`->React.string} </a>
        </label>
      )}
      {components->componentsPredicateToComponent}
    </div>
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | Error(message) => <ErrorPage message />
      | Ok(items) => <Sidebar items ids />
      }
    )}
  </div>
}
