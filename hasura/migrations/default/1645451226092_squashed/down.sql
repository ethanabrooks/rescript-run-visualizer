
-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.logs_with_episode_success_or_test_episode_success()
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE (log ? 'episode success' OR log ? 'test episode success')
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.logs_with_episode_success()
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE log ? 'episode success'
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- alter table "public"."chart" add column "name" text
--  null;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- alter table "public"."chart" add column "order" integer
--  null;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE run_log.id % n = 0
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE run_log.id % n = 0
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.except_every_nth_run_log(n integer)
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE run_log.id % n != 0
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.except_every_nth_run_log(n integer)
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE run_log.id % n != 0
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
--  RETURNS SETOF run_log
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run_log
--     WHERE run_log.id % n = 0
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.last_n_runs(n integer)
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id IN (
--     select run_id
-- from run_log
-- group by run_id
-- order by MAX(run_log.id) DESC
-- limit n
-- )
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.last_n_runs(n integer)
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id IN (
--     select run_id
-- from run_log
-- group by run_id
-- order by MAX(run_log.id) DESC
-- limit n
-- )
-- $function$;


-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- alter table "public"."run_blob" add column "metadata" jsonb
 null;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION author_full_name(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- drop function author_full_name;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION author_full_name(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE
-- OR REPLACE FUNCTION public.archive_empty_sweeps()
-- RETURNS void LANGUAGE sql STABLE AS $function$
-- update
--   sweep
-- set archived = true
-- where
--   sweep.id not in (
--     select
--       distinct sweep_id
--     from
--       run
--     where
--       id in (
--         select
--           distinct run_id
--         from
--           run_log
--       )
--       and sweep_id is not null
--   ) $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION has_logs(sweep_row sweep)
-- RETURNS Boolean AS $$
--   SELECT sweep_row.id not in (
--     select
--       distinct sweep_id
--     from
--       run
--     where
--       id in (
--         select
--           distinct run_id
--         from
--           run_log
--       )
--       and sweep_id is not null
--     )
-- $$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION has_logs(sweep_row sweep)
-- RETURNS Boolean AS $$
--   SELECT sweep_row.id not in (
--     select
--       distinct sweep_id
--     from
--       run
--     where
--       id in (
--         select
--           distinct run_id
--         from
--           run_log
--       )
--       and sweep_id is not null
--     )
-- $$ LANGUAGE sql STABLE;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION has_logs(sweep_row sweep)
-- RETURNS boolean AS $$
--   SELECT sweep_row.id not in (
--     select
--       distinct sweep_id
--     from
--       run
--     where
--       id in (
--         select
--           distinct run_id
--         from
--           run_log
--       )
--       and sweep_id is not null
--     )
-- $$ LANGUAGE sql STABLE;

alter table "public"."sweep" alter column "remaining_runs" set not null;

alter table "public"."sweep" rename column "remaining_runs" to "run_count";

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.empty_sweeps()
-- RETURNS SETOF sweep
-- LANGUAGE sql
-- STABLE AS
-- $function$
--     select *
--     from sweep
--     where sweep.id
--     not in (
--      select distinct sweep_id
--      from run
--      where id in (
--       select distinct run_id
--       from run_log
--      )
--      and sweep_id is not null
--     )
--  $function$;

alter table "public"."sweep" alter column "run_count" set default nextval('sweep_run_count_seq'::regclass);

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- alter table "public"."sweep" add column "run_count" serial
--  not null;


-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE sweep_id IS NULL
--     OR sweep_id NOT IN (SELECT id FROM SWEEP);
-- $function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run 
    WHERE sweep_id IS NULL 
    OR sweep_id NOT IN (SELECT id FROM SWEEP);
$function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE sweep_id IS NULL
--     OR sweep_id NOT IN (SELECT id FROM SWEEP);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE sweep_id not in (select id from sweep);
-- $function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE sweep_id not in (select id from sweep);
$function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE sweep_id not in (select id from sweep);
-- $function$;


-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_run()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_runs()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- drop FUNCTION public.non_sweep_runs;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- drop FUNCTION public.non_sweep_runs();

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_runs()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_runs()
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
--  RETURNS SETOF run
--  LANGUAGE sql
--  STABLE
-- AS $function$
--     SELECT *
--     FROM run
--     WHERE id not in (select id from sweep);
-- $function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::BIGINT <= max_step
$function$;

CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::INTEGER <= max_step
$function$;

-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::BIGINT <= max_step
$function$;

alter table "public"."run_blob" drop constraint "run_blob_run_id_fkey";

DROP TABLE "public"."run_blob";
