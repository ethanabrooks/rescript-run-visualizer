open Belt
module UpdateChart = %graphql(`
  mutation update_chart($chartIds: [Int!], $spec: jsonb!) {
    update_chart(_set: {spec: $spec}, where: {id: {_in: $chartIds}}) {
      returning {
        id
      }
    }
  }
`)

@react.component
let make = (
  ~updateChartResult: ApolloClient__React_Types.MutationResult.t<UpdateChart.UpdateChart_inner.t>,
) => {
  switch updateChartResult {
  | {loading: true} => <LoadingPage />
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({update_chart: Some({returning})})} =>
    <p> {`Updated ${returning->Array.length->Int.toString} charts.`->React.string} </p>
  | _ => <> </>
  }
}
