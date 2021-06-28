open Belt

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
  let (updateChart, updateChartResult) = UpdateChart.use()
  let (insertChart, insertChartResult) = InsertChart.use()
  let (errors, setErrors) = React.useState(_ => [])

  React.useEffect1(_ => {
    switch errors {
    | [] => ()
    | _ => Webapi.Dom.window |> Webapi.Dom.Window.alert(errors->Js.Array2.joinWith("\n"))
    }
    Some(_ => setErrors(_ => []))
  }, [errors])

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
      | None =>
        parseResult->Result.mapWithDefault((), spec => {
          let objects: array<InsertChart.t_variables_chart_insert_input> =
            runIds
            ->Set.Int.toArray
            ->Array.map(run_id => InsertChart.makeInputObjectchart_insert_input(~run_id, ~spec, ()))
          insertChart({objects: objects})->ignore
        })

      | Some(chartIds) =>
        let chartIds = chartIds->Set.Int.toArray->Some
        updateChart(({spec: spec, chartIds: chartIds}: UpdateChart.t_variables))->ignore
      }
    }
    let disabled = false
    <> <Button text onClick disabled /> </>
  }
}
