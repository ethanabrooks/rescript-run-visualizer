open Belt

module SweepQuery = %graphql(`
query logs($sweepId: Int!) {
  sweep(where: {id: {_eq: $sweepId}}) {
    metadata
    runs {
      id
      run_logs {
        id
        log
      }
    }
    charts {
      spec
    }
  }
}
`)

module LogSubscription = %graphql(`
subscription logs($sweepId: Int!, $minLogId: Int!) {
  run_log(where: {run: {sweep_id: {_eq: $sweepId}}, id: {_gt: $minLogId}}, limit: 1) {
    id
    log
    run_id
  }
}
`)

@react.component
let make = (~sweepId: int, ~client: ApolloClient__Core_ApolloClient.t) => {
  <> </>
  // <Display
  //   state={switch DisplayCharts.useData() {
  //   | Data({specs, logs, metadata}) => Data({specs: specs, logs: logs, metadata: metadata})
  //   | Loading => Loading
  //   | Error(e) => Error(e)
  //   }}
  // />
}
