open Belt
open Routes
let textToResult = text => text->Util.parseJson->Result.map((m): Hasura.metadata => m->Contains)

let textAreaClassName = "border h-10 p-4 flex-grow shadow-sm w-full sm:text-sm border-gray-300"
let filterTextClass = "font-mono text-sm font-sm text-gray-700"

@react.component
let make = (~text, ~setText) => <>
  <span className={`${filterTextClass} flex-none pr-6`}> {"metadata @> "->React.string} </span>
  <input
    type_={"text"}
    placeholder={"{}"}
    onChange={evt => setText(ReactEvent.Form.target(evt)["value"])}
    className={`${textAreaClassName}
    ${filterTextClass}
            rounded-l-md
        ${text->textToResult->Result.isError ? " text-red-600 " : " focus:ring-indigo-500 "}`}
    value={text}
  />
</>
