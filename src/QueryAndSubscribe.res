open Belt

module Query = %graphql(`
  query run($condition: run_bool_exp!) {
    run(where: $condition) {
      metadata
      run_logs {
        id
        log
      }
      charts {
        spec
      }
    }
  }
`)

module Subscription = %graphql(`
  subscription logs($condition: run_log_bool_exp!) {
    run_log(where: $condition, limit: 1, order_by: [{id: desc}]) {
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
    | ({data}, Result.Ok(old)) => {
        let new = data.run_log->Array.map(({id, log}) => (id, log))
        setLogs(_ => old->Option.mapWithDefault(new, new->Array.concat)->Some->Result.Ok)
      }
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
        run->Array.map(({charts, metadata, run_logs}): Data.queryResult => {
          specs: charts->Array.map(({spec}) => spec),
          metadata: metadata,
          logs: run_logs
          ->Array.map(({log, id}) => (id, log))
          ->Set.fromArray(~id=module(Data.PairComparator)),
        })
      )

      switch (logs, runs) {
      | (Ok(Some(subscriptionLogs)), Some(runs)) => {
          open Data
          runs
          ->Array.reduce(None, (aggregated, {metadata, specs, logs}): option<(
            array<Js.Json.t>, // metadata
            jsonSet, // specs
            pairSet, // logs
          )> => {
            let specs: jsonSet = specs->Set.fromArray(~id=module(JsonComparator))
            let metadata = metadata->Option.mapWithDefault([], m => [m])
            aggregated
            ->Option.mapWithDefault((metadata, specs, logs), ((m, s, l)) => {
              let m = metadata->Array.concat(m)
              let s = specs->Set.union(s)
              let l = logs->Set.union(l)
              (m, s, l)
            })
            ->Some
          })
          ->Option.mapWithDefault(Data.NoMatch, ((metadata, specs, queryLogs)) => {
            let metadata = switch metadata {
            | [] => None
            | [metadata] => metadata->Some
            | metadata => metadata->Js.Json.array->Some
            }
            let subscriptionLogs = subscriptionLogs->Set.fromArray(~id=module(PairComparator))
            Data({
              specs: specs,
              logs: queryLogs->Set.union(subscriptionLogs),
              metadata: metadata,
            })
          })
        }
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
