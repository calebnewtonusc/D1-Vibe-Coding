# Git Rules

## Stage by filename — never `git add -A` or `git add .`

Prevents accidentally committing `.env` files, large binaries, or unrelated changes.

```bash
git add src/components/Nav.tsx package.json
```

## Commit message format

```
feat: {what new capability was added}
fix: {what was broken and how it was fixed}
chore: {maintenance task}
docs: {documentation change}
style: {design/UI change}
refactor: {code restructure, no behavior change}
```

Reference issue numbers: `fix: resolve null crash on profile load (#42)`

## Branch naming

- `feat/{feature-slug}` — new features
- `fix/{issue-or-slug}` — bug fixes
- `chore/{description}` — maintenance, dependency updates

## Never amend published commits

Create a new commit instead. Amending rewrites history — breaks anyone else working on the branch.

## Resolve merge conflicts — don't blindly discard

Read both sides of the conflict before choosing. `git checkout --ours/--theirs` without understanding is a code deletion bug.

## .env files

Never stage `.env` files. Always verify `.gitignore` covers them:

```bash
git diff --cached --name-only | grep -E "^\.env|\.env\."
```

If a `.env` file appears — STOP and unstage it immediately.
