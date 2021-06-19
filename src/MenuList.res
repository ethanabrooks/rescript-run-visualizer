open Belt
type entry = {id: int, metadata: option<Js.Json.t>}

@react.component
let make = (~items: array<entry>, ~ids: Set.Int.t) => {
  let {hash} = ReasonReactRouter.useUrl()
  let (text, textbox) = TextInput.useText(~initialText="name,parameters")
  let keywords = ","->Js.String.split(text)->Set.String.fromArray->Set.String.remove("")
  <div className="py-10 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    {textbox}
    <ul className="bg-white rounded-lg -space-y-px">
      {items
      ->List.fromArray
      ->List.sort(({id: id1}, {id: id2}) => id2 - id1)
      ->List.mapWithIndex((idx, {id, metadata}) => {
        let key = id->Int.toString
        let selected = ids->Set.Int.has(id)
        let className = `
          ${idx == 0 ? "rounded-tl-lg rounded-tr-lg" : ""}
          ${idx == items->Array.length - 1 ? "rounded-bl-lg rounded-br-lg" : ""}
          ${selected ? "bg-indigo-50 border-indigo-200 z-10" : "border-gray-200"}
          ${"relative border p-4 flex cursor-pointer focus:outline-none"}
        `

        open Util
        let newIds = ids->Set.Int.has(id) ? ids->Set.Int.remove(id) : ids->Set.Int.add(id)
        let newIds = newIds->Set.Int.toArray->Array.map(Int.toString)->Js.Array2.joinWith(",")
        let href = switch hash->splitHash->List.fromArray {
        | list{base, ..._} => `#${base}/${newIds}`
        | _ => Js.Exn.raiseError(`Invalid hash: ${hash}`)
        }
        <li key={key}>
          <a className href>
            <div className="flex-shrink-0 flex items-center justify-center w-16">
              {key->React.string}
            </div>
            {metadata->Option.mapWithDefault(<> </>, metadata => {
              <pre className="p-4 font-extralight">
                {metadata
                ->jsonToMap
                ->Option.mapWithDefault(metadata, map =>
                  map
                  ->Map.String.keep((key, _) =>
                    keywords->Set.String.isEmpty || keywords->Set.String.has(key)
                  )
                  ->mapToJson
                )
                ->yaml
                ->React.string}
              </pre>
            })}
          </a>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </div>
}
