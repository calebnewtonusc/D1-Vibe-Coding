# D1 Vibe Coding

A complete Claude Code setup for developers who ship. Drop it in and your AI pair programmer immediately writes better code, builds better UIs, and follows consistent patterns. Run one command to get your entire development infrastructure wired up: personal second brain, iMessage agent, and all context synced to GitHub automatically.

## What you get

**36 slash commands** covering the full dev lifecycle: scaffold, push, deploy, audit, PR lifecycle, daily planning, sprint tracking, design review, testing, debugging, and more.

**18+ rules files** auto-injected as context based on file type: security, API patterns, component standards, database, deployment, naming, performance, state management, accessibility, TypeScript, design, testing, and UX laws.

**A full design system** (`CLAUDE.md`) that makes every generated UI look like a funded startup's product page. Dark mode, shadcn/ui, Tailwind, scroll-aware navbar, and real typography, all enforced on every generation.

**A second brain system** that splits your personal context into two repos: a public `claude-context` for operational instructions (zero PII) and a private `{your-name}-context` for personal facts. Claude loads your identity, current projects, and priorities every session automatically.

**Hooks** that auto-format files after every write, sync context to GitHub on every edit, warn before touching `.env`, and load your Todoist priorities at session start.

**iMessage agent** wired in out of the box: reads your chat history, understands your contacts, and sends messages via AppleScript.

---

## Full infrastructure setup (recommended)

One command. Creates everything from scratch.

```bash
git clone https://github.com/calebnewtonusc/D1-Vibe-Coding
cd D1-Vibe-Coding
chmod +x setup.sh && ./setup.sh
```

The setup script collects your name, GitHub username, and API keys, then:

1. Creates `{your-name}-context` (private GitHub repo) with personal brain templates: `YOU.md`, `NOW.md`, `PEOPLE.md`, `SYSTEM.md`, `STACK.md`
2. Creates `claude-context` (public GitHub repo) with D1 operational instructions: CLAUDE.md, all commands, rules, and hooks
3. Clones your iMessage agent into your workspace and wires the MCP config
4. Writes `~/.claude/settings.json` with all hooks: SessionStart (loads your context + Todoist priorities), PostToolUse (auto-formats and auto-syncs both context repos), Stop (push reminder), Notification
5. Configures Composio MCP if you have a URL

You end up with three repos and a fully wired Claude setup. Every session starts with your full context loaded. Every edit to your context files auto-commits and auto-pushes.

---

## Quick install (project-level only)

Just want CLAUDE.md and the commands/rules in an existing project:

```bash
chmod +x install.sh && ./install.sh /path/to/your/project
```

Or from within your project:

```bash
curl -fsSL https://raw.githubusercontent.com/calebnewtonusc/D1-Vibe-Coding/main/install.sh | bash
```

For full infrastructure (second brain + iMessage + MCP), run `setup.sh` instead.

---

## The slash commands

| Command           | What it does                                                   |
| ----------------- | -------------------------------------------------------------- |
| `/new-project`    | Scaffold Next.js + shadcn/ui + Tailwind + all deps in one shot |
| `/push`           | Secret scan, smart commit message, push                        |
| `/deploy`         | Quality gate + Vercel deploy                                   |
| `/ship`           | Typecheck + lint + tests before any merge                      |
| `/audit`          | Security scan + code quality + design quality                  |
| `/pr-shepherd`    | Full PR lifecycle: review, fix, CI, merge                      |
| `/respond-pr`     | Read all review comments, implement fixes, reply with SHAs     |
| `/fix-issue`      | Fetch GitHub issue, branch, research, implement, commit        |
| `/review-pr`      | Deep code review with inline comments                          |
| `/review`         | Review current file or selection                               |
| `/daily-brief`    | Today's tasks + GitHub PRs + focused plan                      |
| `/morning`        | Morning standup: yesterday, today, blockers                    |
| `/close-loop`     | End-of-session: commit, push, log, set up tomorrow             |
| `/standup`        | Generate standup from git log                                  |
| `/changelog`      | Changelog from git log since last tag                          |
| `/cleanup`        | Remove dead code, console.logs, unused imports                 |
| `/deps`           | Check outdated, unused, vulnerable dependencies                |
| `/env-check`      | Compare `.env.example` vs `.env` to find gaps                  |
| `/sprint`         | Today's task breakdown by priority                             |
| `/todo`           | Add a task from natural language                               |
| `/done`           | Mark a task complete                                           |
| `/inbox`          | Process all open tasks + emails + PRs                          |
| `/build`          | Run build checks and fix errors                                |
| `/test`           | Write or run tests for the current feature                     |
| `/debug`          | Systematic debug protocol: read error, trace, fix              |
| `/trace`          | Trace a bug to its root cause                                  |
| `/refactor`       | Refactor selected code cleanly                                 |
| `/design`         | Design review against the D1 design system                     |
| `/api`            | Scaffold a new API route with validation                       |
| `/database`       | Scaffold migration, types, and query functions                 |
| `/context-update` | Manually trigger context file sync                             |
| `/scratchpad`     | Capture quick ideas                                            |
| `/imovie`         | AirDrop-to-iMovie automation helpers                           |

