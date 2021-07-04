CREATE FUNCTION filter_runs2(  object jsonb)
RETURNS SETOF run AS $$
    SELECT *
    FROM run
    WHERE
metadata @> object
$$ LANGUAGE sql STABLE;
