---
description: Deep audit a project directory — bugs, incomplete work, security issues, inconsistencies
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(npm:*), Bash(npx tsc:*)
argument-hint: "<project path>"
---

# Project Audit

## Step 1: Locate the project

Use `$ARGUMENTS` if given, otherwise current directory. Confirm a valid project (package.json, pyproject.toml, etc.).

## Step 2: Understand the project

Read: package.json, README.md, top-level source files. Build a mental map before diving in.

Do NOT comment on code you haven't read.

## Step 3: Compiler/type checks

```bash
npx tsc --noEmit
python3 -m mypy . --ignore-missing-imports 2>&1 | head -50
```

Document all errors. Don't fix yet.

## Step 4: Scan for incomplete work

Search for: `TODO, FIXME, HACK, XXX, unimplemented, placeholder, stub, @ts-ignore, @ts-expect-error`

Any in production code paths is a finding.

## Step 5: Security audit

- SQL injection: string interpolation in queries
- Secrets in source: hardcoded API keys, tokens, passwords
- `eval()` / `Function()` with user-supplied input
- Missing auth checks on sensitive routes
- `dangerouslySetInnerHTML` with unsanitized content
- PII logged at any level
- User-supplied IDs trusted without ownership verification

## Step 6: TypeScript safety

- `as any` without explanatory comment
- Non-null assertions (`!`) on potentially null values
- `@ts-ignore` without explanation
- External data typed as `any` instead of `unknown`

## Step 7: Async correctness

- `await` inside a loop when calls are independent (use `Promise.all`)
- Fire-and-forget Promises without `.catch()`
- Mixed `async/await` and `.then()/.catch()` in the same function

## Step 8: Consistency

- Dead code (exported but never imported)
- Duplicate logic across files
- Naming inconsistencies (camelCase vs snake_case for same concept)
- Env variables used but not in `.env.example`

## Step 9: Findings report

Group by severity: **Critical** | **High** | **Medium** | **Low** | **Nit**

For each finding:

```
[SEVERITY] file:line
Category: Security | TypeScript | Async | Incomplete | Consistency
Issue: <what's wrong>
Evidence: <exact code>
Fix: <what to do>
```

Summary table with count per severity.

Rules: Read every file you cite. Never report without file:line evidence. Read-only — don't implement fixes unless asked.
