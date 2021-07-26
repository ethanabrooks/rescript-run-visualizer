CREATE
OR REPLACE FUNCTION public.archive_empty_sweeps() 
RETURNS void LANGUAGE sql STABLE AS $function$
update
  sweep
set archived = true
where
  sweep.id not in (
    select
      distinct sweep_id
    from
      run
    where
      id in (
        select
          distinct run_id
        from
          run_log
      )
      and sweep_id is not null
  ) $function$;
