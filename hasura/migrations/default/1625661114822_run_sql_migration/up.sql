CREATE OR REPLACE FUNCTION log_path(path text[])
RETURNS TEXT AS $$
  SELECT log->>'name'
  FROM run_log
$$ LANGUAGE sql STABLE;
