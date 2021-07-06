-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION logs_less_than_step(max_step integer)
RETURNS SETOF run_log AS $$
    SELECT *
    FROM run_log
    WHERE (log->>'step') = '192000'
$$ LANGUAGE sql STABLE;
