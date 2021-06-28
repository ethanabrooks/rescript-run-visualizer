open Belt
module MaxChartId = %graphql(`
    query maxChartId {
        chart(limit: 1, order_by: [{id: desc}]) {
            id
        }
    }
`)

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

@react.component
let make = (~chartIds, ~runIds, ~onClick, ~parseResult) => {
  let (getMaxId, maxIdResult) = MaxChartId.useLazy()
  let (updateChart, updateChartResult) = UpdateChart.use()
  let (insertChart, insertChartResult) = InsertChart.use()
  let (errors, setErrors) = React.useState(_ => [])
  // TODO: use alert

  React.useEffect1(_ => {
    switch maxIdResult {
    | Executed({error: Some({message})}) => setErrors([message]->Array.concat)
    | Executed({data: Some({chart: ids})}) =>
      switch ids {
      | [{id}] =>
        parseResult->Result.mapWithDefault((), spec => {
          let objects: array<InsertChart.t_variables_chart_insert_input> =
            runIds
            ->Set.Int.toArray
            ->Array.map(run_id =>
              InsertChart.makeInputObjectchart_insert_input(~run_id, ~spec, ~id=id + 1, ())
            )
          insertChart({objects: objects})->ignore
        })
      | _ => Js.Exn.raiseError("Unexpected return value from maxIdResult")
      }
    | _ => ()
    }
    None
  }, [maxIdResult])
  React.useEffect1(_ => {
    switch updateChartResult {
    | {error: Some({message})} => setErrors([message]->Array.concat)
    | _ => ()
    }
    None
  }, [updateChartResult])

  React.useEffect1(_ => {
    switch insertChartResult {
    | {error: Some({message})} => setErrors([message]->Array.concat)
    | _ => ()
    }
    None
  }, [insertChartResult])

  let text = "Submit"
  switch parseResult {
  | Error(_) =>
    let onClick = _ => ()
    let disabled = true
    <Button text onClick disabled />

  | Ok(spec) =>
    let onClick = _ => {
      spec->onClick
      switch chartIds {
      | None => getMaxId()
      | Some(chartIds) =>
        let chartIds = chartIds->Set.Int.toArray->Some
        updateChart(({spec: spec, chartIds: chartIds}: UpdateChart.t_variables))->ignore
      }
    }
    let disabled = false
    <>
      <Button text onClick disabled />
      {errors->Array.map(message => <ErrorPage message />)->React.array}
    </>
  }
}
