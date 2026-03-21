---
description: End-of-session wrap-up — commit staged changes, push to GitHub, log what was done
allowed-tools: Bash(git:*), Bash(gh:*), Bash(date:*), Read, Edit, Write, Glob
---

# Close Loop

End-of-session ritual. Commit, push, log, set up tomorrow.

## Step 1: Check git state

```bash
git status
git diff --stat HEAD
```

Report: modified, staged, untracked.

## Step 2: .env leak check

```bash
git diff --cached --name-only | grep -E "^\.env|\.env\." && echo "WARNING: .env staged!" || echo "Clean"
```

If `.env` is staged — STOP and unstage immediately.

## Step 3: Commit

If there are staged or unstaged changes:

1. Show diff summary
2. Stage by filename — never `git add -A`
3. Commit with a meaningful message

## Step 4: Push

```bash
git push origin main
```

If remote doesn't exist:

```bash
GITHUB_USER=$(gh api user --jq .login)
gh repo create $GITHUB_USER/{repo-name} --private --source=. --push
```

Share the GitHub URL.

## Step 5: What was accomplished?

- What was built or fixed
- What files changed
- Open TODOs or unfinished threads

## Step 6: Activity log

If a session log exists (e.g., `ACTIVITY_LOG.md`), append:

```markdown
### {YYYY-MM-DD} — {1-line session title}

- {what was done}
- {important decisions}
- {what's left}
```

## Step 7: Next session

State clearly:

- The 1 thing that must happen next session
- Any context that would be lost without noting it

Brief. This is a ritual, not a report.
