---
description: Read all review comments on a PR, triage each one, implement fixes, reply
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(gh pr:*), Bash(gh api:*), Bash(git:*), Bash(npm:*), Bash(npx tsc:*)
argument-hint: "[PR number] — defaults to current branch's PR"
---

# Respond to PR Review

## Step 1: Find the PR

```bash
gh pr list --head $(git branch --show-current) --json number,title,url --jq '.[0]'
```

Or use `$ARGUMENTS` as the PR number.

## Step 2: Fetch all comments

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
gh api --paginate repos/{owner}/{repo}/pulls/{number}/comments
gh api --paginate repos/{owner}/{repo}/pulls/{number}/reviews
```

Deduplicate — bots often post the same finding multiple times.

## Step 3: Triage and plan

For each unique issue:

1. Read the current file at the referenced location
2. Check if already fixed by a prior commit
3. Assess validity — real problem or false positive?
4. Classify severity: Critical | High | Medium | Low

Plan table:

| #   | Issue | File:Line | Severity | Status | Planned Fix |
| --- | ----- | --------- | -------- | ------ | ----------- |

**Wait for user confirmation before implementing.**

## Step 4: Implement fixes

1. Implement each fix
2. Run quality gate:
   - `npm run typecheck 2>/dev/null || npx tsc --noEmit`
   - `npm run lint 2>/dev/null || npx eslint . --max-warnings 0`
3. Commit and push to the branch

## Step 5: Reply to comments

Reply on the PR with what was fixed and the commit SHA. For false positives, explain why no change was needed.

## Rules

- Never assess code you haven't read first
- Don't make changes beyond what the review comments ask for
- Surface disagreements during planning, not silently
