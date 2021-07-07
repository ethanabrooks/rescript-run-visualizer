-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION sweep_metadata_path(path text[])
RETURNS TEXT AS $$
  SELECT metadata#>>'{"name"}'
  FROM sweep
$$ LANGUAGE sql STABLE;
