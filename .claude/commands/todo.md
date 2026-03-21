---
description: Add a Todoist task from natural language — auto-assigns label, priority, due date
allowed-tools: Bash(curl:*), Bash(date:*), Read
argument-hint: "<task description> [due:today|tomorrow|monday] [p1|p2|p3|p4]"
---

# Todo

Add a task to Todoist from natural language.

## Step 1: Parse

Extract from `$ARGUMENTS`:

- **Content**: the task description
- **Due date**: "today", "tomorrow", day name, or "due:X"
- **Priority**: "p1/p2/p3/p4" or "urgent/important", default P3

Todoist priority API mapping:

- P1 = priority 4
- P2 = priority 3
- P3 = priority 2 (default)
- P4 = priority 1

## Step 2: Get labels

```bash
curl -sf "https://api.todoist.com/rest/v2/labels" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

Match the requested label, or use the most appropriate one from the list.

## Step 3: Create

```bash
curl -sf -X POST "https://api.todoist.com/rest/v2/tasks" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "{content}",
    "due_string": "{due}",
    "priority": {priority_value},
    "labels": ["{label}"]
  }'
```

## Step 4: Confirm

One line: task name, label, priority, due date.
