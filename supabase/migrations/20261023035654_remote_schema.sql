SET local check_function_bodies = off;

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON SEQUENCES FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" REVOKE ALL ON TABLES FROM "service_role";

CREATE TABLE "public"."EventAttendance" (
  "uid"           uuid                     NOT NULL,
  "eid"           uuid                     NOT NULL,
  "status"        text,
  "registered_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "EventAttendance_pkey" PRIMARY KEY (uid, eid)
);

ALTER TABLE "public"."EventAttendance"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."EventOrganizations" (
  "eid" uuid NOT NULL,
  "oid" uuid NOT NULL,
  CONSTRAINT "EventOrganizations_pkey" PRIMARY KEY (eid, oid)
);

ALTER TABLE "public"."EventOrganizations"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."EventTag" (
  "eid" uuid NOT NULL,
  "tid" uuid NOT NULL,
  CONSTRAINT "EventTag_pkey" PRIMARY KEY (eid, tid)
);

ALTER TABLE "public"."EventTag"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."Event" (
  "eid"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"             text                     NOT NULL,
  "description"      text,
  "link"             text,
  "attendanceQRcode" text,
  "address"          text,
  "startTime"        timestamp with time zone NOT NULL,
  "duration"         bigint                   NOT NULL,
  CONSTRAINT "Event_pkey" PRIMARY KEY (eid)
);

ALTER TABLE "public"."Event"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."Friendships" (
  "uid1" uuid NOT NULL,
  "uid2" uuid NOT NULL,
  CONSTRAINT "Friendships_pkey" PRIMARY KEY (uid1, uid2)
);

ALTER TABLE "public"."Friendships"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."OrgMembers" (
  "oid"  uuid NOT NULL,
  "uid"  uuid NOT NULL,
  "role" text NOT NULL DEFAULT 'member'::text,
  CONSTRAINT "OrgMembers_pkey" PRIMARY KEY (oid, uid)
);

ALTER TABLE "public"."OrgMembers"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."Organization" (
  "oid"                 uuid  NOT NULL DEFAULT gen_random_uuid(),
  "name"                text  NOT NULL,
  "description"         text,
  "socialMediaChannels" jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT "Organization_pkey" PRIMARY KEY (oid)
);

ALTER TABLE "public"."Organization"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."TagFollowers" (
  "uid"         uuid                     NOT NULL,
  "tid"         uuid                     NOT NULL,
  "followed_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "TagFollowers_pkey" PRIMARY KEY (uid, tid)
);

ALTER TABLE "public"."TagFollowers"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."Tag" (
  "tid"  uuid NOT NULL DEFAULT gen_random_uuid(),
  "name" text NOT NULL,
  CONSTRAINT "Tag_name_key" UNIQUE (name),
  CONSTRAINT "Tag_pkey" PRIMARY KEY (tid)
);

ALTER TABLE "public"."Tag"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."User" (
  "uid"         uuid NOT NULL,
  "email"       text NOT NULL,
  "username"    text NOT NULL,
  "profile_pic" text,
  CONSTRAINT "User_email_key" UNIQUE (email),
  CONSTRAINT "User_pkey" PRIMARY KEY (uid),
  CONSTRAINT "User_username_key" UNIQUE (username)
);

ALTER TABLE "public"."User"
  ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
  RETURNS event_trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog'
  AS $function$
DECLARE
  cmd record;
  tbl name;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        SELECT c.relname INTO tbl FROM pg_catalog.pg_class c WHERE c.oid = cmd.objid;
        EXECUTE format('alter table if exists %I.%I enable row level security', cmd.schema_name, tbl);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$;

REVOKE ALL ON FUNCTION "public"."rls_auto_enable"() FROM "anon", "authenticated", "service_role";

ALTER TABLE "public"."EventAttendance"
  ADD CONSTRAINT "EventAttendance_eid_fkey" FOREIGN KEY (eid) REFERENCES public."Event"(eid);

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_eid_fkey" FOREIGN KEY (eid) REFERENCES public."Event"(eid);

ALTER TABLE "public"."EventTag"
  ADD CONSTRAINT "EventTag_eid_fkey" FOREIGN KEY (eid) REFERENCES public."Event"(eid);

ALTER TABLE "public"."Friendships"
  ADD CONSTRAINT "Friendships_uid1_fkey" FOREIGN KEY (uid1) REFERENCES auth.users(id);

ALTER TABLE "public"."Friendships"
  ADD CONSTRAINT "Friendships_uid2_fkey" FOREIGN KEY (uid2) REFERENCES auth.users(id);

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_oid_fkey" FOREIGN KEY (oid) REFERENCES public."Organization"(oid);

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_oid_fkey" FOREIGN KEY (oid) REFERENCES public."Organization"(oid);

ALTER TABLE "public"."EventTag"
  ADD CONSTRAINT "EventTag_tid_fkey" FOREIGN KEY (tid) REFERENCES public."Tag"(tid);

