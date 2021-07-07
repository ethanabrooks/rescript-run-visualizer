CREATE OR REPLACE FUNCTION test(sweep sweep)
RETURNS TEXT AS $$
  SELECT metadata#>>'{name}'
  FROM sweep
$$ LANGUAGE sql STABLE;
