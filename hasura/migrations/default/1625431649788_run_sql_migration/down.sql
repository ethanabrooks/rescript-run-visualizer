-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION filter_runs3()
RETURNS SETOF run AS $$
    SELECT *
    FROM run
--     WHERE
-- metadata @> object
$$ LANGUAGE sql STABLE;
