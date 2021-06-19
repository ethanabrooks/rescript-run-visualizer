open Belt
type entry = {id: int, metadata: option<Js.Json.t>}

@react.component
let make = (~items: array<entry>, ~ids: Set.Int.t) => {
  let {hash} = ReasonReactRouter.useUrl()
  <div className="py-10">
    <ul className="relative z-0 divide-y divide-gray-200">
      {items
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.map(({id, metadata}) => {
        let key = id->Int.toString
        let className =
          "col-span-1 flex cursor-pointer"->Js.String2.concat(
            ids->Set.Int.has(id) ? " bg-gray-200" : "hover:bg-gray-50 ",
          )

        let newIds = ids->Set.Int.has(id) ? ids->Set.Int.remove(id) : ids->Set.Int.add(id)
        let newIds = newIds->Set.Int.toArray->Array.map(Int.toString)->Js.Array2.joinWith(",")
        let href = switch hash->Util.splitHash->List.fromArray {
        | list{base, ..._} => `#${base}/${newIds}`
        | _ => Js.Exn.raiseError(`Invalid hash: ${hash}`)
        }
        <li key={key}>
          <a className href>
            <div className="flex-shrink-0 flex items-center justify-center w-16">
              {key->React.string}
            </div>
            {metadata->Option.mapWithDefault(<> </>, metadata => {
              <pre className="p-4"> {metadata->Util.yaml->React.string} </pre>
            })}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </div>
}
