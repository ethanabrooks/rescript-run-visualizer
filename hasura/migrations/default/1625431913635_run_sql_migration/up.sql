CREATE OR REPLACE FUNCTION public.filter_sweeps(object jsonb DEFAULT NULL::jsonb, path text[] DEFAULT NULL::text[], pattern text DEFAULT '%'::text)
 RETURNS SETOF sweep
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM sweep
    WHERE ($1 IS NULL OR metadata @> object)
    AND   ($2 IS NULL OR metadata #>>path like pattern)
$function$;
