alter table "public"."sweep" alter column "run_count" set default nextval('sweep_run_count_seq'::regclass);
