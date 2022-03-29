
SET check_function_bodies = false;
CREATE FUNCTION public.add(integer, integer) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$select $1 + $2;$_$;
CREATE FUNCTION public.filter_metadata(value text) RETURNS jsonb
    LANGUAGE sql
    AS $$ select metadata from sweep where metadata->'config'->'seed'->1 = '0' $$;
CREATE TABLE public.run (
    id integer NOT NULL,
    sweep_id integer,
    metadata jsonb,
    archived boolean DEFAULT false NOT NULL
);
CREATE FUNCTION public.filter_runs(object jsonb DEFAULT NULL::jsonb, path text[] DEFAULT NULL::text[], pattern text DEFAULT '%'::text) RETURNS SETOF public.run
    LANGUAGE sql STABLE
    AS $_$
    SELECT *
    FROM run
    WHERE ($1 IS NULL OR metadata @> object)
    AND   ($2 IS NULL OR metadata #>>path like pattern)
$_$;
CREATE TABLE public.sweep (
    id integer NOT NULL,
    grid_index integer,
    metadata jsonb,
    archived boolean DEFAULT false NOT NULL
);
CREATE FUNCTION public.filter_sweeps(object jsonb DEFAULT NULL::jsonb, path text[] DEFAULT NULL::text[], pattern text DEFAULT '%'::text) RETURNS SETOF public.sweep
    LANGUAGE sql STABLE
    AS $_$
    SELECT *
    FROM sweep
    WHERE ($1 IS NULL OR metadata @> object)
    AND   ($2 IS NULL OR metadata #>>path like pattern)
$_$;
CREATE FUNCTION public.increment(i integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
                RETURN i + 1;
        END;
$$;
CREATE TABLE public.run_log (
    id integer NOT NULL,
    run_id integer NOT NULL,
    log jsonb NOT NULL
);
CREATE FUNCTION public.logs_less_than_step(max_step integer) RETURNS SETOF public.run_log
    LANGUAGE sql STABLE
    AS $$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::INTEGER <= max_step
$$;
CREATE FUNCTION public.sweep_metadata_path(sweep public.sweep, path text[]) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT metadata#>>path
  FROM sweep
$$;
CREATE FUNCTION public.test(sweep public.sweep) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT metadata#>>'{name}'
  FROM sweep
$$;
CREATE TABLE public.chart (
    id integer NOT NULL,
    run_id integer,
    spec jsonb NOT NULL,
    archived boolean DEFAULT false NOT NULL
);
CREATE SEQUENCE public.chart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.chart_id_seq OWNED BY public.chart.id;
CREATE TABLE public.parameter_choices (
    sweep_id integer NOT NULL,
    "Key" text NOT NULL,
    choice jsonb[] NOT NULL
);
CREATE SEQUENCE public.run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.run_id_seq OWNED BY public.run.id;
CREATE SEQUENCE public.run_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.run_log_id_seq OWNED BY public.run_log.id;
CREATE SEQUENCE public.sweep_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.sweep_id_seq OWNED BY public.sweep.id;
ALTER TABLE ONLY public.chart ALTER COLUMN id SET DEFAULT nextval('public.chart_id_seq'::regclass);
ALTER TABLE ONLY public.run ALTER COLUMN id SET DEFAULT nextval('public.run_id_seq'::regclass);
ALTER TABLE ONLY public.run_log ALTER COLUMN id SET DEFAULT nextval('public.run_log_id_seq'::regclass);
ALTER TABLE ONLY public.sweep ALTER COLUMN id SET DEFAULT nextval('public.sweep_id_seq'::regclass);
ALTER TABLE ONLY public.chart
    ADD CONSTRAINT chart_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.parameter_choices
    ADD CONSTRAINT "parameter_choices_sweep_id_Key_key" UNIQUE (sweep_id, "Key");
ALTER TABLE ONLY public.run_log
    ADD CONSTRAINT run_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.sweep
    ADD CONSTRAINT sweep_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.chart
    ADD CONSTRAINT chart_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.run(id);
ALTER TABLE ONLY public.parameter_choices
    ADD CONSTRAINT parameter_choices_sweep_id_fkey FOREIGN KEY (sweep_id) REFERENCES public.sweep(id);
ALTER TABLE ONLY public.run_log
    ADD CONSTRAINT run_log_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.run(id);
ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_sweep_id_fkey FOREIGN KEY (sweep_id) REFERENCES public.sweep(id);

CREATE TABLE "public"."run_blob" ("id" serial NOT NULL, "run_id" integer NOT NULL, "blob" bytea NOT NULL, PRIMARY KEY ("id") , UNIQUE ("id"));

alter table "public"."run_blob"
  add constraint "run_blob_run_id_fkey"
  foreign key ("run_id")
  references "public"."run"
  ("id") on update no action on delete no action;

CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::BIGINT <= max_step
$function$;

DROP FUNCTION "public"."logs_less_than_step"("pg_catalog"."int4");

CREATE OR REPLACE FUNCTION public.logs_less_than_step(max_step integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log->>'step')::BIGINT <= max_step
$function$;



CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs(max_step integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

drop FUNCTION public.non_sweep_runs();

drop FUNCTION public.non_sweep_runs;

CREATE OR REPLACE FUNCTION public.non_sweep_runs()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

DROP FUNCTION "public"."non_sweep_runs";

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE sweep_id not in (select id from sweep);
$function$;

DROP FUNCTION "public"."non_sweep_run";

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE sweep_id not in (select id from sweep);
$function$;

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run 
    WHERE sweep_id IS NULL 
    OR sweep_id NOT IN (SELECT id FROM SWEEP);
$function$;

DROP FUNCTION "public"."non_sweep_run";

CREATE OR REPLACE FUNCTION public.non_sweep_run()
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run 
    WHERE sweep_id IS NULL 
    OR sweep_id NOT IN (SELECT id FROM SWEEP);
$function$;

alter table "public"."sweep" add column "run_count" serial
 not null;

alter table "public"."sweep" alter column "run_count" set default '0';

CREATE OR REPLACE FUNCTION public.empty_sweeps() 
RETURNS SETOF sweep
LANGUAGE sql 
STABLE AS
$function$
    select * 
    from sweep
    where sweep.id 
    not in (
     select distinct sweep_id 
     from run 
     where id in (
      select distinct run_id 
      from run_log
     )
     and sweep_id is not null
    )
 $function$;

alter table "public"."sweep" rename column "run_count" to "remaining_runs";

alter table "public"."sweep" alter column "remaining_runs" drop not null;


CREATE FUNCTION has_logs(sweep_row sweep)
RETURNS boolean AS $$
  SELECT sweep_row.id not in (
    select
      distinct sweep_id
    from
      run
    where
      id in (
        select
          distinct run_id
        from
          run_log
      )
      and sweep_id is not null
    )
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION has_logs(sweep_row sweep)
RETURNS Boolean AS $$
  SELECT sweep_row.id not in (
    select
      distinct sweep_id
    from
      run
    where
      id in (
        select
          distinct run_id
        from
          run_log
      )
      and sweep_id is not null
    )
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION has_logs(sweep_row sweep)
RETURNS Boolean AS $$
  SELECT sweep_row.id not in (
    select
      distinct sweep_id
    from
      run
    where
      id in (
        select
          distinct run_id
        from
          run_log
      )
      and sweep_id is not null
    )
$$ LANGUAGE sql STABLE;

CREATE
OR REPLACE FUNCTION public.archive_empty_sweeps() 
RETURNS void LANGUAGE sql STABLE AS $function$
update
  sweep
set archived = true
where
  sweep.id not in (
    select
      distinct sweep_id
    from
      run
    where
      id in (
        select
          distinct run_id
        from
          run_log
      )
      and sweep_id is not null
  ) $function$;

CREATE FUNCTION author_full_name(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

drop function author_full_name;

CREATE FUNCTION author_full_name(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

CREATE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION bytea_to_text(run_blob)
RETURNS TEXT AS $$
  SELECT encode($1.blob, 'escape')
$$ LANGUAGE sql STABLE;

alter table "public"."run_blob" add column "metadata" jsonb
 null;

CREATE OR REPLACE FUNCTION public.last_n_runs(n integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id IN (
    select run_id
from run_log
group by run_id
order by MAX(run_log.id) DESC
limit n
)
$function$;

CREATE OR REPLACE FUNCTION public.last_n_runs(n integer)
 RETURNS SETOF run
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run
    WHERE id IN (
    select run_id
from run_log
group by run_id
order by MAX(run_log.id) DESC
limit n
)
$function$;

CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n = 0
$function$;

CREATE OR REPLACE FUNCTION public.except_every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n != 0
$function$;

CREATE OR REPLACE FUNCTION public.except_every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n != 0
$function$;

CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n = 0
$function$;

CREATE OR REPLACE FUNCTION public.every_nth_run_log(n integer)
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE run_log.id % n = 0
$function$;

alter table "public"."chart" add column "order" integer
 null;

alter table "public"."chart" add column "name" text
 null;

CREATE OR REPLACE FUNCTION public.logs_with_episode_success()
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE log ? 'episode success'
$function$;

CREATE OR REPLACE FUNCTION public.logs_with_episode_success_or_test_episode_success()
 RETURNS SETOF run_log
 LANGUAGE sql
 STABLE
AS $function$
    SELECT *
    FROM run_log
    WHERE (log ? 'episode success' OR log ? 'test episode success')
$function$;
