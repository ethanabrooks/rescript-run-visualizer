CREATE OR REPLACE FUNCTION public.empty_sweeps() 
RETURNS SETOF sweep
LANGUAGE sql 
STABLE AS
$function$
    select * 
    from sweep
    where sweep.id 
    not in (
     select distinct sweep_id 
     from run 
     where id in (
      select distinct run_id 
      from run_log
     )
     and sweep_id is not null
    )
 $function$;
