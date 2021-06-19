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
let make = (~client) => {
  let (selected, setSelected) = React.useState(_ => Set.Int.empty)
  switch SweepsQuery.use() {
  | {loading: true} => "Loading..."->React.string
  | {error: Some(_error)} => "Error loading data"->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some({sweep})} =>
    <div>
      <MenuList
        items={sweep->Array.map(({id, metadata}): MenuList.entry => {id: id, metadata: metadata})}
        setSelected
      />
      <Sweep sweepIds={selected} client />
    </div>
  }
}
