@react.component
let make = (~client, ~granularity, ~ids) => {
  let subscriptionState = Subscribe1.useSubscription(~client, ~granularity, ~ids)

  switch subscriptionState {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logs, specs, metadata, runIds}) =>
    <Charts logs specs metadata runIds client granularity />
  }
}
