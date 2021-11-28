open Routes
open SidebarFilterInput
open Belt

type whereResults = Predicate.t<Belt.Result.t<Hasura.metadata, option<string>>>

let whereToTexts = (where: Hasura.where): Predicate.t<string> =>
  where->Predicate.map((Contains(json)) => json->Js.Json.stringify)

let whereOptionToTexts = (where: option<Hasura.where>): Predicate.t<string> =>
  where->Option.mapWithDefault(Predicate.Just(""), whereToTexts)

let rec resultsToWhere = (whereResults: whereResults): option<Hasura.where> =>
  switch whereResults {
  | And(a) => a->Array.keepMap(resultsToWhere)->And->Some
  | Or(a) => a->Array.keepMap(resultsToWhere)->Or->Some
  | Just(metadata) => metadata->Util.resultToOption->Option.map(x => x->Predicate.Just)
  }

let buttonClass = "w-20 h-10 border border-gray-300 text-sm bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default px-2 items-center justify-center"

@react.component
let make = (
  ~ids: Set.Int.t,
  ~granularity,
  ~archived: bool,
  ~where: option<Hasura.where>,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let whereResults = where->whereOptionToTexts->Predicate.map(textToResult)
  let where = whereResults->resultsToWhere
  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~where,
    ~client,
  )

  <div className="w-1/2 m-5">
    <SidebarFilter ids granularity archived where />
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | Error(message) => <ErrorPage message />
      | Ok(items) =>
        <div
          className="flow-root py-10 max-height-80vh overflow-y-scroll overscroll-contain resize-x">
          <ul className="divide-y divide-gray-200">
            {items
            ->List.fromArray
            ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
            ->List.map(({id, metadata}) => <SidebarItem id ids metadata />)
            ->List.toArray
            ->React.array}
          </ul>
        </div>
      }
    )}
  </div>
}
