open Belt
open Util

@val external maxLogs: string = "NODE_MAX_LOGS"

module Subscription = %graphql(`
  subscription InitialSubscription($condition: run_bool_exp!) {
  run(where: $condition) {
    id
    metadata
    charts {
      id
      spec
      archived
    }
    run_logs_aggregate {
      aggregate {
        count
      }
    }
  }
}
`)

type queryResult = {
  metadata: Map.Int.t<Js.Json.t>,
  specs: Map.Int.t<Js.Json.t>,
  logCount: int,
  runIds: Set.Int.t,
}

type state = NoData | Waiting | Error(ApolloClient__Errors_ApolloError.t) | Data(queryResult)

let useSubscription = (~client: ApolloClient__Core_ApolloClient.t, ~ids, ~granularity) => {
  let (state, setState) = React.useState(() => Waiting)

  React.useEffect2(() => {
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
            ->Array.reduce((None: option<queryResult>), (
              acc,
              {metadata, charts, run_logs_aggregate: {aggregate: count}, id},
            ) => {
              // collect possibly multiple metadata into array
              let metadataMap =
                metadata->Option.mapWithDefault(Map.Int.empty, Map.Int.empty->Map.Int.set(id))

              // combine multiple charts from run
              let specs: Map.Int.t<Js.Json.t> =
                charts
                ->Array.keep(({archived}) => !archived)
                ->Array.map(({id, spec}) => (id, spec))
                ->Map.Int.fromArray

              let logCount = count->Option.mapWithDefault(0, ({count}) => count)

              let runIds = Set.Int.empty->Set.Int.add(id)

              // combine values from this run with values from previous runs
              acc
              ->Option.mapWithDefault(
                {metadata: metadataMap, specs: specs, logCount: logCount, runIds: runIds},
                ({metadata: m, specs: s, logCount: l, runIds: r}) => {
                  let metadata = m->Map.Int.merge(metadataMap, merge)
                  let specs = s->Map.Int.merge(specs, merge)
                  let logCount = l + logCount
                  let runIds = r->Set.Int.union(runIds)
                  {metadata: metadata, specs: specs, logCount: logCount, runIds: runIds}
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

    let condition = {
      open Routes
      let ids = ids->Set.Int.toArray
      switch granularity {
      | Run =>
        let id = Subscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
        Subscription.makeInputObjectrun_bool_exp(~id, ())
      | Sweep =>
        let sweep_id = Subscription.makeInputObjectInt_comparison_exp(~_in=ids, ())
        Subscription.makeInputObjectrun_bool_exp(~sweep_id, ())
      }
    }

    subscription :=
      client.subscribe(~subscription=module(Subscription), {condition: condition}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(_ => unsubscribe())
  }, (ids, granularity))

  state
}
