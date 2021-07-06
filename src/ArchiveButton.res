open Belt
open Routes

type archiveResult = {
  called: bool,
  dataMessage: option<string>,
  error: option<ApolloClient__Errors_ApolloError.t>,
}
type queryResult = {loading: bool, error: option<string>, data: option<array<bool>>}

module SetArchived = {
  module Run = %graphql(`
  mutation set_archived($ids: [Int!], $archived: Boolean!) {
    update_run(_set: {archived: $archived}, where: {id: {_in: $ids}}) {
      affected_rows
    }
  }
`)
  module Sweep = %graphql(`
  mutation set_archived($ids: [Int!], $archived: Boolean!) {
    update_sweep(_set: {archived: $archived}, where: {id: {_in: $ids}}) {
      affected_rows
    }
    update_run(_set: {archived: $archived}, where: {sweep: {id: {_in: $ids}}}) {
      affected_rows
    }
  }
`)
}

module ArchivedSubscription = {
  module Sweep = %graphql(`
  subscription queryArchived($condition: sweep_bool_exp!) {
    sweep(where: $condition) {
      archived
    }
  }
`)
  module Run = %graphql(`
  subscription queryArchived($condition: run_bool_exp!) {
    run(where: $condition) {
      archived
    }
  }
`)
}

@react.component
let make = (~granularity, ~ids) => {
  let ids: array<int> = ids->Set.Int.toArray
  module Button = {
    @react.component
    let make = (~isArchived) => {
      let (onClick, archiveResult) = switch granularity {
      | Run =>
        let (
          archive,
          {called, error, data}: ApolloClient__React_Types.MutationResult.t<SetArchived.Run.t>,
        ) = SetArchived.Run.use()

        let onClick = _ => archive({ids: ids->Some, archived: !isArchived})->ignore
        let archiveResult = {
          called: called,
          error: error,
          dataMessage: switch data {
          | Some({update_run: Some({affected_rows: runsArchived})}) =>
            `Archived ${runsArchived->Int.toString} runs.`->Some
          | _ => None
          },
        }

        (onClick, archiveResult)
      | Sweep =>
        let (
          archive,
          {called, error, data}: ApolloClient__React_Types.MutationResult.t<SetArchived.Sweep.t>,
        ) = SetArchived.Sweep.use()

        let onClick = _ => archive({ids: ids->Some, archived: !isArchived})->ignore
        let archiveResult = {
          called: called,
          error: error,
          dataMessage: switch data {
          | Some({
              update_run: Some({affected_rows: runsArchived}),
              update_sweep: Some({affected_rows: sweepsArchived}),
            }) =>
            `Archived ${sweepsArchived->Int.toString} sweeps and ${runsArchived->Int.toString} runs.`->Some
          | _ => None
          },
        }
        (onClick, archiveResult)
      }
      <>
        <button
          type_="button"
          onClick={_ => {
            isArchived->onClick->ignore
          }}
          className="inline-flex items-center justify-center px-4 py-2 border border-transparent font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:text-sm">
          {(isArchived ? "Restore" : "Archive")->React.string}
        </button>
        {switch archiveResult {
        | {called: false} => <> </>
        | {error: Some({message})} => <ErrorPage message />
        | {dataMessage: Some(message), error: None} => <p> {message->React.string} </p>
        | {error: None} => <p> {(isArchived ? "Restoring..." : "Archiving...")->React.string} </p>
        }}
      </>
    }
  }
  let queryResult = switch granularity {
  | Sweep =>
    let id = ArchivedSubscription.Sweep.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let condition = ArchivedSubscription.Sweep.makeInputObjectsweep_bool_exp(~id, ())
    let {error, loading, data} = ArchivedSubscription.Sweep.use({condition: condition})
    {
      error: error->Option.map(({message}) => message),
      loading: loading,
      data: data->Option.map(({sweep}) => sweep->Array.map(({archived}) => archived)),
    }
  | Run =>
    let id = ArchivedSubscription.Run.makeInputObjectInt_comparison_exp(~_in=ids, ())
    let condition = ArchivedSubscription.Run.makeInputObjectrun_bool_exp(~id, ())
    let {error, loading, data} = ArchivedSubscription.Run.use({condition: condition})
    {
      error: error->Option.map(({message}) => message),
      loading: loading,
      data: data->Option.map(({run}) => run->Array.map(({archived}) => archived)),
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
