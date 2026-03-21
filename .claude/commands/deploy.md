---
description: Deploy current project to Vercel — runs quality gate, then deploys
allowed-tools: Bash(vercel:*), Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Bash(ls:*), Read, Glob
argument-hint: "[--prod] [project-path]"
---

# Deploy

Deploy to Vercel. Runs quality gate first — never ships broken code.

## Step 1: Detect project

If `$ARGUMENTS` has a path, use it. Otherwise use current directory.

```bash
ls package.json 2>/dev/null && echo "found" || echo "no package.json"
cat vercel.json 2>/dev/null || echo "no vercel.json"
```

## Step 2: Quality gate

```bash
npm run typecheck 2>/dev/null || npx tsc --noEmit
npm run lint 2>/dev/null || npx eslint . --max-warnings 0
```

If either fails, stop. Do not deploy broken code.

## Step 3: Clean git state

```bash
git status --short
```

Commit any uncommitted changes first (by filename, never `git add -A`).

## Step 4: Deploy

Preview (default):

```bash
vercel --yes 2>&1
```

Production (if `--prod` in `$ARGUMENTS`):

```bash
git push origin main
```

Never run `vercel --prod` from local — push to main and let Vercel auto-deploy from GitHub.

## Step 5: Report

Show the deployment URL. Note whether it's preview or production.
