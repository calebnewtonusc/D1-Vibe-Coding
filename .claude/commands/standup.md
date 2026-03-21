---
description: Generate a daily standup — what was done, what's next, any blockers
allowed-tools: Bash(git:*), Bash(gh:*), Bash(curl:*), Bash(date:*), Read
---

# Standup

Generate a standup update. Pull real data, be specific.

## Step 1: Yesterday's git activity

```bash
git log --since="24 hours ago" --author="$(git config user.email)" --oneline --all 2>/dev/null | head -20
```

## Step 2: Todoist — completed + today's plan

```bash
# Today's tasks
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=today" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

## Step 3: Open PRs / blockers

```bash
gh pr list --author "@me" --state open --json number,title,reviewDecision --limit 5
```

## Step 4: Generate standup

```
YESTERDAY
- {what was actually shipped — specific commits or tasks}

TODAY
- {top 3 things from task plan}

BLOCKERS
- {anything stuck, or "None"}
```

Under 150 words. Specific and factual — no vague summaries.
