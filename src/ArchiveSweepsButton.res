open Belt
type archiveResult = {
  called: bool,
  dataMessage: option<string>,
  error: option<ApolloClient__Errors_ApolloError.t>,
}

module Inner = {
  @react.component
  let make = (~archiveResult: archiveResult, ~onClick, ~isArchived: bool) =>
    switch archiveResult {
    | {called: false} =>
      <button
        type_="button"
        onClick={_ => isArchived->onClick}
        className="inline-flex items-center justify-center px-4 py-2 border border-transparent font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:text-sm">
        {(isArchived ? "Restore" : "Archive")->React.string}
      </button>
    | {error: Some({message})} => <ErrorPage message />
    | {dataMessage: Some(message), error: None} => <p> {message->React.string} </p>
    | {error: None} => <p> {(isArchived ? "Restoring..." : "Archiving...")->React.string} </p>
    }
}

module ArchiveQuery = %graphql(`
  query queryArchived($condition: sweep_bool_exp!) {
    sweep(where: $condition) {
      archived
    }
  }
`)

@react.component
let make = (~archiveResult: archiveResult, ~onClick, ~condition) =>
  switch ArchiveQuery.use({condition: condition}) {
  | {loading: true} => <> </>
  | {error: Some(_error)} => "Error loading ArchiveQuery data"->React.string
  | {data: Some({sweep})} =>
    switch sweep {
    | [] => <> </>
    | _ =>
      let areArchived =
        sweep->Array.every(({archived}) => archived)
          ? [true]
          : sweep->Array.every(({archived}) => !archived)
          ? [false]
          : [true, false]

      areArchived
      ->Array.mapWithIndex((i, isArchived: bool) =>
        <Inner key={i->Int.toString} archiveResult onClick isArchived />
      )
      ->React.array
    }
  | {data: None, error: None, loading: false} =>
    "You might think this is impossible, but depending on the situation it might not be!"->React.string
  }