ALTER TABLE "public"."TagFollowers"
  ADD CONSTRAINT "TagFollowers_tid_fkey" FOREIGN KEY (tid) REFERENCES public."Tag"(tid);

ALTER TABLE "public"."EventAttendance"
  ADD CONSTRAINT "EventAttendance_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid);

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid);

ALTER TABLE "public"."TagFollowers"
  ADD CONSTRAINT "TagFollowers_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid);

ALTER TABLE "public"."User"
  ADD CONSTRAINT "User_uid_fkey" FOREIGN KEY (uid) REFERENCES auth.users(id);

CREATE EVENT TRIGGER "ensure_rls"
  ON ddl_command_end
  WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
  EXECUTE FUNCTION "public"."rls_auto_enable"();

COMMENT ON COLUMN "public"."Friendships"."uid1" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."Friendships"."uid2" IS '[SENSITIVE]';

COMMENT ON COLUMN "public"."User"."email" IS '[SENSITIVE]';

GRANT EXECUTE ON FUNCTION "public"."rls_auto_enable"() TO PUBLIC;

REVOKE ALL ON FUNCTION "public"."rls_auto_enable"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."rls_auto_enable"() TO "postgres";

REVOKE ALL ON TABLE "public"."Event" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Event" TO "anon";

REVOKE ALL ON TABLE "public"."Event" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Event" TO "authenticated";

REVOKE ALL ON TABLE "public"."Event" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Event" TO "postgres";

REVOKE ALL ON TABLE "public"."Event" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Event" TO "service_role";

REVOKE ALL ON TABLE "public"."EventAttendance" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventAttendance" TO "anon";

REVOKE ALL ON TABLE "public"."EventAttendance" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventAttendance" TO "authenticated";

REVOKE ALL ON TABLE "public"."EventAttendance" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."EventAttendance" TO "postgres";

REVOKE ALL ON TABLE "public"."EventAttendance" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventAttendance" TO "service_role";

REVOKE ALL ON TABLE "public"."EventOrganizations" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventOrganizations" TO "anon";

REVOKE ALL ON TABLE "public"."EventOrganizations" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventOrganizations" TO "authenticated";

REVOKE ALL ON TABLE "public"."EventOrganizations" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."EventOrganizations" TO "postgres";

REVOKE ALL ON TABLE "public"."EventOrganizations" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventOrganizations" TO "service_role";

REVOKE ALL ON TABLE "public"."EventTag" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventTag" TO "anon";

REVOKE ALL ON TABLE "public"."EventTag" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventTag" TO "authenticated";

REVOKE ALL ON TABLE "public"."EventTag" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."EventTag" TO "postgres";

REVOKE ALL ON TABLE "public"."EventTag" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."EventTag" TO "service_role";

REVOKE ALL ON TABLE "public"."Friendships" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Friendships" TO "anon";

REVOKE ALL ON TABLE "public"."Friendships" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Friendships" TO "authenticated";

REVOKE ALL ON TABLE "public"."Friendships" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Friendships" TO "postgres";

REVOKE ALL ON TABLE "public"."Friendships" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Friendships" TO "service_role";

REVOKE ALL ON TABLE "public"."OrgMembers" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."OrgMembers" TO "anon";

REVOKE ALL ON TABLE "public"."OrgMembers" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."OrgMembers" TO "authenticated";

REVOKE ALL ON TABLE "public"."OrgMembers" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."OrgMembers" TO "postgres";

REVOKE ALL ON TABLE "public"."OrgMembers" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."OrgMembers" TO "service_role";

REVOKE ALL ON TABLE "public"."Organization" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Organization" TO "anon";

REVOKE ALL ON TABLE "public"."Organization" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Organization" TO "authenticated";

REVOKE ALL ON TABLE "public"."Organization" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Organization" TO "postgres";

REVOKE ALL ON TABLE "public"."Organization" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Organization" TO "service_role";

REVOKE ALL ON TABLE "public"."Tag" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Tag" TO "anon";

REVOKE ALL ON TABLE "public"."Tag" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Tag" TO "authenticated";

REVOKE ALL ON TABLE "public"."Tag" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."Tag" TO "postgres";

REVOKE ALL ON TABLE "public"."Tag" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."Tag" TO "service_role";

REVOKE ALL ON TABLE "public"."TagFollowers" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."TagFollowers" TO "anon";

REVOKE ALL ON TABLE "public"."TagFollowers" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."TagFollowers" TO "authenticated";

REVOKE ALL ON TABLE "public"."TagFollowers" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."TagFollowers" TO "postgres";

REVOKE ALL ON TABLE "public"."TagFollowers" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."TagFollowers" TO "service_role";

REVOKE ALL ON TABLE "public"."User" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."User" TO "anon";

REVOKE ALL ON TABLE "public"."User" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."User" TO "authenticated";

REVOKE ALL ON TABLE "public"."User" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."User" TO "postgres";

REVOKE ALL ON TABLE "public"."User" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."User" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "anon";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "authenticated";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLES TO "service_role";

