

CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

drop FUNCTION public.non_sweep_runs();

drop FUNCTION public.non_sweep_runs;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

DROP FUNCTION "public"."non_sweep_runs";

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE sweep_id not in (select id from sweep);
$function$;

DROP FUNCTION "public"."non_sweep_run";

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE sweep_id not in (select id from sweep);
$function$;

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

DROP FUNCTION "public"."non_sweep_run";

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
