## Project Configuration

- **Language**: TypeScript
- **Package Manager**: pnpm
- **Add-ons**: prettier, eslint, tailwindcss, ai-tools, storybook, sveltekit-adapter, playwright

---

You are able to use the Svelte MCP server, where you have access to comprehensive Svelte 5 and SvelteKit documentation. Here's how to use the available tools effectively:

## Available Svelte MCP Tools:

### 1. list-sections

Use this FIRST to discover all available documentation sections. Returns a structured list with titles, use_cases, and paths.
When asked about Svelte or SvelteKit topics, ALWAYS use this tool at the start of the chat to find relevant sections.

### 2. get-documentation

Retrieves full documentation content for specific sections. Accepts single or multiple sections.
After calling the list-sections tool, you MUST analyze the returned documentation sections (especially the use_cases field) and then use the get-documentation tool to fetch ALL documentation sections that are relevant for the user's task.

### 3. svelte-autofixer

Analyzes Svelte code and returns issues and suggestions.
You MUST use this tool whenever writing Svelte code before sending it to the user. Keep calling it until no issues or suggestions are returned.

### 4. playground-link

Generates a Svelte Playground link with the provided code.
After completing the code, ask the user if they want a playground link. Only call this tool after user confirmation and NEVER if code was written to files in their project.


## What is this app? 

This app is called "+me." It is a social app intended to give students of Rutgers University a unified hub for all campus activities and engagement. 

The app has two main sections: a "Schedule" tab where users can keep track of events they and their friends are going to,
and a "Community Events" tab where users can see recommended events based on their major, year, interests, and past events.
Users will also have access to an AI agent that can plan out their day/week. The agent will remember the user's interactions with it to 
give more personalized responses. 

A central feature of this app is that it will autopopulate campus events from social platforms like Instagram. AI agents will extract information 
like location, time, date, and organization from an Instagram post, and create a corresponding listing on our platform. Users may submit their club/organization
to be considered for autopopulation. 

The app also has a social feature: you can see where your friends are planning to go and join them. 

## Conventions

This project uses a component-based architecture and test-driven development. Ensure that `.svelte` files are *single responsibility*. Code that is not immediately relevant for the purposes
of the component should be moved into a new file or into its own component. With this, you should be able to keep the length of `.svelte` files below 100 lines of code. 

Test-driven development means that you write tests for your code before writing the implementation. Vitest, Playwright, and Storybook are all provided to make rigorous testing 
feasible. Follow "red-green-refactor." Write a failing test first, write implementation to make it passing, then refactor the code to make it as readable as possible. 
Remember to avoid testing implementation details when you write tests. Use user-validated examples of correct outputs given inputs. 


