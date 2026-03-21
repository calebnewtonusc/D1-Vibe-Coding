---
description: Smart git push — stage relevant files, generate commit message, push to GitHub
allowed-tools: Bash(git:*), Bash(gh:*), Bash(ls:*), Read, Glob
argument-hint: "[commit message or leave empty for AI-generated]"
---

# Push

Stage modified files, generate a commit message, and push. Never use `git add .` or `git add -A`.

## Step 1: Check state

```bash
git status --short
git diff --stat HEAD
```

Report what's modified and what's staged.

## Step 2: .env leak scan

Before staging anything:

```bash
git diff --stat HEAD | grep -E "\.env" && echo "WARNING: .env file modified" || echo "No .env files"
git diff HEAD -- | grep -E "^\+(sk-ant|sk-|ANTHROPIC|API_KEY|SECRET|PASSWORD|TOKEN)" | grep -v "process\.env\." | grep -v "example\|placeholder" | head -5
```

If any real secrets appear in the diff — **STOP** and do not commit.

## Step 3: Stage by filename

Look at modified files. For each:

- Source files (.ts, .tsx, .py, .js, etc.) — stage
- Config files (package.json, tsconfig.json, vercel.json, etc.) — stage
- .env files — DO NOT stage, warn the user
- node_modules, .next, dist, **pycache** — skip entirely

```bash
git add {file1} {file2} {file3}
```

## Step 4: Commit message

If `$ARGUMENTS` is provided, use it.

Otherwise analyze the diff and write one:

- `feat: {new capability}`
- `fix: {what was broken and how}`
- `chore: {maintenance, config, refactor}`
- `docs: {documentation change}`

## Step 5: Commit and push

```bash
git commit -m "{message}"
git push
```

If no upstream: `git push -u origin main`

## Step 6: Report

Show the commit hash and GitHub URL.
