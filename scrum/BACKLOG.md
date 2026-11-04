#  Project Backlog
Contains all tasks that relate to the project. This is the single source of all work for the project. If it's not on here, it isn't getting done. 

1. Build a basic running web application
- Implement user authentication and have "Sign Up" and "Log In" pages. This can be done with Supabase
    - Allow for OAuth (i.e. "Sign in with Google")
- Implement relevant database tables for our app
    - University/College, with the fields `cid, `name`
    - User, with the fields `uid`, `username`, `profile_pic`, `personal_email`, `created_at`
    - UserEmails, with the fields `uid`, `emid`, `email`, `email_type`, `verified`, `created_at`
    - UserUnis, with the fields `affid`, `uid`, `cid`
    - Friendships with the fields `uid1`, `uid2` (uid1 < uid2)
    - Event, with the fields `eid`, `name`, `description`, `organization_id`, `link`, `attendanceQRCode`, `address`, `startTime`, `duration`
    - Organization, with the fields `oid`, `name`, `description`, `socialMediaChannels`, `cid`
    - Tag, with the fields `tid`, `name`
    - EventAttendance, with the fields `uid`, `eid`, `status`, `registered_at`
    - OrgMembers, with the fields `oid`, `uid`, `role`
    - EventTags, with the fields `eid`, `tid`, `tag`
    - TagFollowers, with the fields `uid`, `tid`, `followed_at`

- Implement CRUD functionality with respect to events 
    - Allow manual creation of events by an organization
    - Allow users to RSVP for events
    - Allow users to see events that they have signed up for on a calendar view


2. Build a system to autocreate `Event`s by scraping Instagram posts
- Over all organizations that have provided their `socialMediaChannels`, iterate through their newest posts
- Use an AI agent to detect whether or not something is an ad for an event, and then populate an `Event` record
    - Can use data from the caption - fill in common locations like "BSC" -> Busch Student Center, and capture date and time


