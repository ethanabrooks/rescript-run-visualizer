@react.component
let make = (~client, ~granularity, ~ids) =>
  switch RunsSubscription.useSubscription(~client, ~granularity, ~ids) {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logs, specs, metadata, runIds}) =>
    <Charts logs specs metadata runIds client granularity />
  }
