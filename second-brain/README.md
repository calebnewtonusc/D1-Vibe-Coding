# Second Brain — Claude Persistent Context System

The D1 second brain gives Claude a persistent memory of who you are, what you're working on, and how you work. Instead of re-explaining yourself every session, Claude loads your context automatically and picks up exactly where you left off.

## What it is

A set of structured markdown files Claude loads at the start of every session. They cover:

- **YOU.md** — who you are, your background, skills, goals, working style
- **NOW.md** — current jobs, active projects, priorities, what's broken
- **PEOPLE.md** — collaborators, teammates, people in your orbit
- **SYSTEM.md** — your tools, APIs, infrastructure, credentials format
- **STACK.md** — your preferred tech stack and coding standards

Each file is auto-committed to a private GitHub repo every time it changes. Over time this becomes a living, versioned history of your professional life that Claude can always reference.

## Setup (5 minutes)

```bash
cd second-brain
chmod +x init-brain.sh
./init-brain.sh
```

The script will:
1. Walk you through each context file
2. Create a private GitHub repo for your brain
3. Wire up the auto-commit hook so changes push automatically
4. Add the SessionStart hook so Claude loads your context on every session

## Agent integrations

Once your brain is set up, wire in your agents:

- [iMessage Agent](agents/imessage.md) — Claude reads and sends your iMessages
- [Composio MCP](agents/composio.md) — 100+ integrations: GitHub, Gmail, Calendar, Todoist, Vercel
- [Todoist Session Context](agents/todoist.md) — Today's top tasks injected into every session

## Manual setup

If you prefer to skip the script, copy the templates from `context/` and fill them in:

```bash
mkdir -p ~/.claude/context
cp second-brain/context/*.md ~/.claude/context/
# Edit each file with your info
```

Then add this to your `~/.claude/settings.json` `hooks.SessionStart`:

```json
{
  "type": "command",
  "command": "cat ~/.claude/context/YOU.md ~/.claude/context/NOW.md 2>/dev/null | head -200",
  "statusMessage": "Loading your context..."
}
```

All glory to God! ✝️❤️
