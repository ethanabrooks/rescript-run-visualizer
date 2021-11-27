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
