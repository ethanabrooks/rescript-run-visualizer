open Belt

@react.component
let make = (~id: int, ~metadata) => {
  open Routes
  let href =
    Routes.Valid({
      granularity: Run,
      checkedIds: Set.Int.empty->Set.Int.add(id),
      archived: false,
      where: None,
    })
    ->routeToHash
    ->hashToHref
  <div className="p-4">
    <a href className="font-medium text-indigo-700 hover:underline">
      {id->Int.toString->React.string}
    </a>
    <pre className="text-gray-500"> {metadata->Util.yaml({sortKeys: true})->React.string} </pre>
  </div>
}
