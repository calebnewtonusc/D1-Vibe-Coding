# Todoist Session Context

Inject today's Todoist priorities into every Claude session automatically. Claude opens knowing what you need to ship today before you say a word.

## What it does

Every time you start a Claude Code session, a SessionStart hook fires, fetches your top 3 highest-priority tasks due today, and injects them into Claude's context. Claude can then reference them, help you knock them out, and surface reminders when you're about to context-switch.

## Setup

### 1. Get your Todoist API token

Go to [app.todoist.com/app/settings/integrations/developer](https://app.todoist.com/app/settings/integrations/developer) and copy your API token.

### 2. Add to ~/.claude/settings.json

Under `env`:

```json
{
  "env": {
    "TODOIST_API_TOKEN": "YOUR_TOKEN_HERE"
  }
}
```

### 3. Add the SessionStart hook

Under `hooks.SessionStart`:

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "TASKS=$(curl -sf 'https://api.todoist.com/rest/v2/tasks?filter=today' -H 'Authorization: Bearer YOUR_TOKEN' 2>/dev/null | python3 -c \"import json,sys; tasks=json.load(sys.stdin); top=[t['content'] for t in sorted(tasks, key=lambda x: -x.get('priority',1))[:3]]; print(', '.join(top))\" 2>/dev/null || echo 'unavailable'); printf '%s' \"{\\\"hookSpecificOutput\\\": {\\\"hookEventName\\\": \\\"SessionStart\\\", \\\"additionalContext\\\": \\\"Today top Todoist priorities: $TASKS\\\"}}\"",
      "statusMessage": "Loading Todoist priorities..."
    }
  ]
}
```

Replace `YOUR_TOKEN` with your actual token, or use `$TODOIST_API_TOKEN` if you set it in `env`.

## Slash commands

The D1 kit includes Todoist slash commands out of the box:

| Command | What it does |
|---------|-------------|
| `/todo Buy groceries p1 today` | Add a task with natural language |
| `/done fix auth bug` | Mark a task complete by name |
| `/sprint` | Show today's task breakdown by priority |
| `/daily-brief` | Today's tasks + GitHub PRs + a focused plan |

## Label system (optional, but powerful)

If you use labels in Todoist, Claude can filter by them:

```bash
# Get only tasks labeled @work
curl -sf 'https://api.todoist.com/rest/v2/tasks?filter=today+%26+@work' \
  -H "Authorization: Bearer $TODOIST_API_TOKEN"
```

Set this up in your session hook to only inject work tasks during work sessions.

## Priority mapping

Todoist priorities map to Claude's urgency framing:

| Todoist | Meaning | How Claude treats it |
|---------|---------|---------------------|
| p1 | Urgent | Surfaces first, flags if not addressed |
| p2 | High | Included in sprint |
| p3 | Normal | Included in brief |
| p4 | Low | Background |
