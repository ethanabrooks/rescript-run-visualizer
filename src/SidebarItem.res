open Belt
open Routes
open Dom

type springValue = string
type outputHeight = {height: springValue}
type inputHeight = {height: int}
type to = {to: inputHeight}
@module("@react-spring/web") external useSpring: to => outputHeight = "useSpring"

@val @scope("window")
external getComputedStyle: Dom.element => cssStyleDeclaration = "getComputedStyle"
@get external getHeightProperty: cssStyleDeclaration => string = "height"

type animated_props = {
  style: ReactDOMStyle.t,
  ref: ReactDOM.domRef,
}
@module("./Animated.jsx")
external make: (~props: animated_props, ~children: React.element) => React.element = "make"

let usePrevious = value => {
  let ref = React.useRef(false)
  React.useEffect1(() => {
    ref.current = value
    None
  }, [value])
  ref.current
}

@react.component
let make = (~id: int, ~checkedIds: Set.Int.t, ~metadata) => {
  let url = RescriptReactRouter.useUrl()
  let (opened, setOpened) = React.useState(_ => false)
  let viewHeight = React.useRef(0)
  // let previous = usePrevious(opened)

  let spring = {to: {height: opened ? 1000 : 0}}->useSpring
  let height = spring.height
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
              ->Util.jsonToMap
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
    {metadata->Option.mapWithDefault(<> </>, metadata => {
      make(
        ~children={
          <pre className="line-clamp-2 text-sm text-gray-600 p-4 font-extralight">
            {metadata->Util.yaml({sortKeys: true})->React.string}
          </pre>
        },
        ~props={
          {
            style: ReactDOMStyle.make(~height, ()),
            ref: ReactDOM.Ref.callbackDomRef(element => {
              element
              ->Js.Nullable.toOption
              ->Option.map(getComputedStyle)
              ->Option.map(getHeightProperty)
              ->Option.map(Js.String2.replace("px", ""))
              ->Option.flatMap(Int.fromString)
              ->Option.forEach(height => viewHeight.current = height)
            }),
          }
        },
      )
    })}
  </li>
}
