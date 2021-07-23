
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
