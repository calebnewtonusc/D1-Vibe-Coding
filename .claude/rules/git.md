---
paths:
  - "**/*"
---
# Git Rules

**Never commit Co-Authored-By lines.** Caleb does not want Claude attribution in any commit messages.

**Stage by filename, never `git add -A` or `git add .`** — prevents accidentally committing `.env` files, large binaries, or unrelated changes.

**amber-organization/amber requires PRs.** Never push directly to `main` on that repo. Always push a new branch and open a PR.

**Personal repos (calebnewtonusc/*)** can be pushed to `main` directly.

**Branch naming:**
- `fix/{issue-or-slug}` — bug fixes
- `feat/{feature-slug}` — new features
- `chore/{description}` — maintenance, dependency updates

**Commit message format:**
- `fix: {what was broken and how it was fixed}`
- `feat: {what new capability was added}`
- `chore: {maintenance task}`
- Reference issue numbers: `fix: resolve null crash on profile load (#42)`

**Never amend published commits** — create a new commit instead.

**Resolve conflicts by understanding them.** Don't `git checkout --ours/--theirs` blindly — read both sides.