---

## The second brain

Two repos. Hard boundary between operational and personal.

```
claude-context/      PUBLIC — how Claude should behave
                     CLAUDE.md, rules/, commands/, hooks/
                     Zero personal info. Safe to share.

{name}-context/      PRIVATE — who you are and what you're working on
                     YOU.md, NOW.md, PEOPLE.md, SYSTEM.md, STACK.md
                     Never make this public.
```

Claude loads your personal context every session via the `SessionStart` hook. Every time Claude writes to a context file, the `PostToolUse` hook auto-commits and auto-pushes. Your brain stays current without you touching it.

See [second-brain/README.md](second-brain/README.md) for full architecture details.

---

## The design system

The `CLAUDE.md` is the core. It enforces:

- **Dark mode by default**: `#0a0a0a` background, `zinc-950` surfaces
- **shadcn/ui always**: never raw `<button>` or `<input>` from scratch
- **Lucide React icons**: never emoji, never text characters as icons
- **Scroll-aware navbar on every project**: hidden at top, slides in after 80px, hides near page bottom
- **Typography hierarchy**: Inter/Geist, `text-5xl font-bold tracking-tight` heroes, proper scale
- **Cards and buttons with hover states**: every interactive element
- **Loading/empty/error states**: never blank white space
- **Responsive layouts**: mobile-first, `max-w-7xl` containers

Before shipping any UI, ask: does this look like a YC-backed startup's product page? If not, rebuild it.

---

## The rules files

Each file is auto-loaded as context when Claude touches matching files:

- **security.md**: parameterized queries, RLS, no secrets in logs, auth ownership checks
- **api.md**: Next.js App Router routes, Zod validation, consistent error shapes
- **components.md**: shadcn/ui enforcement, skeleton/empty/error state patterns
- **database.md**: Supabase conventions, RLS policies, migration workflow
- **deployment.md**: Vercel deploy workflow, pre-deploy checklist
- **naming.md**: file, variable, DB, API, branch naming conventions
- **performance.md**: `next/image`, `next/font`, Server Components, bundle size
- **state.md**: React Query for server state, URL state, Zustand for shared UI
- **accessibility.md**: semantic HTML, focus management, WCAG contrast, ARIA
- **typescript.md**: strict mode patterns, Zod integration, no `any`
- **design.md**: D1 design system, color, typography, components
- **writing.md**: copy standards, no em dashes, no AI slop
- **scroll-effects.md**: CSS scroll animations, IntersectionObserver, parallax
- **testing.md**: unit, integration, and E2E testing patterns
- **ux-laws.md**: Hick's, Fitts's, Miller's, and other UX laws applied
- **review-discipline.md**: code review standards and checklists
- **audit.md**: pre-ship audit checklist
- **git.md**: commit format, branch naming, PR rules

---

## The hooks

```
SessionStart         →  load personal context + Todoist priorities into every session
PostToolUse Write    →  auto-format on save + sync context repos to GitHub
PreToolUse Write     →  warn before touching .env files
Stop                 →  remind to push to GitHub + surface TODOs
Notification         →  voice alerts via macOS say command
```

The `PostToolUse` hook watches your `{name}-context/` and `claude-context/` directories. Any write auto-commits and pushes. You never fall out of sync.

---

## Stack assumptions

This kit is optimized for:

- **Next.js 14+** (App Router)
- **Tailwind CSS**
- **shadcn/ui**
- **Supabase** (auth + database)
- **Vercel** (deployment)
- **TypeScript** (strict mode)
- **GitHub** (via `gh` CLI)
- **Anthropic Claude** (`claude-sonnet-4-6` default)

---

## Ecosystem and resources

The vibe coding landscape is growing fast. We maintain a curated map of the entire ecosystem.

**[ECOSYSTEM.md](ECOSYSTEM.md)** covers:

- 7 awesome lists aggregating hundreds of vibe-coded projects
- Vibe coding platforms and SDKs (VibeSDK, context engineering templates)
- Workflow and orchestration tools
- Cloudflare D1 example repos
- MCP server directory (official + third-party)
- AI coding tools beyond Claude Code
- Articles and videos

---

## Documentation

In-depth guides for specific aspects of the D1 vibe coding workflow.

| Doc                                        | What It Covers                                                                                                       |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| [docs/METHODOLOGY.md](docs/METHODOLOGY.md) | The five principles of vibe coding, the D1 workflow loop, common anti-patterns, how to measure effectiveness         |
| [docs/CLOUDFLARE.md](docs/CLOUDFLARE.md)   | D1 query patterns, migrations, Drizzle ORM setup, Worker routing (vanilla + Hono), D1 + KV + R2 together, deployment |
| [docs/PROMPTS.md](docs/PROMPTS.md)         | 20+ real prompts for scaffolding, feature building, debugging, database work, UI design, and deployment              |

