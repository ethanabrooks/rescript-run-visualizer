CREATE OR REPLACE FUNCTION public.logs_with_episode_success_or_test_episode_success()
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log ? 'episode success' OR log ? 'test episode success')
$function$;
