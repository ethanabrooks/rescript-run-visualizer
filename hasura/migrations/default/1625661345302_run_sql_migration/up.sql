CREATE OR REPLACE FUNCTION sweep_metadata_path(path text[])
RETURNS TEXT AS $$
  SELECT metadata#>>'{"name"}'
  FROM sweep
$$ LANGUAGE sql STABLE;
