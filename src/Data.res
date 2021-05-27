open Belt

@decco
type runId = int

@decco
type logId = int

type logEntry = (int, Js.Json.t)

type subscriptionData = list<logEntry>

let encodeLog = (log: Js.Json.t, ~runId: int, ~logId: int) =>
  switch log->Js.Json.decodeObject {
  | None => Decco.error("Unable to decode as object", log)
  | Some(dict) => {
      dict->Js.Dict.set("runId", runId->runId_encode)
      dict->Js.Dict.set("logId", logId->logId_encode)
      (logId, dict->Js.Json.object_)->Result.Ok
    }
  }

module JsonComparator = Belt.Id.MakeComparable({
  type t = Js.Json.t
  let cmp = Pervasives.compare
})

type jsonSet = Set.t<Js.Json.t, JsonComparator.identity>

type t = list<(int, Js.Json.t)>

type state =
  | NoMatch
  | Loading
  | Error(string)
  | Data({logs: t, specs: jsonSet, metadata: option<Js.Json.t>})

let useAccumulator = (~convertData: 'a => array<(int, Js.Json.t)>) => {
  let (state, setState) = React.useState(() => None->Result.Ok)
  let onError = error => setState(_ => error->Result.Error)
  let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<'a>) =>
    switch (value, state) {
    | ({error: Some(error)}, _) => error->onError
    | ({data}, Result.Ok(old)) =>
      setState(_ =>
        data
        ->convertData
        ->Array.reduce(old, (old, new) =>
          old->Option.mapWithDefault(list{new}, old => list{new, ...old})->Some
        )
        ->Result.Ok
      )
    | _ => ()
    }
  (state, onNext, onError)
}
type queryResult = {metadata: option<Js.Json.t>, specs: array<Js.Json.t>}

let getState = (
  ~logs: Result.t<option<t>, ApolloClient__Errors_ApolloError.t>,
  ~runs: option<array<queryResult>>,
) =>
  switch (logs, runs) {
  | (Ok(Some(logs)), Some(runs)) =>
    runs
    ->Array.reduce(None, (aggregated, {metadata, specs}): option<(array<Js.Json.t>, jsonSet)> => {
      // metadata // specs
      let specs: jsonSet = specs->Set.fromArray(~id=module(JsonComparator))
      let metadata = metadata->Option.mapWithDefault([], m => [m])
      aggregated
      ->Option.mapWithDefault((metadata, specs), ((m, s)) => {
        let m = metadata->Array.concat(m)
        let s = specs->Set.union(s)
        (m, s)
      })
      ->Some
    })
    ->Option.mapWithDefault(NoMatch, ((metadata, specs)) => {
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
