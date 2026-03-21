---
description: Mark a Todoist task as complete — search by name or ID
allowed-tools: Bash(curl:*), Read
argument-hint: "<task name or ID>"
---

# Done

Mark a Todoist task complete.

## Step 1: Find the task

If `$ARGUMENTS` is a number, use it as task ID directly.

Otherwise search today's tasks:

```bash
curl -sf "https://api.todoist.com/rest/v2/tasks?filter=today" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

Fuzzy-match `$ARGUMENTS` against task content. If multiple match, ask which one.

## Step 2: Close

```bash
curl -sf -X POST "https://api.todoist.com/rest/v2/tasks/{task_id}/close" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

## Step 3: Confirm

One line: "Done: {task name}"

If `$ARGUMENTS` is "all {label}" — close all tasks with that label for today.
