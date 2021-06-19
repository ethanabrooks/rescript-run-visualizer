open Belt

@react.component
let make = (~buttons) => {
  <div className="flex">
    <span className="relative z-0 inline-flex">
      {buttons
      ->Array.mapWithIndex((i, button) => <div key={i->Int.toString}> {button} </div>)
      ->React.array}
    </span>
  </div>
}
