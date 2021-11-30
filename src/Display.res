open Belt

module InsertChart = InsertChartStatus.InsertChart
module UpdateChart = UpdateChartStatus.UpdateChart

let reverse = (specs: Map.Int.t<Js.Json.t>): Map.t<
  Js.Json.t,
  Util.chartState,
  Util.JsonComparator.identity,
> =>
  specs->Map.Int.reduce(Map.make(~id=module(Util.JsonComparator)), (map, id, spec) => {
    let ids =
      map
      ->Map.get(spec)
      ->Option.map(({ids}: Util.chartState) => ids)
      ->Option.getWithDefault(Set.Int.empty)
    let ids = ids->Set.Int.add(id)
    let order = map->Map.size - 1
    map->Map.set(spec, {ids: ids, rendering: true, order: order, needsUpdate: false})
  })

@react.component
let make = (~client, ~granularity, ~checkedIds) => {
  module StatusesAndCharts = {
    @react.component
    let make = (~logCount: int, ~specs: Map.Int.t<Js.Json.t>, ~runIds) => {
      let (insertChart, insertChartResult) = InsertChart.use()
      let (updateChart, updateChartResult) = UpdateChart.use()

      let ((specs, newSpec), dispatch) = React.useReducer(
        ((specs, newSpec), action: Util.chartAction) =>
          switch action {
          | ToggleRender(spec) =>
            let {rendering, ids, order}: Util.chartState = specs->Map.getExn(spec)
            let specs =
              specs->Map.set(
                spec,
                {rendering: !rendering, ids: ids, order: order, needsUpdate: false},
              )
            (specs, newSpec)
          | Submit(spec) =>
            switch specs->Map.get(spec) {
            | None => (specs, spec->Some) // spec is not in specs, therefore new
            | Some(specState) =>
              let specs = specs->Map.set(spec, {...specState, rendering: true})
              (specs, newSpec)
            }
          | Insert(spec, ids) => (
              specs->Map.set(
                spec,
                (
                  {
                    rendering: true,
                    ids: ids,
                    order: specs->Map.size,
                    needsUpdate: false,
                  }: Util.chartState
                ),
              ),
              None,
            )
          | Remove(spec) => (specs->Map.remove(spec), None)
          },
        (specs->reverse, None),
      )

      // run insertChart mutation, inserting newSpec for each id in runIds
      React.useEffect1(_ => {
        newSpec
        ->Option.map(spec => {
          let objects: array<InsertChart.t_variables_chart_insert_input> =
            runIds
            ->Set.Int.toArray
            ->Array.map(run_id => InsertChart.makeInputObjectchart_insert_input(~run_id, ~spec, ()))
          insertChart({objects: objects})->ignore
        })
        ->ignore
        None
      }, [newSpec])

      // insert new chart into specs
      React.useEffect1(_ => {
        switch insertChartResult {
        | {data: Some({insert_chart: Some({returning})})} =>
          let ids = returning->Array.map(({id}) => id)->Set.Int.fromArray
          switch newSpec {
          | Some(newSpec) => dispatch(Insert(newSpec, ids))
          | _ => ()
          }
        | _ => ()
        }
        None
      }, [insertChartResult])

      // run updateChart mutation, updating each spec with needsUpdate: true
      React.useEffect1(_ => {
        specs
        ->Map.mapWithKey((spec, {needsUpdate, ids}: Util.chartState) =>
          if needsUpdate {
            let chartIds = ids->Set.Int.toArray->Some
            updateChart(({spec: spec, chartIds: chartIds}: UpdateChart.t_variables))->ignore
          }
        )
        ->ignore
        None
      }, [specs])

      <>
        <InsertChartStatus insertChartResult newSpec />
        <UpdateChartStatus updateChartResult />
        {switch LogsQuery.useLogs(~logCount, ~checkedIds) {
        | Error(message) => <ErrorPage message />
        | Loading => <LoadingPage />
        | Stuck => <ErrorPage message={"Stuck."} />
        | Data(logs) => <ChartsDisplay specs logs dispatch checkedIds client />
        }}
      </>
    }
  }

  switch InitialSubscription.useSubscription(~client, ~granularity, ~checkedIds) {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logCount, specs, metadata, runIds}) => <>
      <StatusesAndCharts logCount specs runIds />
      {metadata
      ->Map.Int.toArray
      ->Array.map(((id, metadata)) => <Metadata key={id->Int.toString} id metadata />)
      ->React.array}
    </>
  }
}
