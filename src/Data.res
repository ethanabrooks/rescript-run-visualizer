open Belt

type state<'a> =
  | Loading
  | Error(string)
  | Data('a)

module type Source = {
  type data
  type subscriptionData
  let initial: unit => state<data>
  let subscribe: (
    ~currentData: data,
    ~addData: subscriptionData => unit,
    ~setError: string => unit,
  ) => ApolloClient__ZenObservable.Subscription.t
  let update: (data, subscriptionData) => data
}

module Stream = (Source: Source) => {
  let useData = () => {
    let (state, setState) = React.useState(() => Loading)
    let initialState = Source.initial()

    let setError = (message: string) => setState(_ => message->Error)
    let addData = (newData: Source.subscriptionData) => {
      switch state {
      | Data(data) => setState(_ => data->Source.update(newData)->Data)
      | _ => ()
      }
    }

    React.useEffect3(() => {
      switch (state, initialState) {
      | (Loading, Data(data)) => {
          setState(_ => Data(data))
          Source.subscribe(~currentData=data, ~addData, ~setError)->Some
        }
      | _ => None
      }->Option.map((subscription, ()) => subscription.unsubscribe())
    }, (setState, state, initialState))
    state
  }
}

@decco
type runId = int

@decco
type logId = int

type logEntry = (int, Js.Json.t)

type subscriptionData = list<logEntry>
type data = {specs: list<Js.Json.t>, logs: subscriptionData}

let encodeLog = (log: Js.Json.t, ~runId: int, ~logId: int) =>
  switch log->Js.Json.decodeObject {
  | None => Decco.error("Unable to decode as object", log)
  | Some(dict) => {
      dict->Js.Dict.set("runId", runId->runId_encode)
      dict->Js.Dict.set("logId", logId->logId_encode)
      (logId, dict->Js.Json.object_)->Result.Ok
    }
  }
