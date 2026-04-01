# Claude Workflow Kit

A complete, production-ready Claude Code setup. Drop it in and your AI pair programmer immediately writes better code, ships better UIs, and follows better patterns. You never have to tell it twice.

## What you get

**20+ slash commands** covering the full dev lifecycle: scaffold, push, deploy, audit, PR lifecycle, daily planning, sprint tracking.

**10 rules files** auto-injected as context based on file type: security, API patterns, component standards, database, deployment, naming, performance, state management, accessibility, TypeScript.

**A full design system** (`CLAUDE.md`) that makes every generated UI look like a funded startup's product page. Dark mode, shadcn/ui, Tailwind, scroll-aware navbar, and real typography, all enforced on every generation.

**Hooks** that auto-format files after every write, warn before touching `.env`, and remind you to push to GitHub at the end of each session.

**Reusable templates** for navbar, hero, cards, API routes, error/loading/empty states.

---

## Quick install

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-workflow-kit
cd claude-workflow-kit
chmod +x install.sh && ./install.sh
```

Or set it up manually (takes 5 minutes). See [SETUP.md](SETUP.md).

---

## The slash commands

| Command        | What it does                                                   |
| -------------- | -------------------------------------------------------------- |
| `/new-project` | Scaffold Next.js + shadcn/ui + Tailwind + all deps in one shot |
| `/push`        | Secret scan → smart commit message → push                      |
| `/deploy`      | Quality gate + Vercel deploy                                   |
| `/ship`        | Typecheck + lint + tests before any merge                      |
| `/audit`       | Security scan + code quality + design quality                  |
| `/pr-shepherd` | Full PR lifecycle: review → fix → CI → merge                   |
| `/respond-pr`  | Read all review comments, implement fixes, reply with SHAs     |
| `/fix-issue`   | Fetch GitHub issue → branch → research → implement → commit    |
| `/daily-brief` | Today's tasks + GitHub PRs + focused plan                      |
| `/close-loop`  | End-of-session: commit, push, log, set up tomorrow             |
| `/standup`     | Generate standup from git log                                  |
| `/changelog`   | Changelog from git log since last tag                          |
| `/cleanup`     | Remove dead code, console.logs, unused imports                 |
| `/deps`        | Check outdated, unused, vulnerable dependencies                |
| `/env-check`   | Compare `.env.example` vs `.env` to find gaps                  |
| `/sprint`      | Today's task breakdown by priority                             |
| `/todo`        | Add a task from natural language                               |
| `/done`        | Mark a task complete                                           |
| `/scratchpad`  | Capture quick ideas                                            |

---

## The design system

The `CLAUDE.md` is the crown jewel. It enforces:

- **Dark mode by default**: `#0a0a0a` background, `zinc-950` surfaces
- **shadcn/ui always**: never raw `<button>` or `<input>` from scratch
- **Lucide React icons**: never emoji, never text characters as icons
- **Scroll-aware navbar on every project**: hidden at top, slides in after 80px, hides near page bottom
- **Typography hierarchy**: Inter/Geist, `text-5xl font-bold tracking-tight` heroes, proper scale
- **Cards and buttons with hover states**: every interactive element
- **Loading/empty/error states**: never blank white space
- **Responsive layouts**: mobile-first, `max-w-7xl` containers

Before shipping any UI, ask: _"Does this look like a YC-backed startup's product page?"_ If not, rebuild it.

---

## The rules files

Drop `.claude/rules/` in your project. Each file is auto-loaded as context when Claude touches matching files:

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

---

## The hooks

Copy `settings/settings.json` and merge it into `~/.claude/settings.json`:

```
PostToolUse Write|Edit  →  auto-run prettier on every saved file
PreToolUse Write        →  warn before touching .env files
Stop                    →  remind to push to GitHub + surface any TODOs
SessionStart            →  load project context + today's priorities
```

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

The design rules work for any frontend. The database/API rules assume Supabase. Swap them out for your stack.

---

## File structure

```
claude-workflow-kit/
├── CLAUDE.md                   # Drop in project root; enforces design system
├── install.sh                  # One-command setup
├── SETUP.md                    # Manual setup instructions
├── .claude/
│   ├── commands/               # 20+ slash commands
│   ├── rules/                  # 10 rules files (auto-injected context)
│   ├── templates/              # Copy-paste components
│   └── snippets/               # Reusable code chunks
└── settings/
    ├── settings.json           # Hooks + permissions template
    └── README.md               # How to configure
```

---

Built by [Caleb Newton](https://calebnewton.me)
