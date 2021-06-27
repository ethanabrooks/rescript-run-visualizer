open Belt

@react.component
let make = (~buttons) => {
  <div className="mt-4 flex md:mt-0 md:ml-4">
    {buttons
    ->Array.mapWithIndex((i, button) => <div key={i->Int.toString}> {button} </div>)
    ->React.array}
  </div>
}
