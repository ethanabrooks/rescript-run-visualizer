open Belt
open Util

@val external maxLogs: string = "NODE_MAX_LOGS"

module Query = %graphql(`
query run_log_count($condition: run_log_bool_exp!) {
  run_log_aggregate(where: $condition) {
    aggregate {
      count
    }
  }
}
`)

type queryResult = {
  metadata: Map.Int.t<Js.Json.t>,
  specs: specs,
  logs: jsonMap,
  runIds: Set.Int.t,
}

type result = {
  interval: int,
  exclude: bool,
}

let useQuery = (~ids, ~granularity): queryState<option<result>> => {
  let condition = {
    open Routes
    let ids = ids->Set.Int.toArray
    switch granularity {
    | Run =>
      let id = Query.makeInputObjectInt_comparison_exp(~_in=ids, ())
      Query.makeInputObjectrun_log_bool_exp(~id, ())
    | Sweep =>
      let sweep_id = Query.makeInputObjectInt_comparison_exp(~_in=ids, ())
      let run = Query.makeInputObjectrun_bool_exp(~sweep_id, ())
      Query.makeInputObjectrun_log_bool_exp(~run, ())
    }
  }
  switch Query.use({condition: condition}) {
  | {loading: true} => Waiting
  | {error: Some(_error)} => _error->Error
  | {data: Some({run_log_aggregate: {aggregate: Some({count})}})} =>
    maxLogs
    ->Int.fromString
    ->Option.flatMap((maxLogs: int) =>
      if count < maxLogs {
        None
      } else if count < 2 * maxLogs {
        Some({interval: maxLogs / (count - maxLogs), exclude: true})
      } else {
        Some({interval: (count - maxLogs) / maxLogs, exclude: false})
      }
    )
    ->Data
  | {error: None, loading: false} => Js_exn.raiseError("Invalid data")
  }
}
