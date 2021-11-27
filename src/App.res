@val external graphqlEndpoint: string = "NODE_GRAPHQL_ENDPOINT"

let headers = {"Authorization": "There are a bunch of ways to get a token in here"}

// This is a link to handle websockets (used by subscriptions)
let wsLink = {
  open ApolloClient.Link.WebSocketLink
  make(
    ~uri="ws://" ++ graphqlEndpoint,
    ~options=ClientOptions.make(
      // Auth headers
      ~connectionParams=ConnectionParams(Obj.magic({"headers": headers})),
      ~reconnect=true,
      (),
    ),
    (),
  )
}

// client enables us to make queries to Hasura
let client: ApolloClient__Core_ApolloClient.t = {
  open ApolloClient
  make(
    ~cache=Cache.InMemoryCache.make(),
    ~connectToDevTools=true,
    ~defaultOptions=DefaultOptions.make(
      ~mutate=DefaultMutateOptions.make(~awaitRefetchQueries=true, ~errorPolicy=All, ()),
      ~query=DefaultQueryOptions.make(~fetchPolicy=NetworkOnly, ~errorPolicy=All, ()),
      ~watchQuery=DefaultWatchQueryOptions.make(~fetchPolicy=NetworkOnly, ~errorPolicy=All, ()),
      (),
    ),
    ~link=wsLink,
    (),
  )
}

@react.component
let make = (): React.element =>
  <ApolloClient.React.ApolloProvider client> <Router client /> </ApolloClient.React.ApolloProvider>
