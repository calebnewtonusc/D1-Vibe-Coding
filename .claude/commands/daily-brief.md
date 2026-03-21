---
description: Morning briefing — Todoist tasks for today, GitHub PRs/issues, focused daily plan
allowed-tools: Bash(gh:*), Bash(curl:*), Bash(date:*), Read
---

# Daily Brief

Pull live data. Synthesize a focused daily plan. Signal over noise.

## Step 1: Today's date

```bash
date '+%A, %B %-d, %Y'
```

## Step 2: Todoist — today's tasks + overdue

```bash
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=today" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"

curl -sf "https://api.todoist.com/rest/v2/tasks?filter=overdue" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

Group by label/project. Priority order (P1 first). Count total tasks.

## Step 3: GitHub — PRs and issues

```bash
gh pr list --author "@me" --state open --json number,title,updatedAt,reviewDecision --limit 10
gh issue list --assignee "@me" --state open --json number,title,updatedAt --limit 10
```

## Step 4: Synthesize

```
{Day}, {Date}

TOP PRIORITIES (3 max)
1. {most critical, with why}
2. {second}
3. {third}

TODAY'S TASKS ({n} total)
{grouped by project/label, P1 first}

OVERDUE ({n}): {task names}

GITHUB
{PRs/issues needing action}

FOCUS BLOCK
{Best 2-hour deep work window + what to do in it}
```

Under 400 words. No fluff.

Ask: "Want me to reorder tasks or kick off anything specific?"
