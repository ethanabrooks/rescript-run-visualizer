open Belt
open Util

module Subscription = %graphql(`
  subscription subscription($condition: run_bool_exp!) {
    run(where: $condition) {
      id
      metadata
      run_logs {
        id
        log
      }
      charts(where: {archived: {_eq: false}}) {
        id
        spec
        archived
      }
    }
  }
`)

@val external max_logs: string = "NODE_MAX_LOGS"

type queryResult = {
  metadata: Map.Int.t<Js.Json.t>,
  specs: specs,
  logs: jsonMap,
  runIds: Set.Int.t,
}

type state = NoData | Waiting | Error(ApolloClient__Errors_ApolloError.t) | Data(queryResult)

@react.component
let make = (~condition1, ~condition2, ~client: ApolloClient__Core_ApolloClient.t) => {
  let (state, setState) = React.useState(() => Waiting)

  React.useEffect3(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    let onError = error => setState(_ => error->Error)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} => error->onError
      | {data: {run}} =>
        {
          // combine values from multiple runs returned from query
          let newState =
            run
            ->Array.reduce((None: option<queryResult>), (acc, {metadata, charts, run_logs, id}) => {
              // collect possibly multiple metadata into array
              let metadataMap =
                metadata->Option.mapWithDefault(Map.Int.empty, Map.Int.empty->Map.Int.set(id))

              // combine multiple charts from run
              let specs: specs = charts->Array.map(({id, spec}) => (id, spec))->Map.Int.fromArray

              // combine multiple logs from run
              let logs =
                run_logs
                ->Array.map(({id, log}) => (id, log))
                ->Map.Int.fromArray
                // add metadata to each log
                ->Map.Int.map(log =>
                  metadata->Option.mapWithDefault(log, log->Subscribe2.addParametersToLog)
                )

              let runIds = Set.Int.empty->Set.Int.add(id)
              // combine values from this run with values from previous runs
              acc
              ->Option.mapWithDefault(
                {metadata: metadataMap, specs: specs, logs: logs, runIds: runIds},
                ({metadata: m, specs: s, logs: l, runIds: r}) => {
                  let metadata = m->Map.Int.merge(metadataMap, merge)
                  let specs = s->Map.Int.merge(specs, merge)
                  let logs = l->Map.Int.merge(logs, merge)
                  let runIds = r->Set.Int.union(runIds)
                  {metadata: metadata, specs: specs, logs: logs, runIds: runIds}
                },
              )
              ->Some
            })
            ->Option.mapWithDefault(NoData, data => Data(data))
          setState(_ => newState)
        }

        unsubscribe()
      }
    }

    subscription :=
      client.subscribe(~subscription=module(Subscription), {condition: condition1}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(unsubscribe)
  }, (client, condition1, setState))

  switch state {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | NoData => <p> {"No data."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logs, specs, metadata, runIds}) => <Charts logs specs metadata runIds client condition2 />
  }
}
