@module("./Chart.jsx") external make: string => React.element = "make"

@react.component
let make = (~message): React.element => make(message)
