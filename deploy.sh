#! /usr/bin/env bash
if [ -z ${NODE_GRAPHQL_ENDPOINT} ]
then
  echo NODE_GRAPHQL_ENDPOINT must be defined
  exit
fi
docker-compose build --build-arg ENDPOINT="$NODE_GRAPHQL_ENDPOINT"
docker-compose up -d
