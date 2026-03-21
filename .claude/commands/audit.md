---
description: Security and code quality audit — vulnerabilities, bad patterns, tech debt
allowed-tools: Bash(git:*), Bash(npm:*), Bash(npx:*), Bash(grep:*), Bash(find:*), Read, Glob
argument-hint: "[project-path]"
---

# Audit

Deep audit of `$ARGUMENTS` (or current directory). No shortcuts.

## Step 1: Security scan

```bash
# Secrets in code
grep -r "sk-ant\|sk-proj\|ANTHROPIC_API_KEY\|ghp_\|eyJhbGci\|password\s*=\s*['\"]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" . 2>/dev/null \
  | grep -v ".env" | grep -v "example"

# .gitignore covers .env?
cat .gitignore 2>/dev/null | grep "\.env"

# Hardcoded localhost URLs
grep -r "localhost:3000\|localhost:8000\|127\.0\.0\.1" \
  --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v "\.test\." | grep -v "comment"
```

## Step 2: Dependency audit

```bash
npm audit --audit-level=moderate 2>/dev/null || pnpm audit 2>/dev/null
npx depcheck 2>/dev/null | head -30
```

## Step 3: Code quality

```bash
# Unhandled promises
grep -r "\.then(" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v "catch" | head -10

# any-typed variables
grep -r ": any" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v "// " | head -10

# Console.logs in non-test files
grep -r "console\.log" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v "\.test\." | grep -v "logger" | head -10

# TODO/FIXME count
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" --include="*.py" . 2>/dev/null | grep -v "node_modules"
```

## Step 4: Design quality (UI projects)

```bash
# Inline styles (non-animation)
grep -r "style={{" --include="*.tsx" . 2>/dev/null | grep -v "navbar\|transform\|opacity\|transition" | head -10

# Unstyled buttons
grep -r "<button" --include="*.tsx" . 2>/dev/null | grep -v "className" | head -5
```

## Step 5: Report

Grade each category (A/B/C/D/F) with specific file:line references.

Priority: Security > Correctness > Quality > Style.
