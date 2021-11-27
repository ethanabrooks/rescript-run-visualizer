CREATE OR REPLACE FUNCTION public.last_n_runs(n integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id IN (
    select run_id
from run_log
group by run_id
order by MAX(run_log.id) DESC
limit n
)
$function$;
