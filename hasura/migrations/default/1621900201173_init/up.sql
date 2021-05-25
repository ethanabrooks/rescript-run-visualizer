SET check_function_bodies = false;
CREATE TABLE public.chart (
    id integer NOT NULL,
    run_id integer,
    sweep_id integer,
    spec jsonb NOT NULL
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
    choice json[] NOT NULL
);
CREATE TABLE public.run (
    id integer NOT NULL,
    sweep_id integer,
    metadata json
);
CREATE SEQUENCE public.run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.run_id_seq OWNED BY public.run.id;
CREATE TABLE public.run_log (
    id integer NOT NULL,
    run_id integer NOT NULL,
    log jsonb NOT NULL
);
CREATE SEQUENCE public.run_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.run_log_id_seq OWNED BY public.run_log.id;
CREATE TABLE public.sweep (
    id integer NOT NULL,
    grid_index integer,
    metadata json
);
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
ALTER TABLE ONLY public.chart
    ADD CONSTRAINT chart_sweep_id_fkey FOREIGN KEY (sweep_id) REFERENCES public.sweep(id);
ALTER TABLE ONLY public.parameter_choices
    ADD CONSTRAINT parameter_choices_sweep_id_fkey FOREIGN KEY (sweep_id) REFERENCES public.sweep(id);
ALTER TABLE ONLY public.run_log
    ADD CONSTRAINT run_log_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.run(id);
ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_sweep_id_fkey FOREIGN KEY (sweep_id) REFERENCES public.sweep(id);
