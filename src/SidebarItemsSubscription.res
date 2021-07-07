open Routes
open Belt

module RunSubscription = %graphql(`
  subscription search_runs(
    $path: _text = null,
    $pattern: String = "%",
    $obj: jsonb = null,
    $archived: Boolean! 
  ) {
    filter_runs(args: {object: $obj, path: $path, pattern: $pattern}, 
    where: {_and: [{archived: {_eq: $archived}}, {sweep_id: {_is_null: true}}]}) {
      id
      metadata
    }
  }
`)

module SweepSubscription = %graphql(`
  subscription search_sweeps(
    $path: _text = null,
    $pattern: String = "%",
    $obj: jsonb = null,
    $archived: Boolean! 
  ) {
    filter_sweeps(args: {object: $obj, path: $path, pattern: $pattern}, 
    where: {archived: {_eq: $archived}}) {
      id
      metadata
    }
  }
`)

type state = {
  error: option<ApolloClient__Core_ApolloClient.ApolloError.t>,
  data: option<array<Sidebar.entry>>,
}

let useSidebarItems = (
  ~granularity,
  ~archived,
  ~obj: option<Js.Json.t>,
  ~pattern,
  ~path,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (state, setState) = React.useState(_ => None)

  let path =
    path
    ->Option.map(Js.Array.filter(t => t != ""))
    ->Option.map(Js.Array.joinWith(","))
    ->Option.map(path => `{${path}}`)
    ->Option.map(Js.Json.string)

  React.useEffect4(() => {
    let onError = error => setState(_ => {error: error->Some, data: None}->Some)
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    switch granularity {
    | Run =>
      subscription :=
        client.subscribe(
          ~subscription=module(RunSubscription),
          {
            archived: archived,
            obj: obj,
            pattern: pattern,
            path: path,
          },
        ).subscribe(
          ~onNext=(
            {error, data: {filter_runs}}: ApolloClient__Core_ApolloClient.FetchResult.t__ok<
              RunSubscription.t,
            >,
          ) =>
            setState(_ =>
              {
                error: error,
                data: filter_runs
                ->Array.map(({id, metadata}): Sidebar.entry => {
                  id: id,
                  metadata: metadata,
                })
                ->Some,
              }->Some
            ),
          ~onError,
          (),
        )->Some

    | Sweep =>
      subscription :=
        client.subscribe(
          ~subscription=module(SweepSubscription),
          {
            archived: archived,
            obj: obj,
            pattern: pattern,
            path: path,
          },
        ).subscribe(
          ~onNext=(
            {error, data: {filter_sweeps}}: ApolloClient__Core_ApolloClient.FetchResult.t__ok<
              SweepSubscription.t,
            >,
          ) =>
            setState(_ =>
              {
                error: error,
                data: filter_sweeps
                ->Array.map(({id, metadata}): Sidebar.entry => {
                  id: id,
                  metadata: metadata,
                })
                ->Some,
              }->Some
            ),
          ~onError,
          (),
        )->Some
    }
    Some(_ => unsubscribe())
  }, (archived, obj, pattern, path))

  state->Option.map(state =>
    switch state {
    | {error: Some({message})} => message->Error
    | {data: None, error: None} =>
      "You might think this is impossible, but depending on the situation it might not be!"->Error
    | {data: Some(items)} => items->Ok
    }
  )
}
