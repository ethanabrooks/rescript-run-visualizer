module TodosQuery = %graphql(`
  query TodosQuery {
    run {
      id
    }
  }
`)

@react.component
let make = () => {
  let x = TodosQuery.use()
  Js.log(x)
  <div> {"hello"->React.string} </div>
}
