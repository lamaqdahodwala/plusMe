SET local check_function_bodies = off;

ALTER TABLE "public"."EventAttendance"
  DROP CONSTRAINT "EventAttendance_uid_fkey";

ALTER TABLE "public"."EventOrganizations"
  DROP CONSTRAINT "EventOrganizations_eid_fkey";

ALTER TABLE "public"."EventOrganizations"
  DROP CONSTRAINT "EventOrganizations_oid_cid_fkey";

ALTER TABLE "public"."EventTag"
  DROP CONSTRAINT "EventTag_tid_fkey";

ALTER TABLE "public"."Friendships"
  DROP CONSTRAINT "Friendships_uid1_fkey";

ALTER TABLE "public"."Friendships"
  DROP CONSTRAINT "Friendships_uid2_fkey";

ALTER TABLE "public"."OrgMembers"
  DROP CONSTRAINT "OrgMembers_oid_cid_fkey";

ALTER TABLE "public"."OrgMembers"
  DROP CONSTRAINT "OrgMembers_uid_fkey";

ALTER TABLE "public"."TagFollowers"
  DROP CONSTRAINT "TagFollowers_tid_fkey";

ALTER TABLE "public"."TagFollowers"
  DROP CONSTRAINT "TagFollowers_uid_fkey";

ALTER TABLE "public"."User"
  DROP CONSTRAINT "User_uid_fkey";

ALTER TABLE "public"."UserEmails"
  DROP CONSTRAINT "UserEmails_uid_fkey";

ALTER TABLE "public"."UserUnis"
  DROP CONSTRAINT "UserUnis_cid_fkey";

ALTER TABLE "public"."UserUnis"
  DROP CONSTRAINT "UserUnis_uid_fkey";

CREATE TABLE "public"."ScheduleBlocks" (
  "seid"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "uid"              uuid                     NOT NULL,
  "title"            text                     NOT NULL,
  "type"             text                     NOT NULL,
  "once_start"       timestamp with time zone,
  "once_end"         timestamp with time zone,
  "days_of_week"     integer[],
  "recur_start_date" date,
  "recur_end_date"   date,
  "start_time"       time without time zone,
  "end_time"         time without time zone,
  "timezone"         text                     NOT NULL DEFAULT 'America/New_York'::text,
  CONSTRAINT "ScheduleBlocks_days_check" CHECK (((days_of_week IS NULL) OR (days_of_week <@ ARRAY[1, 2, 3, 4, 5, 6, 7]))),
  CONSTRAINT "ScheduleBlocks_one_time_check" CHECK (((type <> 'one_time'::text) OR ((once_start IS NOT NULL) AND (once_end IS NOT NULL) AND (once_end > once_start)))),
  CONSTRAINT "ScheduleBlocks_pkey" PRIMARY KEY (seid),
  CONSTRAINT "ScheduleBlocks_type_check" CHECK ((type = ANY (ARRAY['one_time'::text, 'weekly'::text]))),
  CONSTRAINT "ScheduleBlocks_weekly_check" CHECK (((type <> 'weekly'::text) OR ((days_of_week IS NOT NULL) AND (cardinality(days_of_week) > 0) AND (recur_start_date IS
    NOT NULL) AND (recur_end_date IS NOT NULL) AND (recur_end_date >= recur_start_date) AND (start_time IS NOT NULL) AND (end_time IS NOT NULL) AND (end_time > start_time))))
);

ALTER TABLE "public"."ScheduleBlocks"
  ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
DECLARE
  new_username text;
BEGIN
  -- Get username from signup metadata, or generate a fallback
  new_username := COALESCE(
    NULLIF(BTRIM(new.raw_user_meta_data ->> 'username'), ''),
    NULLIF(SPLIT_PART(COALESCE(new.email, ''), '@', 1), ''),
    'student'
  );

  -- Create the user's profile
  INSERT INTO public."User" (
    uid,
    username,
    profile_pic
  )
  VALUES (
    new.id,
    new_username,
    NULLIF(BTRIM(new.raw_user_meta_data ->> 'profile_pic'), '')
  )
  ON CONFLICT (username) DO NOTHING;

  -- If username already exists, append a unique suffix
  IF NOT FOUND THEN
    INSERT INTO public."User" (
      uid,
      username,
      profile_pic
    )
    VALUES (
      new.id,
      new_username || '_' || LEFT(REPLACE(new.id::text, '-', ''), 8),
      NULLIF(BTRIM(new.raw_user_meta_data ->> 'profile_pic'), '')
    );
  END IF;

  -- Store the authentication email
  IF new.email IS NOT NULL THEN
    INSERT INTO public."UserEmails" (
      uid,
      email,
      email_type,
      verified
    )
    VALUES (
      new.id,
      new.email,
      CASE
        WHEN LOWER(SPLIT_PART(new.email, '@', 2))
          IN ('rutgers.edu', 'scarletmail.rutgers.edu')
        THEN 'rutgers'
        ELSE 'other'
      END,
      new.email_confirmed_at IS NOT NULL
    )
    ON CONFLICT (email) DO NOTHING;
  END IF;

  RETURN new;
