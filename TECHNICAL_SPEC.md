
## Tech Stack: 

This app will use [Svelte](https://svelte.dev) and [SvelteKit](https://kit.svelte.dev) for most of the programming. These are both Javascript frameworks, so to use them, you will 
need to install [Node.js](https://nodejs.org).

To make the website look good, we will use TailwindCSS, a CSS framework that is very simple to use. 
We will use Supabase for user auth and for database storage. To interact with Supabase, we will use Prisma.

If we need python for the AI parts of the app, we can set up a web server using Flask or FastAPI that will serve our models. This will only happen if we cannot implement
what we want using just Javascript. In production, the two servers will communicate with each other using Docker and Docker compose.

We will use git for version control. 
