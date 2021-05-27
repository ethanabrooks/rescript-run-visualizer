open Belt
type button = {text: string, onClick: ReactEvent.Mouse.t => unit, disabled: bool}
type buttons = array<button>

@react.component
let make = (~buttons: buttons) => {
  <div className="flex justify-end">
    <span className="relative z-0 inline-flex">
      {buttons
      ->Array.map(({text, onClick, disabled}) =>
        <button type_="button" onClick disabled className="button"> {text->React.string} </button>
      )
      ->React.array}
    </span>
  </div>
}
