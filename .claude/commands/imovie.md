---
description: Update iMovie with recently AirDropped media. Run immediately — no clarifying questions.
allowed-tools: Bash(bash:*)
---

Update iMovie with recently AirDropped media. Run immediately — no clarifying questions.

## Step 1: Check status

```
bash /Users/joelnewton/Desktop/2026-Code/_System/imovie-agent/agent.sh --status
```

Parse the JSON output to understand how many files are queued and what project we're targeting.

## Step 2: Import based on what Caleb said

- Default / "yo I AirDropped clips" / "update iMovie" → run with no flags (auto mode)
- "add to current project" → `--import-only`
- "new project" / "start fresh" / new week → `--new`
- "add to [name]" → `--project "Name"`

```
bash /Users/joelnewton/Desktop/2026-Code/_System/imovie-agent/agent.sh [flags]
```

iMovie will open, create the project if needed, and import all staged clips in chronological order.

## Step 3: Report back

Tell Caleb:

- How many files were imported
- Which project they went into
- Any files that were Live Photos (auto-converted to MOV)
- The staged folder path (in case he wants to double-check)

## Notes

- Files are staged to `~/Movies/iMovie-Staged/<week>/` before import — safe to run twice
- Live Photos automatically import as MOV (the motion clip), not the still HEIC
- State is tracked in `_System/imovie-agent/state.json` — works across any chat session
- Willow trigger is a separate daemon (`willow-trigger.sh`) that auto-fires this when Caleb speaks the intent
