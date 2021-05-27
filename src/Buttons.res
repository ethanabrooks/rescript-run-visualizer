open Belt
type button = {text: string, onClick: ReactEvent.Mouse.t => unit, disabled: bool}
type buttons = array<button>

@react.component
let make = (~buttons: buttons) => {
  <div className="flex">
    <span className="relative z-0 inline-flex">
      {buttons
      ->Array.mapWithIndex((i, {text, onClick, disabled}) =>
        <button key={i->Int.toString} type_="button" onClick disabled className="button">
          {text->React.string}
        </button>
      )
      ->React.array}
    </span>
  </div>
}
