CREATE OR REPLACE FUNCTION logs_less_than_step(max_step integer)
RETURNS SETOF run_log AS $$
    SELECT *
    FROM run_log
    -- WHERE (log->>'step')::integer < max_step
$$ LANGUAGE sql STABLE;
