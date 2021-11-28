CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n = 0
$function$;
