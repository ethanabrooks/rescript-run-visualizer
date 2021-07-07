@react.component
let make = (~text: string, ~dispatch, ~labelText, ~textAreaClassName) => {
  <div className="py-5">
    <label className="text-sm font-sm text-gray-700"> {labelText->React.string} </label>
    <input
      type_={"text"}
      onChange={evt => dispatch(ReactEvent.Form.target(evt)["value"])}
      className={textAreaClassName}
      value={text}
    />
  </div>
}
