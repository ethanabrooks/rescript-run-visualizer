## Launch site locally
Define the environment variable `NODE_GRAPHQL_ENDPOINT` as the `[host]:[post]`
of your GraphQL server, e.g. `rldl100.eecs.umich.edu:8080`. Then run:
```
yarn
yarn dev
```
To set up Hasura, see `hasura/README.md`.

To [update the GraphQL schema](https://github.com/reasonml-community/graphql-ppx#schema):
```
npx get-graphql-schema ENDPOINT_URL -j > graphql_schema.json
```