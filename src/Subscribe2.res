open Util
open Belt

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

let addParametersToLog = (log, metadata) =>
  metadata
  ->jsonToMap
  ->Option.flatMap(o => o->Map.String.get("parameters")) // To Do: do not hard-code this somehow
  ->Option.flatMap(jsonToMap)
  ->Option.flatMap(parameters =>
    log->jsonToMap->Option.map(logMap => parameters->Map.String.merge(logMap, merge)->mapToJson)
  )
  ->Option.getWithDefault(log)

@react.component
let make = (
  ~logs: jsonMap,
  ~condition2,
  ~client: ApolloClient__Core_ApolloClient.t,
  ~metadata: jsonMap,
  ~makeCharts: (~logs: jsonMap, ~newLogs: jsonMap) => React.element,
) => {
  let (currentAndNewLogs, setCurrentAndNewLogs) = React.useState(_ => Result.Ok((
    logs,
    Map.Int.empty,
  )))

  React.useEffect2(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    let onError = error => setCurrentAndNewLogs(_ => error->Result.Error)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} =>
        unsubscribe()
        error->onError
      | {data} =>
        ()
        setCurrentAndNewLogs(logs =>
          logs->Result.mapWithDefault(logs, ((oldLogs, _)) => {
            let newLogs =
              data.run_log
              ->Array.map(({id, log}) => (id, log))
              ->Array.keep(((id, _)) => !(oldLogs->Map.Int.has(id)))
              ->Map.Int.fromArray
              ->Map.Int.mapWithKey((runId, log) =>
                metadata
                ->Map.Int.get(runId)
                ->Option.map(log->addParametersToLog)
                ->Option.getWithDefault(log)
              )
            let oldLogs = oldLogs->Map.Int.merge(newLogs, Util.merge)
            Result.Ok((oldLogs, newLogs))
          })
        )
      }
    }

    let archived = Subscription.makeInputObjectBoolean_comparison_exp(~_eq=false, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~archived, ())
    let notArchived = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(
      ~_and=[condition2, notArchived],
      (),
    )
    subscription :=
      client.subscribe(~subscription=module(Subscription), {condition: condition}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(unsubscribe)
  }, (client, condition2))

  switch currentAndNewLogs {
  | Error({message}) => <ErrorPage message />
  | Ok((_, newLogs)) => makeCharts(~logs, ~newLogs)
  }
}
