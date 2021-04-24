type state<'a> =
  | Loading
  | Error(string)
  | Data('a)

module type Source = {
  type data
  type subscriptionData
  let initial: unit => state<data>
  let subscription: option<data> => state<subscriptionData>
  let update: (data, subscriptionData) => data
}

module Stream = (Source: Source) => {
  let useData = () => {
    let (state: state<Source.data>, setState) = React.useState(() => Loading)
    let (count, setCount) = React.useState(() => 0)
    let initialState = Source.initial()

    let subscriptionState = Source.subscription(
      switch initialState {
      | Data(data) => Some(data)
      | _ => None
      },
    )

    React.useEffect2(() => {
      Js.log2("count", count->Belt.Int.toString)
      setCount(_ => count + 1)
      switch (state, initialState, subscriptionState) {
      | (_, Error(e), _)
      | (_, _, Error(e)) =>
        setState(_ => Error(e))
      | (Error(_), _, _)
      | (Loading, Loading, _)
      | (Data(_), _, Loading) => () // waiting on subscriptiion data
      | (Loading, Data(data), _) => setState(_ => data->Data) // received initial data
      | (Data(data), _, Data(newData)) => setState(_ => data->Source.update(newData)->Data) // received subscription data
      }
      None
    }, (initialState, subscriptionState))
    state
  }
}
