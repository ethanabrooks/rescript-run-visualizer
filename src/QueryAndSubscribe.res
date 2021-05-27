open Belt

module Query = %graphql(`
  query run($condition: run_log_bool_exp!) {
    run(where: $condition) {
      metadata
      charts {
        spec
      }
    }
  }
`)

module Subscription = %graphql(`
  subscription logs($condition: run_log_bool_exp!) {
    run_log(where: $condition) {
      id
      log
    }
  }
`)

let useAccumulator = () => {
  let (state, setState) = React.useState(() => None->Result.Ok)
  let onError = error => setState(_ => error->Result.Error)
  let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) =>
    switch (value, state) {
    | ({error: Some(error)}, _) => error->onError
    | ({data}, Result.Ok(old)) =>
      setState(_ =>
        data.run_log
        ->Array.map(({id, log}): (int, Js.Json.t) => (id, log))
        ->Array.reduce(old, (old, new) =>
          old->Option.mapWithDefault(list{new}, old => list{new, ...old})->Some
        )
        ->Result.Ok
      )
    | _ => ()
    }
  (state, onNext, onError)
}

@react.component
let make = (
  ~subscriptionVariables: Subscription.t_variables,
  ~queryVariables: Query.t_variables,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (logs, onNext, onError) = useAccumulator()

  client.subscribe(~subscription=module(Subscription), subscriptionVariables).subscribe(
    ~onNext,
    ~onError,
    (),
  )->ignore

  switch Query.use(queryVariables) {
  | {data: runs} => {
      let runs = runs->Option.map(({run}) =>
        run->Array.map(({charts, metadata}): Data.queryResult => {
          specs: charts->Array.map(({spec}) => spec),
          metadata: metadata,
        })
      )

      let state = switch (logs, runs) {
      | (Ok(Some(logs)), Some(runs)) =>
        runs
        ->Array.reduce(None, (aggregated, {metadata, specs}): option<(
          array<Js.Json.t>,
          Data.jsonSet,
        )> => {
          // metadata // specs
          let specs: Data.jsonSet = specs->Set.fromArray(~id=module(Data.JsonComparator))
          let metadata = metadata->Option.mapWithDefault([], m => [m])
          aggregated
          ->Option.mapWithDefault((metadata, specs), ((m, s)) => {
            let m = metadata->Array.concat(m)
            let s = specs->Set.union(s)
            (m, s)
          })
          ->Some
        })
        ->Option.mapWithDefault(Data.NoMatch, ((metadata, specs)) => {
          let metadata = switch metadata {
          | [] => None
          | [metadata] => metadata->Some
          | metadata => metadata->Js.Json.array->Some
          }
          Data({specs: specs, logs: logs, metadata: metadata})
        })
      | (Ok(None), _)
      | (_, None) =>
        Loading
      | (Error({message}), _) => Error(message)
      }
      <Charts state />
    }
  }
}
