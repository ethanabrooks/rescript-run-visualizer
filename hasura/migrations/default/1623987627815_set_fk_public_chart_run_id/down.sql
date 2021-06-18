alter table "public"."chart" drop constraint "chart_run_id_fkey",
  add constraint "chart_run_id_fkey"
  foreign key ("run_id")
  references "public"."run"
  ("id") on update cascade on delete cascade;
