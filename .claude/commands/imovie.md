---
description: Update iMovie with recently AirDropped media. Run immediately, no clarifying questions.
allowed-tools: Bash(bash:*)
---

Update iMovie with recently AirDropped media. Run immediately, no clarifying questions.

> **Requires**: iMovie agent installed. macOS only. Check `$HOME/dev/imovie-agent/agent.sh` or the path configured during setup.

## Step 1: Check status

```bash
IMOVIE_DIR="${IMOVIE_AGENT_DIR:-$HOME/dev/imovie-agent}"
if [ -f "$IMOVIE_DIR/agent.sh" ]; then
  bash "$IMOVIE_DIR/agent.sh" --status
else
  echo "iMovie agent not found at $IMOVIE_DIR. Set IMOVIE_AGENT_DIR or install manually."
fi
```

Parse the JSON output to understand how many files are queued and what project we're targeting.

## Step 2: Import based on user intent

- Default / "AirDropped clips" / "update iMovie": run with no flags (auto mode)
- "add to current project": `--import-only`
- "new project" / "start fresh" / new week: `--new`
- "add to [name]": `--project "Name"`

```bash
bash "$IMOVIE_DIR/agent.sh" [flags]
```

iMovie will open, create the project if needed, and import all staged clips in chronological order.

## Step 3: Report back

Tell the user:

- How many files were imported
- Which project they went into
- Any files that were Live Photos (auto-converted to MOV)
- The staged folder path (in case they want to double-check)

## Notes

- Files are staged to `~/Movies/iMovie-Staged/<week>/` before import
- Live Photos automatically import as MOV (the motion clip), not the still HEIC
- State is tracked in the agent's `state.json`
