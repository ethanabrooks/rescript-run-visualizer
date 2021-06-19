open Util
type deleted = {
  called: bool,
  dataMessage: option<string>,
  error: option<ApolloClient__Errors_ApolloError.t>,
}
@react.component
let make = (~deleted: deleted, ~onClick) => {
  switch deleted {
  | {called: false} => <>
      <button
        type_="button"
        onClick
        className="inline-flex items-center justify-center px-4 py-2 border border-transparent font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:text-sm">
        {"Delete"->React.string}
      </button>
    </>
  | {error: Some({message})} => <ErrorPage message />
  | {dataMessage: Some(message), error: None} => <p> {message->React.string} </p>
  | {error: None} => <p> {"Deleting..."->React.string} </p>
  }
}
