open Routes
open Belt

module RunSubscription = %graphql(`
  subscription search_runs($archived: Boolean!, $condition: run_bool_exp = {}) {
    run(where: {_and: [{archived: {_eq: $archived}, sweep_id: {_is_null: true}}, $condition]}) {
      id
      metadata
    }
  }
`)

module SweepSubscription = %graphql(`
  subscription search_sweeps($archived: Boolean!, $condition: sweep_bool_exp = {}) {
    sweep(where: {_and: [{archived: {_eq: $archived}}, $condition]}) {
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
  ~archived: bool,
  ~where: option<Hasura.where>,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (state, setState) = React.useState(_ => None)
  let whereJson = where->Option.map(Hasura.where_encode)
  let whereText = whereJson->Option.mapWithDefault("", Js.Json.stringify)

  React.useEffect2(() => {
    let onError = error => setState(_ => {error: error->Some, data: None}->Some)
    let subscription: ref<option<ApolloClient__ZenObservable.Subscription.t>> = ref(None)
    let unsubscribe = _ => (subscription.contents->Option.getExn).unsubscribe()->ignore
    switch granularity {
    | Run =>
      let rec makeRunBoolExp = (where: Hasura.where): RunSubscription.t_variables_run_bool_exp =>
        switch where {
        | And(_and) =>
          let _and = _and->Array.map(makeRunBoolExp)
          RunSubscription.makeInputObjectrun_bool_exp(~_and, ())
        | Or(_or) =>
          let _or = _or->Array.map(makeRunBoolExp)
          RunSubscription.makeInputObjectrun_bool_exp(~_or, ())
        | Just(Contains(path)) =>
          let _contains = path
          let metadata = RunSubscription.makeInputObjectjsonb_comparison_exp(~_contains, ())
          RunSubscription.makeInputObjectrun_bool_exp(~metadata, ())
        }
      subscription :=
        client.subscribe(
          ~subscription=module(RunSubscription),
          {
            archived: archived,
            condition: where->Option.map(makeRunBoolExp),
          },
        ).subscribe(
          ~onNext=(
            {error, data: {run}}: ApolloClient__Core_ApolloClient.FetchResult.t__ok<
              RunSubscription.t,
            >,
          ) =>
            setState(_ =>
              {
                error: error,
                data: run
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
      let rec makeSweepBoolExp = (
        where: Hasura.where,
      ): SweepSubscription.t_variables_sweep_bool_exp =>
        switch where {
        | And(_and) =>
          let _and = _and->Array.map(makeSweepBoolExp)
          SweepSubscription.makeInputObjectsweep_bool_exp(~_and, ())
        | Or(_or) =>
          let _or = _or->Array.map(makeSweepBoolExp)
          SweepSubscription.makeInputObjectsweep_bool_exp(~_or, ())
        | Just(Contains(path)) =>
          let _contains = path
          let metadata = SweepSubscription.makeInputObjectjsonb_comparison_exp(~_contains, ())
          SweepSubscription.makeInputObjectsweep_bool_exp(~metadata, ())
        }
      subscription :=
        client.subscribe(
          ~subscription=module(SweepSubscription),
          {
            archived: archived,
            condition: where->Option.map(makeSweepBoolExp),
          },
        ).subscribe(
          ~onNext=(
            {error, data: {sweep}}: ApolloClient__Core_ApolloClient.FetchResult.t__ok<
              SweepSubscription.t,
            >,
          ) =>
            setState(_ =>
              {
                error: error,
                data: sweep
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
  }, (archived, whereText))

  state->Option.map(state =>
    switch state {
    | {error: Some({message})} => message->Error
    | {data: None, error: None} =>
      "You might think this is impossible, but depending on the situation it might not be!"->Error
    | {data: Some(items)} => items->Ok
    }
  )
}
