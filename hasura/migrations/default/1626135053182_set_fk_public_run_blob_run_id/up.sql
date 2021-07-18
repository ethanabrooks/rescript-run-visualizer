alter table "public"."run_blob"
  add constraint "run_blob_run_id_fkey"
  foreign key ("run_id")
  references "public"."run"
  ("id") on update no action on delete no action;