END;
$function$;

REVOKE ALL ON FUNCTION "public"."handle_new_user"() FROM "anon", "authenticated", "service_role";

CREATE OR REPLACE FUNCTION public.validate_rutgers_email()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO ''
  AS $function$
BEGIN
  IF NEW.email IS NULL
     OR LOWER(BTRIM(NEW.email)) !~ '^[^@]+@(rutgers\.edu|scarletmail\.rutgers\.edu)$'
  THEN
    RAISE EXCEPTION
      'Please use a valid Rutgers email address (@rutgers.edu or @scarletmail.rutgers.edu).';
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION "public"."validate_rutgers_email"() FROM "anon", "authenticated", "service_role";

ALTER TABLE "public"."EventAttendance"
  ADD CONSTRAINT "EventAttendance_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_eid_fkey" FOREIGN KEY (eid) REFERENCES public."Event"(eid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."EventOrganizations"
  ADD CONSTRAINT "EventOrganizations_oid_cid_fkey" FOREIGN KEY (oid, cid) REFERENCES public."Organization"(oid, cid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."EventTag"
  ADD CONSTRAINT "EventTag_tid_fkey" FOREIGN KEY (tid) REFERENCES public."Tag"(tid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."Friendships"
  ADD CONSTRAINT "Friendships_uid1_fkey" FOREIGN KEY (uid1) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."Friendships"
  ADD CONSTRAINT "Friendships_uid2_fkey" FOREIGN KEY (uid2) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_oid_cid_fkey" FOREIGN KEY (oid, cid) REFERENCES public."Organization"(oid, cid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."OrgMembers"
  ADD CONSTRAINT "OrgMembers_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."ScheduleBlocks"
  ADD CONSTRAINT "ScheduleBlocks_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."TagFollowers"
  ADD CONSTRAINT "TagFollowers_tid_fkey" FOREIGN KEY (tid) REFERENCES public."Tag"(tid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."TagFollowers"
  ADD CONSTRAINT "TagFollowers_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."User"
  ADD CONSTRAINT "User_uid_fkey" FOREIGN KEY (uid) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."UserEmails"
  ADD CONSTRAINT "UserEmails_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."UserUnis"
  ADD CONSTRAINT "UserUnis_cid_fkey" FOREIGN KEY (cid) REFERENCES public."University/College"(cid) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "public"."UserUnis"
  ADD CONSTRAINT "UserUnis_uid_fkey" FOREIGN KEY (uid) REFERENCES public."User"(uid) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER validate_rutgers_email_trigger
  BEFORE INSERT OR UPDATE OF email ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_rutgers_email();

CREATE POLICY "Users manage their own schedules" ON "public"."ScheduleBlocks"
  FOR ALL
  TO "authenticated"
  USING ((auth.uid() = uid))
  WITH CHECK ((auth.uid() = uid));

CREATE POLICY "Users can update their own profile" ON "public"."User"
  FOR UPDATE
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = uid))
  WITH CHECK ((( SELECT auth.uid() AS uid) = uid));

CREATE POLICY "Users can view their own profile" ON "public"."User"
  FOR SELECT
  TO "authenticated"
  USING ((( SELECT auth.uid() AS uid) = uid));

CREATE POLICY "Anyone can upload an avatar." ON "storage"."objects"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((bucket_id = 'avatars'::text));

CREATE POLICY "Avatar images are publicly accessible." ON "storage"."objects"
  FOR SELECT
  TO PUBLIC
  USING (((bucket_id = 'avatars'::text) AND storage.allow_any_operation(ARRAY['object.get_authenticated_info'::text, 'object.get_authenticated'::text])));

GRANT EXECUTE ON FUNCTION "public"."handle_new_user"() TO PUBLIC;

REVOKE ALL ON FUNCTION "public"."handle_new_user"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."handle_new_user"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."validate_rutgers_email"() TO PUBLIC;

REVOKE ALL ON FUNCTION "public"."validate_rutgers_email"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."validate_rutgers_email"() TO "postgres";

REVOKE ALL ON TABLE "public"."ScheduleBlocks" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."ScheduleBlocks" TO "anon";

REVOKE ALL ON TABLE "public"."ScheduleBlocks" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."ScheduleBlocks" TO "authenticated";

REVOKE ALL ON TABLE "public"."ScheduleBlocks" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ScheduleBlocks" TO "postgres";

REVOKE ALL ON TABLE "public"."ScheduleBlocks" FROM "service_role";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."ScheduleBlocks" TO "service_role";

