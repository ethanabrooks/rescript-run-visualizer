open Belt

module SetArchived = %graphql(`
  mutation set_archived($chartIds: [Int!]) {
    update_chart(_set: {archived: true}, where: {id: {_in: $chartIds}}) {
      affected_rows
    }
  }
`)

@react.component
let make = (~spec, ~chartIds, ~dispatch, ~logs) => {
  let (archiveChart, archiveChartResult) = SetArchived.use()
  let specString = spec->Js.Json.stringifyWithSpace(2)
  let chartIds = chartIds->Option.map(Set.Int.toArray)
  let {old}: Util.oldAndNewLogs = logs

  let archiveChartButton = switch archiveChartResult {
  | {error: Some({message})} => <ErrorPage message />
  | {data: Some({update_chart: Some({affected_rows})})} =>
    <p> {`Updated ${affected_rows->Int.toString} chart.`->React.string} </p>
  | {error: None} =>
    <Button
      text={"Archive"} onClick={_ => archiveChart({chartIds: chartIds})->ignore} disabled={false}
    />
  }

  let data = old
  let buttons = [
    <Button
      text={"Edit chart"} onClick={_ => dispatch(Util.ToggleRender(spec))} disabled={false}
    />,
    archiveChartButton,
    <CopyButton
      text={"Copy spec"} copyString=specString className={Button.className} disabled={false}
    />,
    <CopyWithDataButton spec data />,
  ]

  <> <Chart logs spec /> <Buttons buttons /> </>
}
