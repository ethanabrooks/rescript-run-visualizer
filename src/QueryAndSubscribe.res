open Belt

module Query = %graphql(`
  query run($condition: run_bool_exp!) {
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

@react.component
let make = (
  ~subscriptionVariables: Subscription.t_variables,
  ~queryVariables: Query.t_variables,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (logs, setLogs) = React.useState(() => None->Result.Ok)
  let onError = error => setLogs(_ => error->Result.Error)
  let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) =>
    switch (value, logs) {
    | ({error: Some(error)}, _) => error->onError
    | ({data}, Result.Ok(_)) =>
      setLogs(_ => data.run_log->Array.map(({id, log}) => (id, log))->Some->Result.Ok)
    | _ => ()
    }

  client.subscribe(~subscription=module(Subscription), subscriptionVariables).subscribe(
    ~onNext,
    ~onError,
    (),
  )->ignore

  let state: Data.state = switch Query.use(queryVariables) {
  | {error: Some({message})} => Error(message)
  | {loading: true} => Loading
  | {data: runs} => {
      let runs = runs->Option.map(({run}) =>
        run->Array.map(({charts, metadata}): Data.queryResult => {
          specs: charts->Array.map(({spec}) => spec),
          metadata: metadata,
        })
      )

      switch (logs, runs) {
      | (Ok(Some(logs)), Some(runs)) =>
        runs
        ->Array.reduce(None, (aggregated, {metadata, specs}): option<(
          array<Js.Json.t>, // metadata
          Data.jsonSet, // specs
        )> => {
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
    }
  }

  switch state {
  | NoMatch => <p> {"No matching run found..."->React.string} </p>
  | Loading => <p> {"Loading..."->React.string} </p>
  | Error(e) => <p> {e->React.string} </p>
  | Data({logs, specs, metadata}) =>
    <Charts logs metadata specs={specs->Set.toArray->Array.reverse} />
  }
}
