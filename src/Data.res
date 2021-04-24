type state<'a> =
  | Loading
  | Error(string)
  | Hanging
  | Data('a)

module type Source = {
  type data
  type subscriptionData
  let initial: unit => state<data>
  let subscription: data => state<subscriptionData>
  let update: (data, subscriptionData) => data
}

module Stream = (Source: Source) => {
  let getData = (queryResult: state<Source.data>): state<Source.data> => {
    switch queryResult {
    | Loading => Source.initial()
    | Data(data) =>
      switch Source.subscription(data) {
      | Data(subscriptionData) => data->Source.update(subscriptionData)->Data
      | Loading => Loading
      | Hanging => Hanging
      | Error(e) => Error(e)
      }
    | state => state
    }
  }
  let useData = () => {
    let (state, setState) = React.useState(() => Loading)
    React.useEffect1(() => {
      setState(_ => getData(state))
      None
    }, [state])
    state
  }
}
