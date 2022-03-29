CREATE OR REPLACE FUNCTION public.logs_with_episode_success()
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE log ? 'episode success'
$function$;
