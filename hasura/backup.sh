#! /usr/bin/env bash
docker exec -i hasura_postgres_1 pg_dumpall -c -U postgres > "$1/$(date +'%d').sql"
