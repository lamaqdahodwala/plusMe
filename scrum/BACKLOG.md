#  Project Backlog
Contains all tasks that relate to the project. This is the single source of all work for the project. If it's not on here, it isn't getting done. 

1. Build a basic running web application
- Implement user authentication and have "Sign Up" and "Log In" pages. This can be done with Supabase
    - Allow for OAuth (i.e. "Sign in with Google")
- Implement relevant database tables for our app
    - User, with the fields `id`, `username`, `attendedEvents`, `friends`, `scheduledEvents`
    - Event, with the fields `name`, `description`, `organization`, `link`, `attendanceQRCode`, `attendees`, `address` (or coordinates `location`), `tags`, `startTime`, `duration`
    - Organization, with the fields `members`, `events`, `description`, `socialMediaChannels`
    - Tag, with the fields `name`
- Implement CRUD functionality with respect to events 
    - Allow manual creation of events by an organization
    - Allow users to RSVP for events
    - Allow users to see events that they have signed up for on a calendar view


2. Build a system to autocreate `Event`s by scraping Instagram posts
- Over all organizations that have provided their `socialMediaChannels`, iterate through their newest posts
- Use an AI agent to detect whether or not something is an ad for an event, and then populate an `Event` record
    - Can use data from the caption - fill in common locations like "BSC" -> Busch Student Center, and capture date and time


