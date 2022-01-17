open Belt

module Query = LogsQuery.EveryQuery

module Subscription = %graphql(`
subscription MaxRunLogId($condition: run_log_bool_exp!) {
  run_log_aggregate(where: $condition) {
    aggregate {
      max {
        id
      }
    }
  }
}
`)
type apolloResult = Result.t<
  ApolloClient__Core_ApolloClient.ApolloQueryResult.t__ok<Query.t>,
  ApolloClient__Core_ApolloClient.ApolloError.t,
>

@react.component
let make = (
  ~specs: Map.t<Js.Json.t, Util.chartState, Util.JsonComparator.identity>,
  ~logs,
  ~checkedIds,
  ~granularity: Routes.granularity,
  ~dispatch,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (logIds, setLogIds) = React.useState(_ => logs->Map.Int.keysToArray->Set.Int.fromArray) // ids of all logs (original and new)
  let (newLogs, setNewLogs) = React.useState(_ => Map.Int.empty) // (id => log) map of logs since original logs
  let (error, setError) = React.useState(() => None)

  React.useEffect1(() => {
    // add newLogs to logIds
    setLogIds(logIds => newLogs->Map.Int.keysToArray->Array.reduce(logIds, Set.Int.add))
    None
  }, [newLogs])

  let run = switch granularity {
  | Sweep =>
    let sweep_id = Query.makeInputObjectInt_comparison_exp(~_in=checkedIds->Set.Int.toArray, ())
    Query.makeInputObjectrun_bool_exp(~sweep_id, ())
  | Run =>
    let id = Query.makeInputObjectInt_comparison_exp(~_in=checkedIds->Set.Int.toArray, ())
    Query.makeInputObjectrun_bool_exp(~id, ())
  }
  let condition1 = Query.makeInputObjectrun_log_bool_exp(~run, ())

  let maxLogId = switch (newLogs->Map.Int.maxKey, logIds->Set.Int.maximum) {
  | (Some(maxLogId), _)
  | (_, Some(maxLogId)) => maxLogId
  | _ => 0
  }

  // Second condition: logs have a greater id than max id in logIds
  let id = Query.makeInputObjectInt_comparison_exp(~_gt=maxLogId, ())
  let condition2 = Query.makeInputObjectrun_log_bool_exp(~id, ())

  let _and = [condition1, condition2]
  let condition = Query.makeInputObjectrun_log_bool_exp(~_and, ())

  // Uncomment to print condition as JSON:

  // Js.log(
  //   {condition: condition}
  //   ->Query.serializeVariables
  //   ->Query.variablesToJson
  //   ->Js.Json.stringifyWithSpace(2),
  // )

  let onError = error => setError(_ => error->Some)

  let executeQuery = Debounce.makeControlled(() => {
    client.query(~query=module(Query), {condition: condition})
    ->Promise.thenResolve(result =>
      switch result {
      | Error(error) => error->onError
      | Ok({data: {run_log}}) =>
        setNewLogs(newLogs =>
          run_log->Array.reduce(newLogs, (newLogs, {id, log}) => newLogs->Map.Int.set(id, log))
        )
      }
    )
    ->ignore
  })

  React.useEffect3(() => {
    // Set up subscription to max run_log id
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} => error->onError
      | {
          data: {run_log_aggregate: {aggregate: Some({max: Some({id: Some(_)})})}},
        } => executeQuery.schedule()
      | _ => ()
      }
    }

    let id = Subscription.makeInputObjectInt_comparison_exp(~_in=checkedIds->Set.Int.toArray, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let subscription = client.subscribe(
      ~subscription=module(Subscription),
      {condition: condition},
    ).subscribe(~onNext, ~onError, ())
    Some(
      _ => {
        subscription.unsubscribe()
        executeQuery.cancel()
      },
    )
  }, (checkedIds, client, executeQuery))

  module ChartGroup = {
    @react.component
    let make = (~name: option<string>, ~rendering: bool, ~spec, ~chartIds: Set.Int.t) => {
      let name = switch name {
      | None =>
        spec
        ->Js.Json.decodeObject
        ->Option.flatMap(object =>
          object
          ->Js.Dict.get("hconcat")
          ->Option.flatMap(hconcat =>
            hconcat
            ->Js.Json.decodeArray
            ->Option.flatMap(array =>
              array
              ->Array.get(0)
              ->Option.flatMap(elt =>
                elt
                ->Js.Json.decodeObject
                ->Option.flatMap(object =>
                  object
                  ->Js.Dict.get("encoding")
                  ->Option.flatMap(encoding =>
                    encoding
                    ->Js.Json.decodeObject
                    ->Option.flatMap(object =>
                      object
                      ->Js.Dict.get("y")
                      ->Option.flatMap(y =>
                        y
                        ->Js.Json.decodeObject
                        ->Option.flatMap(object =>
                          object
                          ->Js.Dict.get("field")
                          ->Option.flatMap(field => field->Js.Json.decodeString)
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      | _ => None
      }
      let (opened, setOpened) = React.useState(_ => true)
      <>
        {name->Option.mapWithDefault(<> </>, name =>
          <div className="flex space-x-3">
            <div
              className="flex items-center justify-center overflow-hidden"
              onClick={_ => setOpened(state => !state)}>
              {opened ? <Chevron.Down /> : <Chevron.Right />}
            </div>
            <h2> {name->React.string} </h2>
          </div>
        )}
        {switch rendering {
        | true =>
          <div
            style={ReactDOMStyle.make(
              ~transition={"max-height 0.4s linear"},
              ~maxHeight={opened ? "1000px" : "0px"},
              ~overflow="auto",
              (),
            )}>
            <Chart logs newLogs spec />
            <div className="pb-5"> <ChartButtons spec chartIds dispatch /> </div>
          </div>
        | false =>
          let initialSpec = spec
          <SpecEditor initialSpec dispatch />
        }}
      </>
    }
  }

  <>
    {switch error {
    | None => <> </>
    | Some({message}) =>
      let message = `MaxRunLogId subscription error: ${message}`
      <ErrorPage message />
    }}
    {specs
    ->Map.toArray
    ->List.fromArray
    ->List.sort(((_, {order: order1}), (_, {order: order2})) => order1 - order2)
    ->List.mapWithIndex((i, (spec, {rendering, name, ids: chartIds})) =>
      <ChartGroup key={i->Int.toString} chartIds name rendering spec />
    )
    ->List.toArray
    ->React.array}
  </>
}
