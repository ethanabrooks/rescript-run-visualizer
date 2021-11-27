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
  let make = (~metadata) => <pre className="p-4"> {metadata->Util.yaml->React.string} </pre>
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
    let make = (~logs: jsonMap, ~specs: Map.Int.t<Js.Json.t>, ~metadata: jsonMap, ~runIds) => {
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

      switch (
        LogsSubscription.useLogs(~client, ~logs, ~metadata, ~granularity, ~runIds),
        useSyncCharts(~specs, ~runIds),
      ) {
      | (Error({message}), (_, _))
      | (_, ({error: Some({message})}, _))
      | (_, (_, {error: Some({message})})) =>
        <ErrorPage message />
      | (Ok({new}), _) => <>
          {specs
          ->Map.toArray
          ->List.fromArray
          ->List.sort(((_, {order: order1}), (_, {order: order2})) => order1 - order2)
          ->List.mapWithIndex((i, (spec, {rendering, ids: chartIds})) => {
            let key = i->Int.toString
            if rendering {
              let logs: Util.oldAndNewLogs = {old: logs, new: new}
              <ChartWithButtons key spec chartIds dispatch logs />
            } else {
              let initialSpec = spec
              <SpecEditor key initialSpec dispatch />
            }
          })
          ->List.toArray
          ->React.array}
          {metadata
          ->Map.Int.valuesToArray
          ->Array.mapWithIndex((i, metadata) => <Metadata key={i->Int.toString} metadata />)
          ->React.array}
        </>
      }
    }
  }

  switch RunsSubscription.useSubscription(~client, ~granularity, ~ids) {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logs, specs, metadata, runIds}) => <Charts logs specs metadata runIds />
  }
}
