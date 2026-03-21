---
description: Generate a prioritized PR triage dashboard — classify by module, review state, scope, and risk
allowed-tools: Bash(gh pr:*), Bash(gh api:*), Bash(gh repo:*)
argument-hint: "[owner/repo — defaults to current repo]"
---

# PR Triage Dashboard

## Step 1: Fetch open PRs

```bash
gh pr list --state open --limit 100 \
  --json number,title,author,createdAt,updatedAt,labels,reviewDecision,isDraft,additions,deletions,changedFiles,headRefName,baseRefName,mergeable
```

For each PR, get file list to determine module:

```bash
gh pr view {number} --json files --jq '.files[].path'
```

## Step 2: Classify each PR

**Module:** `web/ui` | `api` | `db/schema` | `auth` | `ai/ml` | `infra/ci` | `tests` | `docs` | `deps` | `other`

**Review state:** `approved` | `changes-requested` | `reviewed` | `automated-only` | `no-review`

**Scope:** `tiny` (<50 lines) | `small` (50-200) | `medium` (200-500) | `large` (500-2000) | `xl` (2000+)

**Risk:** `fix` (safe, quick review) | `feature` (standard review) | `architectural` (needs deep review — changes interfaces, schema, auth)

## Step 3: Detect conflicts

Flag PRs that touch the same files — potential merge conflicts or conceptual overlap.

## Step 4: Output dashboard

```
## Summary
Total open: N | Approved: N | Needs review: N | Stale (>14d): N

## Ready to Merge (approved, CI green, no conflicts)
[table: # | title | author | scope | module | age]

## Fixes Needing Review
[table: # | title | author | scope | module | age]

## Features Needing Review
[table: # | title | author | scope | module | age]

## Architectural PRs (need deep review)
[table: # | title | author | scope | module | age | what changes]

## Changes Requested — Awaiting Author
[table: # | title | author | feedback summary | stale?]

## Draft PRs
[table: # | title | author | progress note]

## Stale (>14 days no activity)
[table: # | title | author | last activity]

## Conflicts / Overlaps
[list: PR A + PR B touch same files: [file list]]

## Recommendations
[3-5 concrete next actions]
```

Read-only. No comments, approvals, or merges.
