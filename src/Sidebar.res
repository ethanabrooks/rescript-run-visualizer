open Routes
open SidebarFilterInput
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

let buttonClass = "w-20 h-10 border border-gray-300 text-sm bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default px-2 items-center justify-center"

@react.component
let make = (~urlParams: urlParams, ~client: ApolloClient__Core_ApolloClient.t) => {
  let whereResults = urlParams.where->whereOptionToTexts->Predicate.map(textToResult)
  let where = whereResults->resultsToWhere
  let {granularity, archived} = urlParams
  let queryResult = SidebarItemsSubscription.useSidebarItems(
    ~granularity,
    ~archived,
    ~where,
    ~client,
  )

  // let nextHref = {
  //   let where = where->Option.getWithDefault
  // }

  <div className="w-1/2 m-5">
    <SidebarFilter urlParams />
    {queryResult->Option.mapWithDefault(<p> {"Loading..."->React.string} </p>, queryResult =>
      switch queryResult {
      | Error(message) => <ErrorPage message />
      | Ok(items) =>
        let checkedIds = urlParams.checkedIds
        <div
          className="flow-root py-10 max-height-80vh overflow-y-scroll overscroll-contain resize-x">
          <ul className="divide-y divide-gray-200">
            {items
            ->List.fromArray
            ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
            ->List.map(({id, metadata}) => <SidebarItem id checkedIds metadata />)
            ->List.toArray
            ->React.array}
          </ul>
        </div>
      }
    )}
    // {<a href> {""->React.string} </a>}
    // {<a href> {""->React.string} </a>}
  </div>
}
