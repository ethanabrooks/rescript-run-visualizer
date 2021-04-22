let query = gql`
  query UserQuery {
    user {
      id
      name
    }
  }
`

@react.component
let make = (): React.element => <Chart message={"hello"} />
