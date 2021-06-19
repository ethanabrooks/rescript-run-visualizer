open Belt
module Subscription = %graphql(`
subscription {
    run {
        id
        metadata
    }
}
`)

@react.component
let make = (~client, ~ids) => {
  let {loading, error, data} = Subscription.use()
  let error = error->Option.map(({message}) => message)
  let data =
    data->Option.map(({run}) =>
      run->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})
    )
  let queryResult: ListAndDisplay.queryResult = {loading: loading, error: error, data: data}
  let display = <RunsDisplay ids client />
  <ListAndDisplay queryResult ids display />
}
