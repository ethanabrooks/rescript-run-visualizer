open Belt
type entry = {id: int, metadata: option<Js.Json.t>}
@val external document: 'a = "document"

@react.component
let make = (~items: array<entry>, ~ids: Set.Int.t, ~defaultListFilters) => {
  let (text, textbox) = TextInput.useText(~initialText=defaultListFilters)
  let (escapeDown, setEscapeDown) = React.useState(_ => false)

  React.useEffect0(_ => {
    let handleKey = (~down: bool, evt) => {
      let key = ReactEvent.Keyboard.key(evt)

      switch key {
      | "Escape" =>
        setEscapeDown(_ => down)
        ReactEvent.Keyboard.preventDefault(evt)
      | _ => ()
      }
    }
    document["addEventListener"]("keydown", handleKey(~down=true))->ignore
    document["addEventListener"]("keyup", handleKey(~down=false))->ignore
    Some(
      _ => {
        document["removeEventListener"]("keyup", handleKey(~down=false))->ignore
        document["removeEventListener"]("keydown", handleKey(~down=true))->ignore
      },
    )
  })

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
          ${"relative border p-4 flex focus:outline-none"}
        `
        open Util
        let newIds = escapeDown
          ? ids->Set.Int.has(id) ? ids->Set.Int.remove(id) : ids->Set.Int.add(id)
          : Set.Int.empty->Set.Int.add(id)
        let href = switch url->urlToPath {
        | Sweeps({archived}) => Sweeps({ids: newIds, archived: archived})
        | Runs({archived}) => Runs({ids: newIds, archived: archived})
        | _ => Js.Exn.raiseError(`The hash ${url.hash} should not route to MenuList.`)
        }->pathToUrl
        let href = `#${href}`
        <li key={key}>
          <div className>
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
