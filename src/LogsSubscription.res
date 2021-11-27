open Util
open Belt

module Subscription = %graphql(`
  subscription logs($condition: run_log_bool_exp!) {
    run_log(where: $condition, limit: 1, order_by: [{id: desc}]) {
      id
      log
      run {
        id
      }
    }
  }
`)

let addParametersToLog = (log, metadata) =>
  metadata
  ->jsonToMap
  ->Option.flatMap(o => o->Map.String.get("parameters")) // To Do: do not hard-code this somehow
  ->Option.flatMap(jsonToMap)
  ->Option.flatMap(parameters =>
    log->jsonToMap->Option.map(logMap => parameters->Map.String.merge(logMap, merge)->mapToJson)
  )
  ->Option.getWithDefault(log)

let useLogs = (
  ~logs: jsonMap,
  ~client: ApolloClient__Core_ApolloClient.t,
  ~metadata: jsonMap,
  ~runIds,
  ~granularity,
) => {
  let (currentAndNewLogs, setCurrentAndNewLogs) = React.useState(_ =>
    {
      old: logs,
      new: Map.Int.empty,
    }->Ok
  )

  React.useEffect2(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    let onError = error => setCurrentAndNewLogs(_ => error->Error)

    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} =>
        unsubscribe()
        error->onError
      | {data} =>
        setCurrentAndNewLogs(logs =>
          logs->Result.mapWithDefault(logs, ({old}) => {
            let new =
              data.run_log
              ->Array.keep(({id}) => !(old->Map.Int.has(id)))
              ->Array.map(({id, log, run}) => {
                let log =
                  metadata
                  ->Map.Int.get(run.id)
                  ->Option.map(log->addParametersToLog)
                  ->Option.getWithDefault(log)
                (id, log)
              })
              ->Map.Int.fromArray
            let old = old->Map.Int.merge(new, Util.merge)
            Ok({old: old, new: new})
          })
        )
      }
    }

    let ids = runIds->Set.Int.toArray
    let id = Subscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    // Js.log(condition->Subscription.serializeInputObjectrun_log_bool_exp)
    // Js.log(runIds)

    let archived = Subscription.makeInputObjectBoolean_comparison_exp(~_eq=false, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~archived, ())
    let notArchived = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~_and=[condition, notArchived], ())
    subscription :=
      client.subscribe(~subscription=module(Subscription), {condition: condition}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(_ => unsubscribe())
  }, (runIds, granularity))

  currentAndNewLogs
}
