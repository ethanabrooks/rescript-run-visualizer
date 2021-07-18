CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::BIGINT <= max_step
$function$;
