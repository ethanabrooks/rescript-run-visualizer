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
  ~specs: jsonSet,
  ~metadata: array<Js.Json.t>,
  ~variables2: Subscription.t_variables,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (logs, setLogs) = React.useState(() => logs->Result.Ok)

  React.useEffect0(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let onError = error => setLogs(_ => error->Result.Error)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} =>
        (subscription.contents->Option.getExn).unsubscribe()->ignore
        error->onError
      | {data} => {
          let new = data.run_log->Array.map(({id, log}) => (id, log))->Map.Int.fromArray
          let merge = old => old->Map.Int.merge(new, Util.merge)
          setLogs(old => old->Result.map(merge))
        }
      }
    }
    subscription :=
      client.subscribe(~subscription=module(Subscription), variables2).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    None
  })

  switch logs {
  | Error({message}) => <ErrorPage message />
  | Ok(logs) => <Charts logs metadata specs />
  }
}
