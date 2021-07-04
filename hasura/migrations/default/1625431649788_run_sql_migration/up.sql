CREATE FUNCTION filter_runs3()
RETURNS SETOF run AS $$
    SELECT *
    FROM run
--     WHERE
-- metadata @> object
$$ LANGUAGE sql STABLE;
