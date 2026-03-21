---
description: Triage GitHub issues — classify, score severity/opportunity, detect duplicates
allowed-tools: Bash(gh issue:*), Bash(gh api:*), Bash(gh repo:*)
argument-hint: "[owner/repo — defaults to current repo]"
---

# Issue Triage

## Step 1: Fetch issues

```bash
gh issue list --state open --limit 100 \
  --json number,title,body,labels,createdAt,updatedAt,assignees,comments
```

For large repos: `gh api --paginate repos/{owner}/{repo}/issues?state=open`

## Step 2: Classify each issue

**Type:** `bug` | `feature` | `ambiguous`

**Spec quality:** `well-specified` | `adequate` | `under-specified`

## Step 3: Score bugs

```
severity = impact(1-4) × urgency(1-3) × scope(1-3)
```

- +5 if security-related
- +3 if a PR already exists

Impact: 4=data loss/security, 3=core broken, 2=degraded, 1=cosmetic
Urgency: 3=blocking now, 2=workaround exists, 1=edge case
Scope: 3=all users, 2=some users, 1=rare

## Step 4: Score features

```
opportunity = value(1-4) + (4 - effort(1-3)) + readiness(1-3)
```

- +2 if multiple users requested
- +2 if aligns with active work

## Step 5: Detect relationships

- Duplicates (same root cause)
- Clusters (related issues)
- Already fixed (check recent commits)
- Blockers (A blocks B)

## Step 6: Output

```
## Critical Bugs (score ≥ 24)
[table: number | title | score | spec quality | note]

## High-Opportunity Features (score ≥ 8)
[table: number | title | score | spec quality | note]

## Under-Specified (needs clarification)
[list: number | title | what's missing]

## Duplicates
[list: kept | duplicates | reason]

## Stale (>90 days, no activity)
[list: number | title | age]

## Recommendations
[3-5 concrete next actions]
```

Read-only. No comments, labels, or closes.
