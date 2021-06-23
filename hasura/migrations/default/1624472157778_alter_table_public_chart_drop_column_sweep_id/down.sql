alter table "public"."chart"
  add constraint "chart_sweep_id_fkey"
  foreign key (sweep_id)
  references "public"."sweep"
  (id) on update no action on delete no action;
alter table "public"."chart" alter column "sweep_id" drop not null;
alter table "public"."chart" add column "sweep_id" int4;
