@react.component
let make = (~text: string, ~onClick: ReactEvent.Mouse.t => unit, ~disabled: bool) =>
  <button type_="button" onClick disabled className="button"> {text->React.string} </button>
