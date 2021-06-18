open Belt
open Subscribe2
open Util

module Subscription = %graphql(`
  query subscription($condition: run_bool_exp!) {
    run(where: $condition) {
      metadata
      run_logs {
        id
        log
      }
      charts {
        spec
      }
      sweep {
        charts {
          spec
        }
      }
    }
  }
`)

module Deletion = %graphql(`
  mutation deletion($condition: run_bool_exp!) {
    delete_run(where: $condition) {
      affected_rows
    }
}`)

@val external max_logs: string = "NODE_MAX_LOGS"

let objToMap = (obj: Js.Json.t) =>
  obj->Js.Json.decodeObject->Option.map(obj => obj->Js.Dict.entries->Map.String.fromArray)
let mapToObj = (map: Map.String.t<'a>) =>
  map->Map.String.toArray->Js.Dict.fromArray->Js.Json.object_

type queryResult = {
  metadata: array<Js.Json.t>,
  specs: jsonSet,
  logs: jsonMap,
}

type state = Waiting | Error(ApolloClient__Errors_ApolloError.t) | Data(queryResult)

@react.component
let make = (
  ~variables1: Subscription.t_variables,
  ~variables2,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (state, setState) = React.useState(() => Waiting)

  React.useEffect0(() => {
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let onError = error => setState(_ => error->Error)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) =>
      switch value {
      | {error: Some(error)} => error->onError
      | {data: {run}} =>
        {
          // combine values from multiple runs returned from query
          let newState =
            run
            ->Array.reduce((None: option<queryResult>), (
              acc,
              {metadata, charts, run_logs, sweep},
            ) => {
              let metadataMap = metadata->Option.flatMap(objToMap)

              // collect possibly multiple metadata into array
              let metadata = metadata->Option.mapWithDefault([], m => [m])

              // combine multiple charts from run
              let specs =
                sweep
                ->Option.mapWithDefault([], ({charts}) => charts->Array.map(({spec}) => spec))
                ->Array.concat(charts->Array.map(({spec}) => spec))
                ->Set.fromArray(~id=module(JsonComparator))

              // combine multiple logs from run
              let logs =
                run_logs
                ->Array.map(({id, log}) => (id, log))
                ->Map.Int.fromArray
                // add metadata to each log
                ->Map.Int.map(log =>
                  switch (metadataMap, log->objToMap) {
                  | (Some(metadataMap), Some(logMap)) =>
                    metadataMap->Map.String.merge(logMap, merge)->mapToObj
                  | _ => log
                  }
                )

              // combine values from this run with values from previous runs
              acc
              ->Option.mapWithDefault({metadata: metadata, specs: specs, logs: logs}, ({
                metadata: m,
                specs: s,
                logs: l,
              }) => {
                let metadata: array<Js.Json.t> = m->Array.concat(metadata)
                let specs = s->Set.union(specs)
                let logs = l->Map.Int.merge(logs, merge)
                {metadata: metadata, specs: specs, logs: logs}
              })
              ->Some
            })
            ->Option.mapWithDefault(Waiting, data => Data(data))
          setState(_ => newState)
        }

        (subscription.contents->Option.getExn).unsubscribe()->ignore
      }

    subscription :=
      client.subscribe(~subscription=module(Subscription), variables1).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    None
  })

  switch state {
  | Waiting => <p> {"Waiting for data..."->React.string} </p>
  | Error({message}) => <ErrorPage message />
  | Data({logs, specs, metadata}) => <Subscribe2 logs specs metadata variables2 client />
  }
}
