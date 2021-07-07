CREATE OR REPLACE FUNCTION sweep_metadata_path(sweep sweep, path text[])
RETURNS TEXT AS $$
  SELECT metadata#>>path
  FROM sweep
$$ LANGUAGE sql STABLE;
