open Belt
type entry = {id: int, metadata: option<Js.Json.t>}

@react.component
let make = (~items: array<entry>, ~path: string => string) => {
  <div className="py-10">
    <ul className="relative z-0 divide-y divide-gray-200">
      {items
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.map(({id, metadata}) => {
        let id = id->Int.toString
        <li key={id}>
          <a className={"col-span-1 flex hover:bg-gray-50 cursor-pointer"} href={`/${id->path}`}>
            <div className="flex-shrink-0 flex items-center justify-center w-16">
              {id->React.string}
            </div>
            {metadata->Option.mapWithDefault(<> </>, metadata =>
              <pre className="p-4"> {metadata->Js.Json.stringifyWithSpace(2)->React.string} </pre>
            )}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </div>
}
