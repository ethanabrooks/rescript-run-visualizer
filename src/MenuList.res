open Routes
open Belt

type entry = {id: int, metadata: option<Js.Json.t>}
@val external document: 'a = "document"

@react.component
let make = (~items: array<entry>, ~ids: Set.Int.t, ~defaultListFilters) => {
  let (text, textbox) = TextInput.useText(~initialText=defaultListFilters)
  let url = ReasonReactRouter.useUrl()
  let keywords = ","->Js.String.split(text)->Set.String.fromArray->Set.String.remove("")
  <div className="py-10 m-5 max-h-screen overflow-y-scroll overscroll-contain">
    {textbox}
    <ul className="bg-white rounded-lg -escape-y-px">
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
          ${"items-center relative border p-4 flex focus:outline-none"}
        `
        open Util
        let newIds = Set.Int.empty->Set.Int.add(id)
        let href = switch url->urlToRoute {
        | Valid(valid) => Valid({...valid, ids: newIds})
        | _ => Js.Exn.raiseError(`The hash ${url.hash} should not route to MenuList.`)
        }->routeToHref
        <li key={key}>
          <div className>
            <div className="flex items-center h-5 p-4">
              <input
                id="candidates"
                name="candidates"
                type_="checkbox"
                checked={ids->Set.Int.has(id)}
                onChange={_ => {
                  let newIds = ids->Set.Int.has(id) ? ids->Set.Int.remove(id) : ids->Set.Int.add(id)
                  let href = switch url.hash->hashToRoute {
                  | Valid(valid) => Valid({...valid, ids: newIds})
                  | _ => Js.Exn.raiseError(`The hash ${url.hash} should not route to MenuList.`)
                  }->routeToHref

                  ReasonReactRouter.replace(href)
                }}
                className="focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded"
              />
            </div>
            <a className="flex-shrink-0 flex items-center justify-center w-16" href>
              {key->React.string}
            </a>
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
          </div>
        </li>
      })
      ->List.toArray
      ->React.array}
    </ul>
  </div>
}
