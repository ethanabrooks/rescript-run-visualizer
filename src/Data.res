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
    let (state: state<Source.data>, setState) = React.useState(() => Loading)
    let initialState = Source.initial()

    let addData = (newData: Source.subscriptionData) => {
      switch state {
      | Data(data) => setState(_ => data->Source.update(newData)->Data)
      | _ => ()
      }
    }
    let setError = (message: string) => setState(_ => message->Error)

    React.useEffect2(() => {
      switch initialState {
      | Data(data) => Source.subscribe(~currentData=data, ~addData, ~setError)->Some
      | _ => None
      }->Option.map((subscription, ()) => subscription.unsubscribe())
    }, (setState, initialState))
    state
  }
}
