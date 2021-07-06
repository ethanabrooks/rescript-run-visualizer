CREATE FUNCTION sweep_logs_less_than_step(ids integer[], max_step integer = NULL)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE ids @> ARRAY[id]
    AND ($2 is NULL or ((metadata->>'step')::integer) < max_step)
$$ LANGUAGE sql STABLE;
