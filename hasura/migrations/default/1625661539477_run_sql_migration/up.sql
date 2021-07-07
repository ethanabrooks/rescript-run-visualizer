CREATE OR REPLACE FUNCTION sweep_metadata_path(path text[])
RETURNS TEXT AS $$
  SELECT id::text
  FROM sweep
$$ LANGUAGE sql STABLE;
