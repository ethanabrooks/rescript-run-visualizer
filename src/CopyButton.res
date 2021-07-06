@react.component
let make = (~text, ~copyString, ~className, ~disabled) => {
  let (copied, setCopied) = React.useState(_ => false)
  <button
    className
    onClick={_ => {
      setCopied(_ => true)
      Js.Global.setTimeout(_ => setCopied(_ => false), 1000)->ignore
      copyString->Util.copy->ignore
    }}
    disabled>
    {(copied ? "Copied" : text)->React.string}
  </button>
}
