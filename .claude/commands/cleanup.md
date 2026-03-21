---
description: Find and remove dead code, unused imports, console.logs, TODO comments
allowed-tools: Bash(grep:*), Bash(find:*), Bash(npx:*), Read, Glob, Edit
argument-hint: "[project-path]"
---

# Cleanup

Find (and optionally fix) dead code.

## Step 1: Unused imports

```bash
npx ts-unused-exports tsconfig.json 2>/dev/null | head -20
```

## Step 2: Console.logs in non-test files

```bash
grep -rn "console\.log\|console\.warn\|console\.error" \
  --include="*.ts" --include="*.tsx" . 2>/dev/null \
  | grep -v "\.test\.\|\.spec\.\|logger\." | head -20
```

## Step 3: TODO/FIXME/HACK comments

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP\|REMOVE" \
  --include="*.ts" --include="*.tsx" --include="*.py" . 2>/dev/null \
  | grep -v "node_modules\|\.next"
```

## Step 4: Dead files

```bash
npx depcheck 2>/dev/null | grep "Unused files" -A 20
```

## Step 5: Commented-out code

```bash
grep -rn "^//\s*[a-zA-Z]" --include="*.ts" --include="*.tsx" . 2>/dev/null \
  | grep -v "eslint\|prettier\|@ts-" | head -20
```

## Step 6: Report and fix

List everything found. Ask: "Fix all, or just report?"

If fixing:

- Remove console.logs (unless part of a logger pattern)
- Remove commented-out code blocks
- Leave TODO comments but list them
- Never auto-delete files — list and confirm
