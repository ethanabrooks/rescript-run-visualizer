open Belt
type entry = {id: int, metadata: option<Js.Json.t>}

@react.component
let make = (~items: array<entry>) => {
  <aside className={"menu"}>
    <ul className={"menu-list"}>
      {items
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.map(({id, metadata}) => {
        let id = id->Int.toString
        <li key={id} onClick={_ => ReasonReactRouter.push(`#run/${id}`)}>
          {id->React.string}
          <a>
            {metadata->Option.mapWithDefault(<> </>, metadata =>
              <pre> {metadata->Js.Json.stringifyWithSpace(2)->React.string} </pre>
            )}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </aside>
}
