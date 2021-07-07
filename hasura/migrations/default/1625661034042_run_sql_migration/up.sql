CREATE FUNCTION log_path(path text[])
RETURNS TEXT AS $$
  SELECT log#>>path
  FROM run_log
$$ LANGUAGE sql STABLE;
