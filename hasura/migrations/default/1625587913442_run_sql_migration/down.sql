-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION logs_less_than_step(max_step INTEGER)
RETURNS SETOF run_log AS $$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::INTEGER <= max_step
$$ LANGUAGE sql STABLE;
