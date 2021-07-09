#! /usr/bin/env bash
docker-compose build --build-arg ENDPOINT="$NODE_GRAPHQL_ENDPOINT"
docker-compose up -d
