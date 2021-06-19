open Belt
type entry = {id: int, metadata: option<Js.Json.t>}

@react.component
let make = (~items: array<entry>, ~setSelected) => {
  <div className="py-10">
    <ul className="relative z-0 divide-y divide-gray-200">
      {items
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.map(({id, metadata}) => {
        let key = id->Int.toString
        <li key={key}>
          <a
            className={"col-span-1 flex hover:bg-gray-50 cursor-pointer"}
            onClick={_ =>
              setSelected(s => s->Set.Int.has(id) ? s->Set.Int.remove(id) : s->Set.Int.add(id))}>
            <div className="flex-shrink-0 flex items-center justify-center w-16">
              {key->React.string}
            </div>
            {metadata->Option.mapWithDefault(<> </>, metadata => {
              <pre className="p-4"> {metadata->Util.dump->React.string} </pre>
            })}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </div>
}
