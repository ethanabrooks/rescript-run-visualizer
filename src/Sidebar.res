open Routes
open Belt

type whereResults = Predicate.t<Belt.Result.t<Hasura.condition, option<string>>>

let whereToTexts = (where: Hasura.where): Predicate.t<string> =>
  where->Predicate.map(condition =>
    switch condition {
    | MetadataContains(json) => json->Js.Json.stringify
    | IdLessThan(i) => i->Int.toString
    }
  )

let whereOptionToTexts = (where: option<Hasura.where>): Predicate.t<string> =>
  where->Option.mapWithDefault(Predicate.Just(""), whereToTexts)

let rec resultsToWhere = (whereResults: whereResults): option<Hasura.where> =>
  switch whereResults {
  | And(a) => a->Array.keepMap(resultsToWhere)->And->Some
  | Or(a) => a->Array.keepMap(resultsToWhere)->Or->Some
  | Just(metadata) => metadata->Util.resultToOption->Option.map(x => x->Predicate.Just)
  }
let rec containsIdLessThan = (where: Hasura.where): bool => {
  switch where {
  | Just(IdLessThan(_)) => true
  | Just(MetadataContains(_)) => false
  | And(a)
  | Or(a) =>
    a->Array.some(containsIdLessThan)
  }
}

let rec removeIdLessThan = (where: Hasura.where): option<Hasura.where> =>
  switch where {
  | And(array) => array->removeIdLessThanInArray->And->Some
  | Or(array) => array->removeIdLessThanInArray->Or->Some
  | Just(IdLessThan(_)) => None
  | Just(_) => where->Some
  }
and removeIdLessThanInArray = (array: array<Hasura.where>) =>
  array->Array.reduce([], (array, where) =>
    switch where {
    | Just(IdLessThan(_)) => array
    | _ =>
      array->Array.concat(
        switch where->removeIdLessThan {
        | Some(where) => [where]
        | None => []
        },
      )
    }
  )

let buttonClass = "w-20 h-10 border border-gray-300 text-sm bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default px-2 items-center justify-center"

@react.component
let make = (~urlParams: urlParams, ~client: ApolloClient__Core_ApolloClient.t) => {
  let where = urlParams.where
  let {granularity, archived} = urlParams

  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~where,
    ~client,
  )

  <div className="w-1/2 m-5">
    <SidebarFilter urlParams />
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | {error: Some({message})} => <ErrorPage message />
      | {data: None} => <ErrorPage message={"No data."} />
      | {data: Some(items)} =>
        let checkedIds = urlParams.checkedIds
        let ids = items->Array.map(({id}) => id)
        let minId: option<int> =
          ids->Array.reduce(None, (min, id) =>
            min->Option.mapWithDefault(id, Js.Math.min_int(id))->Some
          )
        <div
          className="flow-root py-10 max-height-80vh overflow-y-scroll overscroll-contain resize-x">
          <ul className="divide-y divide-gray-200">
            {items
            ->List.fromArray
            ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
            ->List.map(({id, metadata}) =>
              <SidebarItem key={id->Int.toString} id checkedIds metadata />
            )
            ->List.toArray
            ->React.array}
          </ul>
          <div className="flex flex-row justify-evenly font-black pt-5">
            {<a
              className={where->Option.mapWithDefault(false, containsIdLessThan)
                ? "text-indigo-500"
                : "text-gray-300 pointer-events-none"}
              href={
                let where = where->Option.flatMap(SidebarFilter.removeIdLessThan)
                let urlParams = {...urlParams, where: where}
                Routes.Valid(urlParams)->routeToHref
              }>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5"
                viewBox="0 0 20 20"
                fill="currentColor">
                <path
                  fillRule="evenodd"
                  d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                  clipRule="evenodd"
                />
              </svg>
            </a>}
            {<a
              className={switch minId {
              | None => "text-gray-300 pointer-events-none"
              | _ => "text-indigo-500"
              }}
              href={
                let where = minId->Option.mapWithDefault(where, minId => {
                  let idLessThan: Hasura.where = Just(IdLessThan(minId))
                  switch where->Option.flatMap(removeIdLessThan) {
                  | Some(where) => And([where, idLessThan])
                  | None => idLessThan
                  }->Some
                })
                let urlParams = {...urlParams, where: where}
                Routes.Valid(urlParams)->routeToHref
              }>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5"
                viewBox="0 0 20 20"
                fill="currentColor">
                <path
                  fillRule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clipRule="evenodd"
                />
              </svg>
            </a>}
          </div>
        </div>
      }
    )}
  </div>
}
