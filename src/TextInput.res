@react.component
let make = (~initialText: string, ~dispatch) => {
  let (text, setText) = React.useState(_ => initialText)

  <div className="py-5">
    <label className="text-sm font-sm text-gray-700">
      {"Filter metadata keywords"->React.string}
    </label>
    <input
      type_={"text"}
      onChange={evt => {
        let text = ReactEvent.Form.target(evt)["value"]
        setText(_ => text)
        dispatch(text)
      }}
      className={"h-10 border p-4 shadow-sm block w-full sm:text-sm border-gray-300 rounded-md"}
      value={text}
    />
  </div>
}
