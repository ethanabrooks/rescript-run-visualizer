open Belt
module InsertChart = %graphql(`
    mutation insertChart($objects: [chart_insert_input!]!) {
        insert_chart(objects: $objects) {
            returning {
              id
              spec
            }
        }
    }
`)

@react.component
let make = (
  ~insertChartResult: ApolloClient__React_Types.MutationResult.t<InsertChart.InsertChart_inner.t>,
  ~newSpec: option<Js.Json.t>,
) => {
  switch insertChartResult {
  | {loading: true} => <LoadingPage />
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({insert_chart: Some({returning})})} =>
    newSpec
    ->Option.flatMap(newSpec =>
      returning->Array.reduce((None: option<React.element>), (elt, {spec}) =>
        switch (elt, spec == newSpec) {
        | (Some(elt), _) => Some(elt)
        | (None, true) => None
        | (None, false) =>
          <ErrorPage
            message={`Specs do not match:\n${spec->Js.Json.stringifyWithSpace(
                2,
              )}}\n${newSpec->Js.Json.stringifyWithSpace(2)}`}
          />->Some
        }
      )
    )
    ->Option.getWithDefault(
      <p> {`Inserted ${returning->Array.length->Int.toString} new charts.`->React.string} </p>,
    )
  | _ => <> </>
  }
}
