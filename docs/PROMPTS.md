# Example Prompts for Vibe Coding

Real prompts that produce real results. Each one assumes you have a proper `CLAUDE.md` and rules files loaded (which this repo provides).

---

## Scaffolding

### New Next.js Project

```
Scaffold a new Next.js 15 project with TypeScript, Tailwind CSS, shadcn/ui,
and Supabase auth. Include the scroll-aware navbar, dark mode globals.css,
and a hero section on the homepage. Follow the design system in CLAUDE.md.
```

### New Cloudflare Worker + D1 API

```
Create a Cloudflare Worker with D1 that serves a REST API for a bookmarks app.
Tables: bookmarks (id, url, title, description, tags, created_at) and
tags (id, name). Include CORS, error handling, pagination on list endpoints,
and full CRUD. Use prepared statements for all queries.
```

### New API Route

```
Add a POST /api/feedback route that accepts { message, email, page }
in the body. Validate with Zod, insert into a Supabase "feedback" table,
and return 201 on success. Follow the API rules.
```

---

## Feature Building

### Dashboard Page

```
Build a dashboard page at /dashboard that shows:
1. Total users (big number with gradient text)
2. Active projects in a card grid (3 columns, each card shows name, status badge, last updated)
3. Recent activity feed (list of last 10 events with timestamps)
Use React Query to fetch from /api/dashboard. Include skeleton loaders for all three sections.
```

### Auth Flow

```
Add Supabase email/password auth to this project:
1. /login page with email + password form
2. /signup page with email + password + name
3. Middleware that redirects unauthenticated users from /dashboard to /login
4. A UserButton component in the navbar showing avatar + dropdown with sign out
Use React Hook Form + Zod for validation. Follow the component and form patterns in the rules.
```

### Search with D1

```
Add a search endpoint GET /api/search?q=term that searches across items.name
and items.description using LIKE queries. Return max 20 results sorted by
relevance (exact match first, then partial). Include the search query
highlighted in results.
```

---

## Debugging

### Systematic Debug

```
I'm getting "TypeError: Cannot read properties of null (reading 'id')" on
line 47 of src/routes/items.ts when calling GET /api/items/999. The item
doesn't exist in the database. Trace the code path, find where the null
check is missing, and fix it. Don't change the API contract.
```

### Performance Issue

```
The /dashboard page takes 4 seconds to load. The page fetches from three
API routes sequentially. Refactor to fetch all three in parallel using
Promise.all, add proper loading states for each section, and make sure
errors in one section don't break the others.
```

---

## Database

### New Migration

```
Create a D1 migration that adds a "projects" table with:
- id (integer, primary key, autoincrement)
- name (text, not null)
- description (text, nullable)
- status (text, default 'active', check constraint: active/archived/completed)
- owner_id (integer, foreign key to users.id)
- created_at and updated_at (text, default datetime('now'))
Add indexes on status and owner_id.
```

### Drizzle Schema

```
Write a Drizzle ORM schema for a D1 database with these tables:
- users (id, email, name, avatar_url, created_at)
- posts (id, title, content, author_id FK to users, status enum, published_at, created_at)
- comments (id, post_id FK, author_id FK, body, created_at)
Include all relations. Export insert and select types.
```

---

## UI Design

### Landing Page

```
Build a landing page for "Vibe", a task management app for developers.
Sections: hero (headline about shipping faster), feature grid (3 cards:
AI task creation, GitHub integration, sprint tracking), pricing (free +
pro tiers), and CTA. Use the full design system. Make every section
visually distinct. Add scroll reveal animations.
```

### Component

```
Build a NotificationBell component that:
1. Shows a bell icon with a red dot when there are unread notifications
2. Opens a dropdown on click showing the last 5 notifications
3. Each notification has: icon, title, timestamp, and read/unread state
4. Clicking a notification marks it as read and navigates to the relevant page
Use shadcn/ui Popover for the dropdown. Include all states: loading, empty, error.
```

---

## Code Quality

### Audit

```
/audit
```

(The slash command handles the rest. It checks security, performance, accessibility, TypeScript strictness, and design compliance.)

### Refactor

```
Refactor src/routes/items.ts. It's 280 lines. Split into:
1. A query layer (db/items.ts) with typed functions for each operation
2. A validation layer (using Zod schemas)
3. Route handlers that compose the two
Keep the same API contract. No behavior changes.
```

---

## Deployment

### Full Deploy

```
/deploy
```

### Pre-deploy Check

```
Run the full pre-deploy checklist: typecheck, lint, build, check for
hardcoded localhost URLs, check for console.logs, verify all env vars
are set. Report any issues before I deploy.
```

---

## Tips for Better Prompts

1. **Be specific about the output.** "Build a card component" is vague. "Build a project card with name, status badge, member avatars, and last-updated timestamp, using glassmorphism styling" is actionable.

2. **Reference the context.** "Follow the design system" or "Use the API patterns from the rules" tells Claude to pull from your CLAUDE.md and rules files.

3. **Specify what NOT to do.** "Don't add authentication to this endpoint" or "Don't refactor the surrounding code" prevents scope creep.

4. **Include the data shape.** If Claude needs to know the database schema or API response format, include it or point to the file.

5. **One feature per prompt.** Compound prompts ("build the dashboard AND the settings page AND the notification system") produce shallow results. One feature at a time, reviewed and committed before moving on.
