// open Belt
// open Util

// module InsertChart = %graphql(`
//     mutation insertChart($objects: [chart_insert_input!]!) {
//         insert_chart(objects: $objects) {
//             returning {
//               id
//             }
//         }
//     }
// `)

// let useInsertChart = (~specs, ~runIds): mutationResult<array<int>> => {
//   let (insertChart, insertChartResult) = InsertChart.use()

//   let insertChartStatus = switch insertChartResult {
//   | {loading: true} => Loading
//   | {error: Some({message})} => Error(message)
//   | {data: None, error: None, loading: false} => NotCalled
//   | {data: Some({insert_chart})} =>
//     Data(
//       insert_chart
//       ->Option.map(({returning}) => returning->Array.map(({id}) => id))
//       ->Option.getWithDefault([]),
//     )
//   }
//   insertChartStatus
// }

