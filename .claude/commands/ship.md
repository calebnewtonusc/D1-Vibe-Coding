---
description: Run the full quality gate (typecheck, lint, tests, bundle) before shipping
allowed-tools: Bash(npm:*), Bash(npx:*), Bash(python3:*), Bash(git:*)
---

# Ship

Run the quality gate for `$ARGUMENTS` (defaults to current directory).

## Step 0: .env leak check

```bash
git diff --cached --name-only | grep -E "^\.env|\.env\." && echo "BLOCKED: .env staged" || echo "Clean"
git diff --cached | grep -E "(sk-ant|sk-|ANTHROPIC|API_KEY|SECRET|PASSWORD|TOKEN)" | grep "^\+" | grep -v "example\|placeholder\|your_key\|process\.env\." | head -10
```

If a `.env` file is staged or real secrets appear — **STOP**.

## Step 1: Detect project type

- `package.json` → TypeScript/Node
- `requirements.txt` / `pyproject.toml` → Python
- Both → run both

## Step 2: TypeScript / Node

```bash
npm run typecheck 2>/dev/null || npx tsc --noEmit
npm run lint 2>/dev/null || npx eslint . --max-warnings 0
npm test 2>/dev/null || echo "No test script"
```

Zero errors required on typecheck and lint. All tests must pass.

## Step 3: Python

```bash
python3 -m mypy . 2>/dev/null || echo "mypy not configured"
python3 -m pytest -v 2>/dev/null || echo "No pytest found"
```

## Step 4: Bundle size (Next.js)

```bash
npm run build 2>&1 | tail -30
```

Flag routes over **150KB** first load JS. **250KB** is a hard block.

## Step 5: Summary

```
TYPECHECK: PASS / FAIL ({error count})
LINT:      PASS / FAIL ({error count})
TESTS:     PASS / FAIL / SKIP
BUNDLE:    PASS / WARN (largest route: Xkb)
ENV LEAK:  CLEAN / BLOCKED
```

Clean ship = all green. Then run `/push` or `/deploy`.
