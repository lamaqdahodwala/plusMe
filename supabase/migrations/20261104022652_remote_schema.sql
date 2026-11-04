ALTER TABLE "public"."User"
  DROP CONSTRAINT "User_email_key";

ALTER TABLE "public"."User"
  DROP COLUMN "email";

CREATE TABLE "public"."UserEmails" (
  "uid"        uuid                     NOT NULL,
  "emid"       uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "email"      text                     NOT NULL,
  "email_type" text                     NOT NULL,
  "verified"   boolean                  DEFAULT false,
  "created_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "UserEmails_email_key" UNIQUE (email),
  CONSTRAINT "UserEmails_pkey" PRIMARY KEY (uid, emid)
);

ALTER TABLE "public"."UserEmails"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."UserUnis" (
  "affid" uuid NOT NULL DEFAULT gen_random_uuid(),
  "uid"   uuid NOT NULL,
  "cid"   uuid NOT NULL,
  CONSTRAINT "UserUnis_pkey" PRIMARY KEY (affid)
);

ALTER TABLE "public"."UserUnis"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."User"
  ADD COLUMN "personal_email" text;

ALTER TABLE "public"."User"
  ADD COLUMN "created_at" timestamp WITH time zone NOT NULL DEFAULT now();

ALTER TABLE "public"."UserEmails"
  ADD CONSTRAINT "UserEmails_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid);

ALTER TABLE "public"."UserUnis"
  ADD CONSTRAINT "UserUnis_cid_fkey" FOREIGN KEY (cid) REFERENCES public."University/College"(cid);

ALTER TABLE "public"."UserUnis"
  ADD CONSTRAINT "UserUnis_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid);

COMMENT ON COLUMN "public"."UserUnis"."cid" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."UserUnis"."uid" IS '[SENSITIVE]';

REVOKE ALL ON TABLE "public"."UserEmails" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserEmails" TO "anon";

REVOKE ALL ON TABLE "public"."UserEmails" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserEmails" TO "authenticated";

REVOKE ALL ON TABLE "public"."UserEmails" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."UserEmails" TO "postgres";

REVOKE ALL ON TABLE "public"."UserEmails" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserEmails" TO "service_role";

REVOKE ALL ON TABLE "public"."UserUnis" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserUnis" TO "anon";

REVOKE ALL ON TABLE "public"."UserUnis" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserUnis" TO "authenticated";

REVOKE ALL ON TABLE "public"."UserUnis" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."UserUnis" TO "postgres";

REVOKE ALL ON TABLE "public"."UserUnis" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."UserUnis" TO "service_role";

