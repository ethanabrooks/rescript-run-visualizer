switch ReactDOM.querySelector("#main") {
| Some(root) => ReactDOM.render(<App />, root)
| None => () // do nothing
}
