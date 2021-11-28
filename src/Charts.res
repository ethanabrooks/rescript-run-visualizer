open Util
open Belt
open SyncCharts

module Subscription = %graphql(`
  query MyQuery($condition: run_log_bool_exp!) {
  run_log_aggregate(where: $condition) {
    aggregate {
      count(distinct: true)
    }
  }
}
`)

module Metadata = {
  @react.component
  let make = (~id: int, ~metadata) => {
    open Routes
    let href =
      Valid({
        granularity: Run,
        ids: Set.Int.empty->Set.Int.add(id),
        archived: false,
        where: None,
      })
      ->routeToHash
      ->hashToHref
    <div className="p-4">
      <a href className="font-medium text-indigo-700 hover:underline">
        {id->Int.toString->React.string}
      </a>
      <pre className="text-gray-500"> {metadata->Util.yaml({sortKeys: true})->React.string} </pre>
    </div>
  }
}

// Convert Map.Int.t<Js.Json.t> to Map.t<Json.t, chartState>
let reverse = specs =>
  specs->Map.Int.reduce(
    Map.make(~id=module(Util.JsonComparator))->Map.set(
      Js.Json.null,
      {rendering: false, ids: None, order: specs->Map.Int.size, dirty: false},
    ),
    (map, id, spec) => {
      let ids =
        map->Map.get(spec)->Option.flatMap(({ids}) => ids)->Option.getWithDefault(Set.Int.empty)
      let ids = ids->Set.Int.add(id)->Some
      let order = map->Map.size - 1
      map->Map.set(spec, {ids: ids, rendering: true, order: order, dirty: false})
    },
  )

@react.component
let make = (~client, ~granularity, ~ids) => {
  module Charts = {
    @react.component
    let make = (~logCount: int, ~specs: Map.Int.t<Js.Json.t>, ~metadata: jsonMap, ~runIds) => {
      let (specs, dispatch) = React.useReducer((specs, action) =>
        switch action {
        | Set(specs) => specs->reverse
        | ToggleRender(spec) =>
          let {rendering, ids, order} = specs->Map.getExn(spec)
          specs->Map.set(spec, {rendering: !rendering, ids: ids, order: order, dirty: false})
        | Submit(spec) =>
          let specState =
            specs
            ->Map.get(spec)
            ->Option.getWithDefault({
              rendering: true,
              ids: None,
              order: specs->Map.size,
              dirty: true,
            })
          specs->Map.set(spec, {...specState, rendering: true})
        }
      , specs->reverse)

      switch (LogsQuery.useLogs(~logCount, ~runIds), useSyncCharts(~specs, ~runIds)) {
      | (Error(message), (_, _))
      | (_, ({error: Some({message})}, _))
      | (_, (_, {error: Some({message})})) =>
        <ErrorPage message />
      | (Loading, _) => <LoadingPage />
      | (Stuck, _) => <ErrorPage message={"Stuck."} />
      | (Data(logs), _) => <>
          {specs
          ->Map.toArray
          ->List.fromArray
          ->List.sort(((_, {order: order1}), (_, {order: order2})) => order1 - order2)
          ->List.mapWithIndex((i, (spec, {rendering, ids: chartIds})) => {
            let key = i->Int.toString
            if rendering {
              <div className="pb-10" key>
                <Chart logs spec /> <ChartButtons spec chartIds dispatch />
              </div>
            } else {
              let initialSpec = spec
              <SpecEditor key initialSpec dispatch />
            }
          })
          ->List.toArray
          ->React.array}
          {metadata
          ->Map.Int.toArray
          ->Array.map(((id, metadata)) => <Metadata key={id->Int.toString} id metadata />)
          ->React.array}
        </>
      }
    }
  }

  switch InitialSubscription.useSubscription(~client, ~granularity, ~ids) {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logCount, specs, metadata, runIds}) => <Charts logCount specs metadata runIds />
  }
}
