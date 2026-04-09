---
paths:
  - "**/*"
---

# Git Rules

**Never commit Co-Authored-By lines.** No AI attribution in commit messages.

**Stage by filename, never `git add -A` or `git add .`** prevents accidentally committing `.env` files, large binaries, or unrelated changes.

**Branch naming:**

- `fix/{issue-or-slug}` for bug fixes
- `feat/{feature-slug}` for new features
- `chore/{description}` for maintenance, dependency updates

**Commit message format:**

- `fix: {what was broken and how it was fixed}`
- `feat: {what new capability was added}`
- `chore: {maintenance task}`
- Reference issue numbers: `fix: resolve null crash on profile load (#42)`

**Never amend published commits.** Create a new commit instead.

**Resolve conflicts by understanding them.** Don't `git checkout --ours/--theirs` blindly. Read both sides.

<!--
  CUSTOMIZATION POINT: Add repo-specific rules here.
  Example: "org-name/repo requires PRs. Never push directly to main."
  Example: "Personal repos (your-username/*) can be pushed to main directly."
-->
