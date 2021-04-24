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
    let (state, setState) = React.useState(() => Loading)
    let initialState = Source.initial()

    let subscriptionState = Source.subscription(
      switch initialState {
      | Data(data) => Some(data)
      | _ => None
      },
    )

    React.useEffect2(() => {
      setState(_ =>
        switch (state, initialState, subscriptionState) {
        | (Loading, Loading, _) => Loading // waiting on initial data
        | (Loading, Data(data), _) // received initial data
        | (Data(data), _, Loading) =>
          // waiting on subscriptiion data
          data->Data
        | (Data(data), _, Data(newData)) => data->Source.update(newData)->Data // received subscription data
        | (Error(e), _, _)
        | (_, Error(e), _)
        | (_, _, Error(e)) =>
          Error(e)
        }
      )
      None
    }, (initialState, subscriptionState))
    state
  }
}
