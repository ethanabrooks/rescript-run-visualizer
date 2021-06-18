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
      <button type_="button" onClick className="button"> {"Delete"->React.string} </button>
    </>
  | {error: Some({message})} => <ErrorPage message />
  | {dataMessage: Some(message), error: None} => <p> {message->React.string} </p>
  | {error: None} => <p> {"Deleting..."->React.string} </p>
  }
}
