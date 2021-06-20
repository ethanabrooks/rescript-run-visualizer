open Util
open Belt

module InsertChart = %graphql(`
  mutation insert_chart($objects: [chart_insert_input!]!) {
    insert_chart(objects: $objects, on_conflict: {update_columns: [id], constraint: chart_pkey}) {
      affected_rows
    }
  }
`)

type runOrSweepIds = Sweep(Set.Int.t) | Run(Set.Int.t)
let setToList = set => set->Set.Int.toArray->List.fromArray

@react.component
let make = (
  ~parseResult: parseResult,
  ~onClick: list<unit => unit>,
  ~chartIds: Set.Int.t,
  ~runOrSweepIds: runOrSweepIds,
) => {
  let (
    insertChart,
    inserted: ApolloClient__React_Types.MutationResult.t<InsertChart.t>,
  ) = InsertChart.use()
  let disabled = parseResult->Result.isError
  let onClick = _ =>
    parseResult->Result.mapWithDefault((), spec => {
      onClick->List.forEach(callback => callback())
      let objects =
        switch runOrSweepIds {
        | Sweep(sweepOrRunIds)
        | Run(sweepOrRunIds) =>
          sweepOrRunIds
          ->setToList
          ->List.map((sweepOrRunId): list<InsertChart.t_variables_chart_insert_input> => {
            let chartIds = chartIds->setToList
            let chartIds: list<option<int>> =
              chartIds->Js.List.isEmpty ? list{None} : chartIds->List.map(x => x->Some)
            chartIds->List.map((chartId): InsertChart.t_variables_chart_insert_input => {
              id: chartId,
              run: None,
              sweep: None,
              spec: spec->Some,
              run_id: switch runOrSweepIds {
              | Run(_) => sweepOrRunId->Some
              | _ => None
              },
              sweep_id: switch runOrSweepIds {
              | Sweep(_) => sweepOrRunId->Some
              | _ => None
              },
            })
          })
        }
        ->List.flatten
        ->List.toArray
      insertChart({objects: objects})->ignore
    })

  switch inserted {
  | {called: false} => <Button text={"Submit"} onClick disabled />
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({insert_chart: Some(_)})} => <p> {"Inserted chart."->React.string} </p>
  | {error: None} => <p> {"Deleting..."->React.string} </p>
  }
}
