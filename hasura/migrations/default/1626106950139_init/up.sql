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
