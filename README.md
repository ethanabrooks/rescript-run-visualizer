# Welcome to run-visualizer!
This is a website for visualizing runs logged in a [run-tracker/hasura](https://github.com/run-tracker/hasura) database.

# Usage

Begin by [setting up your Hasura database](https://github.com/run-tracker/hasura).

Next ensure that you have installed [docker-compose](https://docs.docker.com/compose/).

Next we clone this repository and run

```
docker-compose build \
  --build-arg NODE_GRAPHQL_ENDPOINT=server.university.edu:1200/v1/graphql \
  --build-arg NODE_MAX_LOGS=20000 \
  --build-arg NODE_MAX_SWEEPS=50 
```
Replacing the `NODE_GRAPHQL_ENDPOINT`  value with your Hasura GraphQL endpoint.
Finally run:
```
docker-compose up -d
```
Check that the image is running by running
```
docker ps
```
The site should be available at `https://current.host.edu:8081`, 
where `current.host.edu` is the address of the machine that you are using and `8081` is the port identified on the third line.

Now check that the docker container is running:
```
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                       NAMES
5b00d20b6523   ethanabrooks/run-visualizer    "/docker-entrypoint.…"   3 seconds ago   Up 3 seconds   0.0.0.0:8081->80/tcp, :::8081->80/tcp       quirky_brahmagupta
```
## Environment variables

### `NODE_GRAPHQL_ENDPOINT`
This is the endpoint for your Hasura GraphQL API. You can check this
by running `hasura console` per [these instructions](https://github.com/run-tracker/hasura#access-the-hasura-console) and checking the API tab. It should look something like `http://server.university.edu:1200/v1/graphql`.


### `NODE_MAX_LOGS`
This determines the number of logs that are displayed per chart.
If the number of logs in the database exceeds this number, 
`run-visualizer` will skip logs at regular intervals in order
to bring the log count below `NODE_MAX_LOGS` (e.g. it will skip every
other or every third log). 

This will distort the appearance of logs but a lower `NODE_MAX_LOGS`
value may be necessary for performance reasons and to prevent chrome from displaying Error code: 5.

### `NODE_MAX_SWEEPS`
This determines the number of sweeps to be displayed simultaneously 
in the side bar on the left. Users can view older sweeps by clicking 
the › character at the bottom of the sidebar. As with `NODE_MAX_LOGS`
this value should be adjusted to match the performance of the
local machine where you will be viewing the website.

# Developers

To [update the GraphQL schema](https://github.com/reasonml-community/graphql-ppx#schema):
```
npx get-graphql-schema ENDPOINT_URL -j > graphql_schema.json
```
