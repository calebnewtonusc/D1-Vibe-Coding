---
description: Instantly scan iMessage inbox — surface pending replies, priorities, and unreads
allowed-tools: Bash(bun:*), Bash(cd:*), Read
---

# Inbox

Run the iMessage agent scan immediately. No setup, no confirmation.

```bash
cd /Users/joelnewton/Desktop/2026-Code/_System/imessage-agent && bun run agent.ts --mode scan 2>&1
```

After the scan, synthesize:

- Who needs a reply (sorted by urgency)
- Any time-sensitive messages
- Conversation threads that have gone cold

If $ARGUMENTS is "full" or "triage":

```bash
cd /Users/joelnewton/Desktop/2026-Code/_System/imessage-agent && bun run agent.ts --mode inbox 2>&1
```

If $ARGUMENTS is "run":

```bash
cd /Users/joelnewton/Desktop/2026-Code/_System/imessage-agent && bun run agent.ts --mode run --dry-run 2>&1
```

Always surface the results immediately — never ask Caleb to run this himself.
