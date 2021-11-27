open Belt

@react.component
let make = (~spec, ~data) => {
  let (numCopyDataPoints, setNumCopyDataPoints) = React.useState(_ => 30)
  let (firstNDatapoints, _) =
    Array.range(0, numCopyDataPoints)->Array.reduce((list{}, 0), ((datapoints, minKey), _) =>
      data
      ->Map.Int.findFirstBy((k, _) => minKey <= k)
      ->Option.mapWithDefault((datapoints, minKey), ((k, v)) => (list{v, ...datapoints}, k + 1))
    )
  let jsonToMap = json =>
    json->Js.Json.decodeObject->Option.map(dict => dict->Js.Dict.entries->Map.String.fromArray)
  let mapToJson = map => map->Map.String.toArray->Js.Dict.fromArray->Js.Json.object_
  let specWithData: option<Js.Json.t> =
    spec
    ->jsonToMap
    ->Option.flatMap((specMap: Map.String.t<Js.Json.t>) =>
      specMap
      ->Map.String.get("data")
      ->Option.flatMap((dataJson: Js.Json.t) => {
        dataJson
        ->jsonToMap
        ->Option.map((dataMap: Map.String.t<Js.Json.t>) => {
          let dataObject =
            dataMap
            ->Map.String.set("values", firstNDatapoints->List.toArray->Js.Json.array)
            ->mapToJson
          specMap->Map.String.set("data", dataObject)->mapToJson
        })
      })
    )
  <div className="w-80 m-1 z-0 inline-flex shadow-sm -space-x-px" ariaLabel="Pagination">
    <button
      className="-space-x-px px-3 py-2 rounded-l-md border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
      onClick={_ => setNumCopyDataPoints(n => n - 5)}
      disabled={numCopyDataPoints == 0}>
      <svg
        className="h-5 w-5"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        ariaHidden=true>
        <path
          fillRule="evenodd"
          d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
          clipRule="evenodd"
        />
      </svg>
    </button>
    <CopyButton
      text={`Copy with first ${numCopyDataPoints->Int.toString} datapoints`}
      copyString={specWithData->Option.getExn->Js.Json.stringifyWithSpace(2)}
      disabled={specWithData->Option.isNone}
      className="flex-grow px-3 py-2 border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
    />
    <div
      className="px-3 py-2 rounded-r-md border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default"
      onClick={_ => setNumCopyDataPoints(n => n + 5)}>
      <svg
        className="h-5 w-5"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        ariaHidden=true>
        <path
          fillRule="evenodd"
          d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
          clipRule="evenodd"
        />
      </svg>
    </div>
  </div>
}
