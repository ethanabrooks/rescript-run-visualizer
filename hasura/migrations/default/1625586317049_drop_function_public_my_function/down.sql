CREATE OR REPLACE FUNCTION public.my_function(texts text[])
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
$function$;
