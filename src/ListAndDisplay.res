type queryResult = {loading: bool, error: option<string>, data: option<array<MenuList.entry>>}

@react.component
let make = (~queryResult, ~ids, ~display) => {
  switch queryResult {
  | {loading: true} => "Loading..."->React.string
  | {error: Some(message)} => `Error loading data: ${message}`->React.string
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  | {data: Some(items)} => <div className={"flex flex-row"}> <MenuList items ids /> {display} </div>
  }
}
