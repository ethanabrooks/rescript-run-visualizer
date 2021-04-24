open Belt
module SweepsQuery = %graphql(`
subscription {
    sweep {
        id
        metadata
    }
}
`)

@react.component
let make = () => {
  switch SweepsQuery.use() {
  | {loading: true} => "Loading..."->React.string
  | {error: Some(_error)} => "Error loading data"->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some({sweep})} => <>
      {sweep
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.map(({id, metadata}) => {
        let id = id->Int.toString
        <li key={id} onClick={_ => ReasonReactRouter.push(`#sweep/${id}`)}>
          <a>
            {id->React.string}
            {metadata->Option.mapWithDefault(<> </>, metadata =>
              <pre> {metadata->Js.Json.stringifyWithSpace(2)->React.string} </pre>
            )}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </>
  }
}
