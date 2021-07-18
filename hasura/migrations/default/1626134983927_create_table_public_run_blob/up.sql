CREATE TABLE "public"."run_blob" ("id" serial NOT NULL, "run_id" integer NOT NULL, "blob" bytea NOT NULL, PRIMARY KEY ("id") , UNIQUE ("id"));
