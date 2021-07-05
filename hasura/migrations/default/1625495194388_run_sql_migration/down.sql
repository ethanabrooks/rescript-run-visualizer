-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION my_function(texts text[])
RETURNS SETOF run AS $$
    SELECT *
    FROM run
$$ LANGUAGE sql STABLE;
