open Belt
open Routes
let textToResult = text =>
  text
  ->Util.parseJson
  ->Result.flatMap(j => j->Hasura.metadata_decode->Util.mapError(({message}) => message->Some))

@react.component
let make = (~text, ~setText) => {
  let textAreaClassName = "h-10 border p-4 shadow-sm block w-full sm:text-sm border-gray-300"
  <div className="pb-5 -space-y-px">
    <input
      type_={"text"}
      placeholder={"JSON object"}
      onChange={evt => {
        Js.log(ReactEvent.Form.target(evt)["value"])
        setText(ReactEvent.Form.target(evt)["value"])
      }}
      className={`${textAreaClassName}
            rounded-md
        ${text->textToResult->Result.isError ? " text-red-600 " : " focus:ring-indigo-500 "}`}
      value={text}
    />
  </div>
}
