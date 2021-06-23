#! /usr/bin/env bash
docker exec -i hasura_postgres_1 pg_dumpall -c -U postgres > "/shared/home/ethanbro/rldl1-postgres-backup/$(date +'%d').sql"
