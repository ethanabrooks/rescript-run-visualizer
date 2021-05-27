let useText = (~valid: string => bool, ~initialText: string) => {
  let (text, setText) = React.useState(_ => initialText)

  let textAreaClassName =
    "focus:outline-none border shadow w-full rounded-md"->Js.String2.concat(
      text->valid ? " focus:border-indigo-500 " : " focus:border-red-300",
    )
  let component =
    <textarea
      rows=10
      onChange={evt => setText(_ => ReactEvent.Form.target(evt)["value"])}
      className={textAreaClassName}
      placeholder={"Enter new vega spec"}
      value={text}
    />
  (text, component)
}
