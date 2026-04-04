---
description: Generate a daily standup — what was done, what's next, any blockers
allowed-tools: Bash(git:*), Bash(gh:*), Bash(curl:*), Bash(date:*), Read
---

# Standup

Generate Caleb's daily standup update. Pull real data, be specific.

## Step 1: Yesterday's git activity

```bash
git log --since="24 hours ago" --author="$(git config user.email)" --oneline --all 2>/dev/null | head -20
```

Also check all projects with remotes:

```bash
for dir in /Users/joelnewton/Desktop/2026-Code/projects/*/; do
  cd "$dir" 2>/dev/null && git log --since="24 hours ago" --oneline 2>/dev/null | head -5 && cd -
done 2>/dev/null
```

## Step 2: Todoist — completed yesterday + today's plan

```bash
# Today's tasks
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=today" \
  -H "Authorization: Bearer f0126e193b7fb233c00d57d8480de4741106209e"

# Recently completed (last 24h)
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=completed" \
  -H "Authorization: Bearer f0126e193b7fb233c00d57d8480de4741106209e" 2>/dev/null | head -5
```

## Step 3: Any open PRs or blockers

```bash
gh pr list --author "@me" --state open --json number,title,reviewDecision --limit 5
```

## Step 4: Generate standup

Output in this format (concise, no fluff):

```
YESTERDAY
- {what was actually shipped/done — specific commits or tasks}

TODAY
- {top 3 things from sprint plan}

BLOCKERS
- {anything stuck, or "None"}
```

Under 150 words. Specific and factual — no vague summaries.
