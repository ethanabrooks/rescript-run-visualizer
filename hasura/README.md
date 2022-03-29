## Set up a database on a server
Follow [these
instructions](https://hasura.io/docs/latest/graphql/core/getting-started/docker-simple.html)
on the server of interest (not on localhost).

 ## Import Hasura setup
This will use a Hasura migration. First
you need to determine the ip-address of the server where the database is running.

Next apply our metadata to the enpoint:
```
hasura metadata apply
```
Now we apply any saved migrations to the connected databases:
```
hasura migrate apply --all-databases
```
Finally we reload the metadata:
```
hasura metadata reload
```
The port is `8080` by default, but you can double check this by looking in the
`docker-compose.yml` file that you ran on the database server. This will add the appropriate tables and relations to your GraphQL endpoint. You can check this by running
```
hasura console
```
On the DATA tab, you should see the appropriate Database(s) and table(s) in the
left column. 

## Backup data
On the database server, run
```
docker exec hasura_postgres_1 pg_dump -U postgres -d postgres > [output-file]
```
This command makes a few assumptions which are true by default:

 - Your Postgres container is named `hasura_postgres_1` is the the container
   running Postgres. You can confirm this by running `docker ps`.
 - Both your Postgres username and database name is `postgres` (true per the
   default `docker-compose.yml`)

One way to perform regular backups is to run this command periodically using a `cron` job.

## Restore data
First follow the steps described in 
[Set up a database on a server](#set-up-a-database-on-a-server).
Next run
```
docker exec -i hasura_postgres_1 psql -U postgres -d postgres < [backup-file]
```
This will load the actual data into the postgres database backing hasura.
Finally run
```
hasura metadata apply
```
