---
description: Check for outdated, unused, and vulnerable dependencies
allowed-tools: Bash(npm:*), Bash(pnpm:*), Bash(npx:*), Bash(pip3:*), Read
argument-hint: "[project-path]"
---

# Deps

Check dependency health for the project at $ARGUMENTS (or current directory).

## Step 1: Detect package manager

```bash
ls pnpm-lock.yaml 2>/dev/null && echo "pnpm" || ls package-lock.json 2>/dev/null && echo "npm" || ls requirements.txt 2>/dev/null && echo "pip"
```

## Step 2: Check for vulnerabilities

```bash
# Node
npm audit --audit-level=low 2>/dev/null || pnpm audit 2>/dev/null

# Python
pip3 check 2>/dev/null
```

## Step 3: Find unused dependencies

```bash
npx depcheck 2>/dev/null
```

## Step 4: Check for outdated packages

```bash
npm outdated 2>/dev/null || pnpm outdated 2>/dev/null
```

## Step 5: Report

For each category:

- **Vulnerabilities**: severity, package, CVE if known
- **Unused**: packages safe to remove (with the `npm uninstall` command ready)
- **Outdated**: version delta, whether it's a major/minor/patch bump

Suggest specific commands to fix the most critical issues.
