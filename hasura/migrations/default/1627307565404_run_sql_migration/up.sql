CREATE OR REPLACE FUNCTION has_logs(sweep_row sweep)
RETURNS Boolean AS $$
  SELECT sweep_row.id not in (
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
    )
$$ LANGUAGE sql STABLE;
