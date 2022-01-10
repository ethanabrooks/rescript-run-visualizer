open Belt
open Routes
@react.component
let make = (~id: int, ~checkedIds: Set.Int.t, ~metadata) => {
  let url = RescriptReactRouter.useUrl()
  let (opened, setOpened) = React.useState(_ => false)

  open Util
  let newIds = Set.Int.empty->Set.Int.add(id)
  let href = switch url->urlToRoute {
  | Valid(valid) => Valid({...valid, checkedIds: newIds})
  | _ => Js.Exn.raiseError(`The hash ${url.hash} should not route to here.`)
  }->routeToHref
  <li key={id->Int.toString} className="relative bg-white py-5 px-4 hover:bg-gray-50">
    <div className="flex space-x-3">
      <div className="flex items-center justify-center">
        <input
          id="candidates"
          name="candidates"
          type_="checkbox"
          checked={checkedIds->Set.Int.has(id)}
          onChange={_ => {
            let newIds =
              checkedIds->Set.Int.has(id)
                ? checkedIds->Set.Int.remove(id)
                : checkedIds->Set.Int.add(id)
            let href = switch url.hash->hashToRoute {
            | Valid(valid) => Valid({...valid, checkedIds: newIds})
            | _ => Js.Exn.raiseError(`The hash ${url.hash} should not route to here.`)
            }->routeToHref

            RescriptReactRouter.replace(href)
          }}
          className="focus:ring-indigo-500 h-4 w-4 filterKeywords-indigo-600 border-gray-300 rounded"
        />
      </div>
      <div className="flex items-center justify-center" onClick={_ => setOpened(state => !state)}>
        {opened
          ? {
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5 cursor-pointer"
                viewBox="0 0 20 20"
                fill="currentColor">
                <path
                  fillRule="evenodd"
                  d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                  clipRule="evenodd"
                />
              </svg>
            }
          : {
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5 cursor-pointer"
                viewBox="0 0 20 20"
                fill="currentColor">
                <path
                  fillRule="evenodd"
                  d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                  clipRule="evenodd"
                />
              </svg>
            }}
      </div>
      <h3
        className="flex-shrink-0 flex items-center justify-center font-medium text-gray-900 truncate">
        <a href>
          {`${id->Int.toString}. ${metadata->Option.mapWithDefault("No metadata", metadata => {
              metadata
              ->jsonToMap
              ->Option.mapWithDefault("Ill-formatted metadata", map =>
                map
                ->Map.String.get("name")
                ->Option.mapWithDefault("No name field in metadata", name =>
                  name->Js.Json.decodeString->Option.getWithDefault(name->Js.Json.stringify)
                )
              )
            })}`->React.string}
        </a>
      </h3>
    </div>
    {if opened {
      metadata->Option.mapWithDefault(<> </>, metadata => {
        <div className="mt-1">
          <pre className="line-clamp-2 text-sm text-gray-600 p-4 font-extralight">
            {metadata->yaml({sortKeys: true})->React.string}
          </pre>
        </div>
      })
    } else {
      <> </>
    }}
  </li>
}
