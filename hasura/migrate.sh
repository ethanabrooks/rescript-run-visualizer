#! /usr/bin/env bash

# apply metadata, this will connect Hasura to the configured databases.
hasura metadata apply --endpoint "$1"
# apply migrations to the connected databases.
hasura migrate apply --all-databases --endpoint "$1"
# reload metadata to make sure Hasura is aware of any newly created database objects.
hasura metadata reload --endpoint "$1"
