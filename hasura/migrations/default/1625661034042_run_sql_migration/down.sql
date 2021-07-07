-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE FUNCTION log_path(path text[])
RETURNS TEXT AS $$
  SELECT log#>>path
  FROM run_log
$$ LANGUAGE sql STABLE;
