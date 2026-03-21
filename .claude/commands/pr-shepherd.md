---
description: Full PR lifecycle — review, fix findings, address comments, quality gate, push, CI fix loop, merge
allowed-tools: Bash(gh pr *), Bash(gh api *), Bash(gh repo view:*), Bash(gh run *), Bash(git *), Bash(npm:*), Bash(npx:*), Read, Edit, Write, Grep, Glob, Agent
argument-hint: "<pr-number or url> [--fix] [--merge] [--review-only]"
---

# PR Shepherd

Full PR lifecycle: review → fix → quality gate → push → CI → merge.

Parse `$ARGUMENTS`:

- Extract PR number from bare number or URL
- Flags: `--fix` (auto-fix), `--merge` (merge when CI green), `--review-only`
- No PR given: `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'`

---

## Phase 1: Situational Awareness

Gather in parallel:

```
gh pr view {number} --json number,title,body,author,baseRefName,headRefName,state,isDraft,mergeable,files,additions,deletions,labels
gh pr diff {number}
gh pr checks {number} --json name,status,conclusion
gh api --paginate repos/{owner}/{repo}/pulls/{number}/comments
gh api --paginate repos/{owner}/{repo}/pulls/{number}/reviews
```

Print status card:

```
PR #{number}: {title}
Author: {author}    Base: {base} ← {head}
Size: +{additions} -{deletions} across {file_count} files
CI: {PASS|FAIL|PENDING}    Mergeable: {yes|no|conflict}
Unresolved comments: {N}
```

Decide mode: comments → Phase 2a | no review → Phase 2b | CI failing → Phase 4 | all green → Phase 6

---

## Phase 2a: Address Review Comments

For each unresolved comment:

1. Read the referenced code at file:line
2. Classify: valid / already fixed / false positive / nit
3. Build fix plan table

Wait for confirmation (unless `--fix`), then Phase 3.

---

## Phase 2b: Deep Review (6 Lenses)

Read every changed file. Prioritize: service logic > handlers > types > tests > docs.

**Correctness** — off-by-one, wrong operators, unreachable code, type confusion, error propagation

**Edge cases** — null/undefined, service failures, boundaries, malformed input

**Security** — auth bypass, IDOR, injection, data leakage, replay attacks

**Tests** — new public functions tested? error paths? edge cases?

**Architecture** — follows patterns? duplicate logic? clean boundaries?

Findings table: `| # | Severity | Category | File:Line | Finding | Suggested Fix |`

Severity: Critical > High > Medium > Low > Nit

---

## Phase 3: Fix

```bash
gh pr checkout {number}
npm run typecheck 2>/dev/null || npx tsc --noEmit
npm run lint 2>/dev/null || npx eslint . --max-warnings 0
npm test
```

Loop up to 3 times. Stop and report if still failing.

---

## Phase 4: Commit & Push

```bash
git add path/to/file1 path/to/file2
git commit -m "fix: address review findings on PR #{number}"
git push origin {headRefName}
```

Reply to addressed comments on GitHub with commit SHA.

---

## Phase 5: CI Monitor

Poll every 30s, up to 10 minutes:

```
gh pr checks {number} --json name,status,conclusion
```

If CI fails (up to 3 attempts): view logs, diagnose, fix, push, repeat.

---

## Phase 6: Merge

If `--merge` or user confirms, all conditions met:

```
gh pr merge {number} --squash --delete-branch
```

---

## Rules

- Read before judging. No findings without reading the code.
- Fix the pattern, not just the instance.
- Don't over-fix. Only change what was flagged.
