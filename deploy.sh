#! /usr/bin/env bash
if [ -z ${NODE_GRAPHQL_ENDPOINT} ]
then
  echo NODE_GRAPHQL_ENDPOINT must be defined
  exit
fi
if [ -z ${NODE_MAX_SWEEPS} ]
then
  echo NODE_MAX_SWEEPS must be defined
  exit
fi
if [ -z ${NODE_MAX_LOGS} ]
then
  echo NODE_MAX_LOGS must be defined
  exit
fi
docker-compose build \
  --build-arg NODE_GRAPHQL_ENDPOINT="$NODE_GRAPHQL_ENDPOINT" \
  --build-arg NODE_MAX_SWEEPS="$NODE_MAX_SWEEPS" \
  --build-arg NODE_MAX_LOGS="$NODE_MAX_LOGS"
docker-compose up -d
