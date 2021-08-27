
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
