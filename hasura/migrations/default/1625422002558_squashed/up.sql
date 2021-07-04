

DROP FUNCTION "public"."search_articles"("pg_catalog"."int4");

DROP FUNCTION "public"."search_sweeps"("pg_catalog"."int4");

CREATE or REPLACE FUNCTION search_sweeps(arg integer)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE id < arg;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION search_sweeps(arg integer)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE id < arg;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION search_sweeps(arg integer)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE metadata->>'name' like '%';
$$ LANGUAGE sql STABLE;

DROP FUNCTION "public"."search_sweeps"("pg_catalog"."int4");

CREATE or REPLACE FUNCTION search_sweeps(arg text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE metadata->>'name' like arg;
$$ LANGUAGE sql STABLE;

DROP FUNCTION "public"."search_sweeps"("pg_catalog"."text");

CREATE or REPLACE FUNCTION search_sweeps(arg jsonb)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE metadata @> arg;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION search_sweeps(arg jsonb)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE metadata @> arg;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_contains(path jsonb)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE metadata @> path;
$$ LANGUAGE sql STABLE;

DROP FUNCTION "public"."search_sweeps"("pg_catalog"."jsonb");

CREATE or REPLACE FUNCTION filter_metadata_path_like(path jsonb, pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata->>'b' like pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path jsonb, pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>'{a,2}' like pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>'{a,2}' = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>'{a,2}' = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>'{a,2}' = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah2(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = 'a';
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah3(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION blah3(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = pattern;
$$ LANGUAGE sql STABLE;

drop function filter_metadata_path_like(path text[], pattern text);

CREATE or REPLACE FUNCTION filter_metadata_path_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = pattern;
$$ LANGUAGE sql STABLE;

CREATE or REPLACE FUNCTION filter_metadata_like(path text[], pattern text)
RETURNS SETOF sweep AS $$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path = pattern;
$$ LANGUAGE sql STABLE;

DROP FUNCTION "public"."blah"("pg_catalog"."_text", "pg_catalog"."text");

DROP FUNCTION "public"."blah2"("pg_catalog"."_text", "pg_catalog"."text");

DROP FUNCTION "public"."blah3"("pg_catalog"."_text", "pg_catalog"."text");

drop function public.filter_metadata_path_like(path jsonb, pattern text);

drop function public.filter_metadata_path_like(path text[], pattern text);

drop function public.search_sweeps2(arg integer);


CREATE OR REPLACE FUNCTION public.filter_metadata_like(path text[], pattern text)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$function$;

DROP FUNCTION "public"."filter_metadata_like"("pg_catalog"."_text", "pg_catalog"."text");

CREATE OR REPLACE FUNCTION public.filter_metadata_like(path text[], pattern text)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$function$;

CREATE OR REPLACE FUNCTION public.filter_sweep_metadata_contains(path jsonb)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE metadata @> path;
$function$;

CREATE OR REPLACE FUNCTION public.filter_sweep_metadata_like(path text[], pattern text)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$function$;

CREATE OR REPLACE FUNCTION public.filter_sweep_metadata_like(path text[], pattern text)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE  metadata#>>path like pattern;
$function$;

CREATE OR REPLACE FUNCTION public.filter_run_metadata_like(path text[], pattern text)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE  metadata#>>path like pattern;
$function$;

CREATE OR REPLACE FUNCTION public.filter_run_metadata_like(path text[], pattern text)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE  metadata#>>path like pattern;
$function$;

CREATE OR REPLACE FUNCTION public.filter_run_metadata_contains(path jsonb)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE metadata @> path;
$function$;

DROP FUNCTION "public"."filter_metadata_contains"("pg_catalog"."jsonb");

CREATE OR REPLACE FUNCTION public.filter_run_metadata_contains(path jsonb)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE metadata @> path;
$function$;

CREATE OR REPLACE FUNCTION public.filter_run_metadata_contains(path jsonb)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE metadata @> path;
$function$;

DROP FUNCTION "public"."filter_metadata_like"("pg_catalog"."_text", "pg_catalog"."text");
