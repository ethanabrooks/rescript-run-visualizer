open Util

module InsertChart = %graphql(`
  mutation insert_chart($objects: [chart_insert_input!]!) {
    insert_chart(objects: $objects, on_conflict: {update_columns: [id], constraint: chart_pkey}) {
      affected_rows
    }
  }
`)

@react.component
let make = (~disabled, ~onClick) => {
  let (
    insertChart,
    inserted: ApolloClient__React_Types.MutationResult.t<InsertChart.t>,
  ) = InsertChart.use()

  switch inserted {
  | {called: false} =>
    <Button
      text={"Submit"}
      onClick={_ =>
        onClick(objects => insertChart(({objects: objects}: InsertChart.t_variables))->ignore)}
      disabled
    />
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({insert_chart: Some(_)})} => <p> {"Inserted chart."->React.string} </p>
  | {error: None} => <p> {"Deleting..."->React.string} </p>
  }
}
