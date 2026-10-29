ALTER TABLE "public"."EventOrganizations"
  DROP CONSTRAINT "EventOrganizations_oid_fkey";

ALTER TABLE "public"."EventOrganizations"
  DROP CONSTRAINT "EventOrganizations_pkey";

ALTER TABLE "public"."OrgMembers"
  DROP CONSTRAINT "OrgMembers_oid_fkey";

ALTER TABLE "public"."OrgMembers"
  DROP CONSTRAINT "OrgMembers_pkey";

ALTER TABLE "public"."Organization"
  DROP CONSTRAINT "Organization_pkey";

CREATE TABLE "public"."University/College" (
  "cid"  uuid NOT NULL DEFAULT gen_random_uuid(),
  "name" text NOT NULL,
  CONSTRAINT "University/College_name_key" UNIQUE (name),
  CONSTRAINT "University/College_pkey" PRIMARY KEY (cid)
);

ALTER TABLE "public"."University/College"
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."EventOrganizations"
  ADD COLUMN "cid" uuid NOT NULL;

ALTER TABLE "public"."OrgMembers"
  ADD COLUMN "cid" uuid NOT NULL;

ALTER TABLE "public"."Organization"
  ADD COLUMN "cid" uuid NOT NULL;

ALTER TABLE "public"."Organization"
  ALTER COLUMN "name" DROP NOT NULL;

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_pkey" PRIMARY KEY (eid, oid, cid);

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_pkey" PRIMARY KEY (oid, uid, cid);

ALTER TABLE "public"."Organization"
  ADD CONSTRAINT "Organization 2_pkey" PRIMARY KEY (oid, cid);

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_oid_cid_fkey" FOREIGN KEY (oid, cid) REFERENCES public."Organization"(oid, cid);

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_oid_cid_fkey" FOREIGN KEY (oid, cid) REFERENCES public."Organization"(oid, cid);

ALTER TABLE "public"."Organization"
  ADD CONSTRAINT "Organization 2_cid_fkey" FOREIGN KEY (cid) REFERENCES public."University/College"(cid);

COMMENT ON COLUMN "public"."EventOrganizations"."cid" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."Organization"."cid" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."Organization"."oid" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."University/College"."cid" IS '[SENSITIVE]';

REVOKE ALL ON TABLE "public"."University/College" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."University/College" TO "anon";

REVOKE ALL ON TABLE "public"."University/College" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."University/College" TO "authenticated";

REVOKE ALL ON TABLE "public"."University/College" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."University/College" TO "postgres";

REVOKE ALL ON TABLE "public"."University/College" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."University/College" TO "service_role";

