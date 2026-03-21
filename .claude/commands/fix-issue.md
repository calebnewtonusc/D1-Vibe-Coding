---
description: Fetch a GitHub issue, create a branch, research the codebase, plan and implement the fix
allowed-tools: Bash(gh issue view:*), Bash(gh repo view:*), Bash(git:*), Bash(npm:*), Bash(npx:*), Read, Edit, Write, Grep, Glob
argument-hint: "<issue-number or github-issue-url>"
---

# Fix GitHub Issue

## Step 1: Resolve the issue

Parse `$ARGUMENTS`:

- Full URL → extract issue number
- Bare number → use directly
- Empty → stop and ask

```bash
gh issue view {number} --json title,body,labels,assignees,comments,state
```

If closed, warn and confirm before proceeding.

## Step 2: Create a branch

```bash
git fetch origin
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
git checkout -b fix/{number}-{short-slug} origin/{default-branch}
```

Slug: 3-5 words from the issue title, kebab-case. Stop if there are uncommitted changes.

## Step 3: Understand the issue

Summarize in 2-3 sentences: what's broken, what "done" looks like, any constraints.

List open questions if the issue is ambiguous.

## Step 4: Research the codebase

1. Find relevant files, functions, and types — read them in full
2. Trace the code path from entry point to relevant logic
3. Find existing tests for the affected code
4. Note patterns to maintain consistency

## Step 5: Plan

Cover:

1. Root cause (bugs) or design approach (features)
2. Files to modify with specific descriptions
3. New files (if any) with justification
4. Tests to add: happy path, error paths, edge cases
5. Migration/compatibility concerns

**Wait for approval before implementing.**

## Step 6: Implement

1. Make each change from the plan
2. Write all planned tests
3. Run quality gate:
   - `npm run typecheck 2>/dev/null || npx tsc --noEmit` — zero errors
   - `npm run lint 2>/dev/null || npx eslint . --max-warnings 0` — zero errors
   - `npm test` — all pass

## Step 7: Commit

```bash
git commit -m "fix: {description} (#{number})"
```

Summarize: files changed, tests added, follow-up work.
