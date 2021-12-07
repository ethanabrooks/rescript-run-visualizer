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

@react.component
let make = (
  ~specs: Map.t<Js.Json.t, Util.chartState, Util.JsonComparator.identity>,
  ~logs,
  ~checkedIds,
  ~granularity: Routes.granularity,
  ~dispatch,
  ~client: ApolloClient__Core_ApolloClient.t,
) => {
  let (logIds, setLogIds) = React.useState(_ => logs->Map.Int.keysToArray->Set.Int.fromArray)
  let (executeQuery, queryResult) = Query.useLazy()
  let (error, setError) = React.useState(() => None)
  let (timedOut, setTimedOut) = React.useState(() => true)

  let newLogs = switch queryResult {
  | Executed({data: Some({run_log})}) =>
    run_log
    ->Array.keepMap(({id, log}) =>
      if logIds->Set.Int.has(id) {
        None // exclude logs that are already in logIds
      } else {
        Some((id, log))
      }
    )
    ->Map.Int.fromArray
  | _ => Map.Int.empty
  }
  let maxLogId = switch newLogs->Map.Int.maxKey {
  | Some(max) => max
  | None => logIds->Set.Int.maximum->Option.getWithDefault(0)
  }

  React.useEffect4(() => {
    // Set up subscription to max run_log id
    let onError = error => setError(_ => error->Some)
    let onNext = (value: ApolloClient__Core_ApolloClient.FetchResult.t__ok<Subscription.t>) => {
      switch value {
      | {error: Some(error)} => error->onError
      | {data: {run_log_aggregate: {aggregate: Some({max: Some({id: Some(_)})})}}} =>
        // When run_log id increases, query for new logs
        if timedOut {
          // First condition: logs belong to checked runs
          let run = switch granularity {
          | Sweep =>
            let sweep_id = Query.makeInputObjectInt_comparison_exp(
              ~_in=checkedIds->Set.Int.toArray,
              (),
            )
            Query.makeInputObjectrun_bool_exp(~sweep_id, ())
          | Run =>
            let id = Query.makeInputObjectInt_comparison_exp(~_in=checkedIds->Set.Int.toArray, ())
            Query.makeInputObjectrun_bool_exp(~id, ())
          }
          let condition1 = Query.makeInputObjectrun_log_bool_exp(~run, ())

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

          executeQuery({condition: condition})

          // reset debounce timer
          setTimedOut(_ => false)
          Js.Global.setTimeout(() => setTimedOut(_ => true), 5000)->ignore
        }
      | _ => ()
      }
    }

    let id = Subscription.makeInputObjectInt_comparison_exp(~_in=checkedIds->Set.Int.toArray, ())
    let run = Subscription.makeInputObjectrun_bool_exp(~id, ())
    let condition = Subscription.makeInputObjectrun_log_bool_exp(~run, ())
    let subscription =
      client.subscribe(~subscription=module(Subscription), {condition: condition}).subscribe(
        ~onNext,
        ~onError,
        (),
      )->Some
    Some(_ => (subscription->Option.getExn).unsubscribe())
  }, (checkedIds, client, timedOut, maxLogId))

  React.useEffect1(() => {
    // add newLogs to logIds
    setLogIds(logIds => newLogs->Map.Int.keysToArray->Array.reduce(logIds, Set.Int.add))
    None
  }, [newLogs])

  <>
    {switch error {
    | None => <> </>
    | Some({message}) =>
      let message = `MaxRunLogId subscription error: ${message}`
      <ErrorPage message />
    }}
    {switch queryResult {
    | Executed({error: Some({message})}) =>
      let message = `LogsQuery.EveryQuery error: ${message}`
      <ErrorPage message />
    | _ => <> </>
    }}
    {specs
    ->Map.toArray
    ->List.fromArray
    ->List.sort(((_, {order: order1}), (_, {order: order2})) => order1 - order2)
    ->List.mapWithIndex((i, (spec, {rendering, ids: chartIds})) => {
      let key = i->Int.toString
      if rendering {
        <div className="pb-10" key>
          <Chart logs newData={newLogs->Map.Int.valuesToArray} spec />
          <ChartButtons spec chartIds dispatch />
        </div>
      } else {
        let initialSpec = spec
        <SpecEditor key initialSpec dispatch />
      }
    })
    ->List.toArray
    ->React.array}
  </>
}
