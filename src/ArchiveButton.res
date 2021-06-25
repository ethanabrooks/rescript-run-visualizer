open Belt
open Util
type archiveResult = {
  called: bool,
  dataMessage: option<string>,
  error: option<ApolloClient__Errors_ApolloError.t>,
}
type queryResult = {loading: bool, error: option<string>, data: option<array<bool>>}

@react.component
let make = (~queryResult: queryResult, ~archiveResult: archiveResult, ~onClick, ~makePath) => {
  module Button = {
    @react.component
    let make = (~isArchived) =>
      switch archiveResult {
      | {called: false} =>
        <a href={`#${isArchived->makePath->pathToUrl}`}>
          <button
            type_="button"
            onClick={_ => isArchived->onClick->ignore}
            className="inline-flex items-center justify-center px-4 py-2 border border-transparent font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:text-sm">
            {(isArchived ? "Restore" : "Archive")->React.string}
          </button>
        </a>
      | {error: Some({message})} => <ErrorPage message />
      | {dataMessage: Some(message), error: None} => <p> {message->React.string} </p>
      | {error: None} => <p> {(isArchived ? "Restoring..." : "Archiving...")->React.string} </p>
      }
  }

  switch queryResult {
  | {loading: true} => <> </>
  | {error: Some(_error)} => "Error loading ArchiveQuery data"->React.string
  | {data: Some(areArchived)} =>
    switch areArchived {
    | [] => <> </>
    | areArchived =>
      let areArchived =
        areArchived->Array.every(archived => archived)
          ? [true]
          : areArchived->Array.every(archived => !archived)
          ? [false]
          : [true, false]

      areArchived
      ->Array.mapWithIndex((i, isArchived: bool) => <Button key={i->Int.toString} isArchived />)
      ->React.array
    }
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  }
}
