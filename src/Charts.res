open Util
open Belt

type chartState = {rendering: bool, ids: option<Set.Int.t>, order: int, dirty: bool}

module InsertChart = %graphql(`
    mutation insertChart($objects: [chart_insert_input!]!) {
        insert_chart(objects: $objects) {
            affected_rows
        }
    }
`)

module UpdateChart = %graphql(`
  mutation update_chart($chartIds: [Int!], $spec: jsonb!) {
    update_chart(_set: {spec: $spec}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

let useSyncCharts = (~specs, ~runIds) => {
  let (updateChart, updateChartResult) = UpdateChart.use()
  let (insertChart, insertChartResult) = InsertChart.use()
  React.useEffect1(() => {
    specs
    ->Map.mapWithKey((spec, {dirty, ids}) =>
      if dirty {
        switch ids {
        | None =>
          let objects: array<InsertChart.t_variables_chart_insert_input> =
            runIds
            ->Set.Int.toArray
            ->Array.map(run_id => InsertChart.makeInputObjectchart_insert_input(~run_id, ~spec, ()))
          insertChart({objects: objects})->ignore
        | Some(chartIds) =>
          let chartIds = chartIds->Set.Int.toArray->Some
          updateChart(({spec: spec, chartIds: chartIds}: UpdateChart.t_variables))->ignore
        }
      }
    )
    ->ignore
    None
  }, [specs])
  (updateChartResult, insertChartResult)
}

@react.component
let make = (~logs: jsonMap, ~specs: specs, ~metadata: jsonMap, ~runIds, ~client, ~granularity) => {
  let reverse = specs =>
    specs->Map.Int.reduce(
      Map.make(~id=module(JsonComparator))->Map.set(
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

  let initialSpecs = specs
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
        ->Option.getWithDefault({rendering: true, ids: None, order: specs->Map.size, dirty: true})
      specs->Map.set(spec, {...specState, rendering: true})
    }
  , specs->reverse)

  React.useEffect1(() => {
    dispatch(Set(initialSpecs))
    None
  }, [initialSpecs])

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
          let logs = {old: logs, new: new}
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
      ->Array.mapWithIndex((i, m) =>
        <pre key={i->Int.toString} className="p-4"> {m->Util.yaml->React.string} </pre>
      )
      ->React.array}
    </>
  }
}
