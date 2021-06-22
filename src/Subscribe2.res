open Belt
open Util

module Subscription = %graphql(`
  subscription logs($condition: run_log_bool_exp!) {
    run_log(where: $condition, limit: 1, order_by: [{id: desc}]) {
      id
      log
    }
  }
`)

module ErrorPage = {
  @react.component
  let make = (~message: string) => <p> {message->React.string} </p>
}

@react.component
let make = (
  ~logs: jsonMap,
  ~condition2,
  ~client: ApolloClient__Core_ApolloClient.t,
  ~makeCharts: (~logs: jsonMap) => React.element,
) => {
  let (logs, setLogs) = React.useState(() => logs->Result.Ok)

  React.useEffect3(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)

    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    let onError = error => setLogs(_ => error->Result.Error)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} =>
        unsubscribe()
        error->onError
      | {data} => {
          let new = data.run_log->Array.map(({id, log}) => (id, log))->Map.Int.fromArray
          let merge = old => old->Map.Int.merge(new, Util.merge)
          setLogs(old => old->Result.map(merge))
        }
      }
    }
    subscription :=
      client.subscribe(~subscription=module(Subscription), {condition: condition2}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(unsubscribe)
  }, (client, condition2, setLogs))

  switch logs {
  | Error({message}) => <ErrorPage message />
  | Ok(logs) => makeCharts(~logs)
  }
}
