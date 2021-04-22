@module("./chart.jsx") external f: unit => string = "f"
@module("./chart.jsx") external example: unit => React.element = "Example"

@react.component
let make = (): React.element => example()