---

## Templates and snippets

Drop-in starter files for common patterns.

### Templates (full starter files)

| File                                                             | What It Is                                                                 |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [templates/cloudflare-worker.ts](templates/cloudflare-worker.ts) | Complete Worker + D1 entry point with CORS, error handling, JSON helpers   |
| [templates/d1-migration.sql](templates/d1-migration.sql)         | Migration template with standard columns, indexes, and auto-update trigger |
| [templates/hero.tsx](templates/hero.tsx)                         | Hero section component with gradient text and CTA buttons                  |
| [templates/navbar.tsx](templates/navbar.tsx)                     | Scroll-aware navbar (hidden at top, appears on scroll)                     |
| [templates/card.tsx](templates/card.tsx)                         | Dark mode card with hover states                                           |
| [templates/api-route.ts](templates/api-route.ts)                 | Next.js API route with Zod validation                                      |
| [templates/page.tsx](templates/page.tsx)                         | Page template with loading/error/empty states                              |
| [templates/globals.css](templates/globals.css)                   | Tailwind globals with dark mode defaults                                   |
| [templates/loading.tsx](templates/loading.tsx)                   | Skeleton loader component                                                  |
| [templates/error.tsx](templates/error.tsx)                       | Error boundary component                                                   |
| [templates/not-found.tsx](templates/not-found.tsx)               | 404 page                                                                   |

### Snippets (copy-paste patterns)

| File                                                       | What It Is                                                                  |
| ---------------------------------------------------------- | --------------------------------------------------------------------------- |
| [snippets/drizzle-d1.ts](snippets/drizzle-d1.ts)           | Complete Drizzle ORM + D1 schema, types, and query examples                 |
| [snippets/wrangler.toml](snippets/wrangler.toml)           | Annotated wrangler.toml with D1, KV, R2, Durable Objects, and cron triggers |
| [snippets/useScrollNav.tsx](snippets/useScrollNav.tsx)     | Scroll-aware navbar hook                                                    |
| [snippets/tailwind.config.ts](snippets/tailwind.config.ts) | Tailwind config with custom theme                                           |
| [snippets/prettierrc.json](snippets/prettierrc.json)       | Prettier config                                                             |
| [snippets/gitignore.txt](snippets/gitignore.txt)           | Standard .gitignore                                                         |

---

## File structure

```
D1-Vibe-Coding/
├── CLAUDE.md                    # Drop in project root; enforces design system
├── ECOSYSTEM.md                 # Curated map of the vibe coding landscape
├── setup.sh                     # One-command full infrastructure setup
├── install.sh                   # Quick project-level install
├── SETUP.md                     # Manual setup instructions
├── .claude/
│   ├── commands/                # 36 slash commands
│   ├── rules/                   # 18 rules files (auto-injected context)
│   └── hooks/                   # PostToolUse formatters and sync hooks
├── docs/
│   ├── METHODOLOGY.md           # Vibe coding philosophy and workflow
│   ├── CLOUDFLARE.md            # D1/Workers/KV/R2 patterns and examples
│   └── PROMPTS.md               # Example AI prompts for every stage of dev
├── templates/                   # Full starter files (Worker, migration, components)
├── snippets/                    # Copy-paste patterns (Drizzle, wrangler, hooks)
├── second-brain/
│   ├── README.md                # Two-repo architecture explained
│   ├── init-brain.sh            # Standalone second brain setup
│   ├── context/                 # Personal context templates
│   │   ├── YOU.md
│   │   ├── NOW.md
│   │   ├── PEOPLE.md
│   │   ├── SYSTEM.md
│   │   └── STACK.md
│   └── agents/
│       ├── imessage.md          # iMessage agent integration guide
│       ├── composio.md          # Composio MCP setup guide
│       └── todoist.md           # Todoist session context guide
└── settings/
    ├── settings.json            # Hooks + permissions template
    └── README.md                # How to configure
```

---

## Related repos

| Repo                                                                                        | What It Is                                              |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [cloudflare/vibesdk](https://github.com/cloudflare/vibesdk)                                 | Cloudflare's official vibe coding SDK with D1 + Drizzle |
| [coleam00/context-engineering-intro](https://github.com/coleam00/context-engineering-intro) | Context engineering templates for Claude Code           |
| [roboco-io/awesome-vibecoding](https://github.com/roboco-io/awesome-vibecoding)             | The biggest awesome list for vibe coding                |
| [punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers)             | Directory of MCP servers for AI agents                  |
| [sha256/local-d1](https://github.com/sha256/local-d1)                                       | Local D1 dev replica for Next.js                        |
| [cpjet64/vibecoding](https://github.com/cpjet64/vibecoding)                                 | Vibe coding techniques and wisdom                       |

See [ECOSYSTEM.md](ECOSYSTEM.md) for the full list.

---

Built by [Caleb Newton](https://github.com/calebnewtonusc)

All glory to God! ✝️❤️
