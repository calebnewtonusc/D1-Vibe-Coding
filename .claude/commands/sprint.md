---
description: Show today's Todoist task breakdown — by project/label, priorities, estimated load
allowed-tools: Bash(curl:*), Bash(date:*), Read
---

# Sprint

Pull today's Todoist tasks and show a clean breakdown.

## Step 1: Pull today's tasks

```bash
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=today" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"

curl -sf "https://api.todoist.com/rest/v2/tasks?filter=overdue" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

## Step 2: Parse and organize

Group by label. Priority sort within each group: P1 first, P4 last.

Todoist priority API mapping:

- P1 = priority 4 (highest)
- P2 = priority 3
- P3 = priority 2
- P4 = priority 1

## Step 3: Output

```
TODAY — {Day}, {Date}
{total} tasks

GROUP 1 — {label} ({n} tasks)
  [P1] {task}
  [P3] {task}

GROUP 2 — ...

OVERDUE ({n})
  {overdue tasks}

LOAD ASSESSMENT
{Light / Moderate / Heavy} — {brief reasoning}
```

If `$ARGUMENTS` is "reorder" — suggest optimal ordering based on time of day and dependencies.
