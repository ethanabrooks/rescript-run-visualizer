open Belt

@react.component
let make = (~buttons) => {
  <span className="flex flex-row relative items-center z-0">
    {buttons
    ->Array.mapWithIndex((i, button) => <div key={i->Int.toString}> {button} </div>)
    ->React.array}
  </span>
}
