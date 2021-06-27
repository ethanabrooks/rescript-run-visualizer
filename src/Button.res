let className = "m-1 z-0 inline-flex px-3 py-2 rounded-md border border-gray-300 text-sm font-medium bg-white text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:outline-none disabled:opacity-50 disabled:cursor-default w-28 items-center justify-center"
@react.component
let make = (~text: string, ~onClick: ReactEvent.Mouse.t => unit, ~disabled: bool) =>
  <button type_="button" onClick disabled className> {text->React.string} </button>
