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

type t = {
  specs: Set.t<Js.Json.t, JsonComparator.identity>,
  metadata: option<Js.Json.t>,
  logs: list<(int, Js.Json.t)>,
}

let merge = (oldData: option<t>, newData: t) =>
  oldData
  ->Option.mapWithDefault(newData, oldData => {
    specs: oldData.specs,
    metadata: oldData.metadata,
    logs: oldData.logs->List.concat(newData.logs),
  })
  ->Some

type state =
  | Loading
  | Error(string)
  | Data(t)

let useAccumulator = (~convertToData: 'a => array<t>) => {
  let (state, setState) = React.useState(() => None->Result.Ok)
  let onError = error => setState(_ => error->Result.Error)
  let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<'a>) =>
    switch (value, state) {
    | ({error: Some(error)}, _) => error->onError
    | ({data}, Result.Ok(oldData)) =>
      setState(_ => data->convertToData->Array.reduce(oldData, merge)->Result.Ok)
    | _ => ()
    }
  (state, onNext, onError)
}
