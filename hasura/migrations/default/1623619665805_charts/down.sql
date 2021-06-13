
ALTER TABLE "public"."run" ALTER COLUMN "metadata" TYPE json;

ALTER TABLE "public"."parameter_choices" ALTER COLUMN "choice" TYPE ARRAY;

ALTER TABLE "public"."sweep" ALTER COLUMN "metadata" TYPE json;
