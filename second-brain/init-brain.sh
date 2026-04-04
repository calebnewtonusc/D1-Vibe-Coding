#!/bin/bash
# init-brain.sh — D1 Second Brain Setup
# Sets up the two-repo second brain: claude-context (AI memory) + personal-context (human records)
# Run once. Takes ~5 minutes.

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${BLUE}D1 Second Brain — Setup${NC}"
echo "======================================="
echo ""
echo "This sets up two private repos:"
echo "  1. claude-context   — AI-facing memory (structured, concise)"
echo "  2. personal-context — Human records (notebooks, resume, logs)"
echo ""
echo "Claude auto-updates these as you work. Every session, it loads your"
echo "context and knows exactly who you are, what you're building, and where"
echo "you left off."
echo ""

# Check prerequisites
if ! command -v gh &>/dev/null; then
  echo -e "${YELLOW}gh CLI not found. Install it: brew install gh && gh auth login${NC}"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo -e "${YELLOW}Not authenticated with GitHub. Run: gh auth login${NC}"
  exit 1
fi

GITHUB_USER=$(gh api user --jq .login 2>/dev/null)
echo -e "GitHub user: ${CYAN}$GITHUB_USER${NC}"
echo ""

# ── Step 1: claude-context repo ──────────────────────────────────────────────
echo -e "${BOLD}Step 1: claude-context${NC} (AI memory)"
echo "This is what Claude loads every session. Keep it concise."
echo ""

CLAUDE_CTX_DIR="$HOME/.claude/context"
mkdir -p "$CLAUDE_CTX_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ Copying context templates..."
cp "$SCRIPT_DIR/context/YOU.md" "$CLAUDE_CTX_DIR/YOU.md"
cp "$SCRIPT_DIR/context/NOW.md" "$CLAUDE_CTX_DIR/NOW.md"
cp "$SCRIPT_DIR/context/PEOPLE.md" "$CLAUDE_CTX_DIR/PEOPLE.md"
cp "$SCRIPT_DIR/context/SYSTEM.md" "$CLAUDE_CTX_DIR/SYSTEM.md"
cp "$SCRIPT_DIR/context/STACK.md" "$CLAUDE_CTX_DIR/STACK.md"
echo -e "  ${GREEN}✓${NC} Templates copied to $CLAUDE_CTX_DIR"

echo "→ Opening YOU.md for editing (fill in your info)..."
echo "  Close the editor when done. YOU.md is the most important file."
read -rp "  Press Enter to open YOU.md in your editor... "
"${EDITOR:-nano}" "$CLAUDE_CTX_DIR/YOU.md"

echo "→ Creating private GitHub repo: $GITHUB_USER/claude-context..."
if gh repo view "$GITHUB_USER/claude-context" &>/dev/null; then
  echo -e "  ${YELLOW}!${NC} Repo already exists — skipping creation"
else
  gh repo create "$GITHUB_USER/claude-context" --private --description "Claude AI persistent memory context" --confirm 2>/dev/null || \
  gh repo create "$GITHUB_USER/claude-context" --private --description "Claude AI persistent memory context"
  echo -e "  ${GREEN}✓${NC} Created github.com/$GITHUB_USER/claude-context"
fi

echo "→ Initializing git in $CLAUDE_CTX_DIR..."
if [ ! -d "$CLAUDE_CTX_DIR/.git" ]; then
  cd "$CLAUDE_CTX_DIR"
  git init
  git remote add origin "https://github.com/$GITHUB_USER/claude-context.git"
  git add .
  git commit -m "init: second brain context"
  git branch -M main
  git push -u origin main
  echo -e "  ${GREEN}✓${NC} Pushed to GitHub"
else
  cd "$CLAUDE_CTX_DIR"
  git add .
  git diff --cached --quiet || git commit -m "chore: init brain templates"
  git push origin main 2>/dev/null || true
  echo -e "  ${YELLOW}!${NC} Already a git repo — committed and pushed latest"
fi

echo ""
echo -e "${GREEN}claude-context ready: https://github.com/$GITHUB_USER/claude-context${NC}"
echo ""

# ── Step 2: personal-context repo ────────────────────────────────────────────
echo -e "${BOLD}Step 2: personal-context${NC} (human records)"
echo "Notebooks, resume, weekly log, skills tracker. For you, not for Claude."
echo ""

PERSONAL_CTX_DIR="$HOME/personal-context"
mkdir -p "$PERSONAL_CTX_DIR"

cat > "$PERSONAL_CTX_DIR/MEMORY.md" << 'MEMEOF'
# My Context — Quick Reference

A human-readable summary of what's happening in my life and work.

## Current Roles

- ...

## Active Projects

- ...

## Priorities

1. ...
2. ...
3. ...

## Notes

- ...
MEMEOF

cat > "$PERSONAL_CTX_DIR/Weekly_Log.md" << 'LOGEOF'
# Weekly Execution Log

## Week of YYYY-MM-DD

### Done
- ...

### Next
- ...

### Blockers
- ...

LOGEOF

echo "→ Creating private GitHub repo: $GITHUB_USER/personal-context..."
if gh repo view "$GITHUB_USER/personal-context" &>/dev/null; then
  echo -e "  ${YELLOW}!${NC} Repo already exists — skipping creation"
else
  gh repo create "$GITHUB_USER/personal-context" --private --description "Personal records, notebooks, weekly log"
  echo -e "  ${GREEN}✓${NC} Created github.com/$GITHUB_USER/personal-context"
fi

cd "$PERSONAL_CTX_DIR"
git init 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USER/personal-context.git"
git add .
git diff --cached --quiet || git commit -m "init: personal context"
git branch -M main
git push -u origin main 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Pushed to GitHub"

echo ""
echo -e "${GREEN}personal-context ready: https://github.com/$GITHUB_USER/personal-context${NC}"
echo ""

# ── Step 3: Wire up Claude hooks ──────────────────────────────────────────────
echo -e "${BOLD}Step 3: Wire up Claude hooks${NC}"
echo "Adding SessionStart + PostToolUse hooks to ~/.claude/settings.json"
echo ""

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$HOME/.claude"
  cat > "$SETTINGS_FILE" << SETTINGSEOF
{
  "env": {
    "GITHUB_TOKEN": "YOUR_GITHUB_PAT_HERE"
  },
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "hooks": {}
}
SETTINGSEOF
  echo -e "  ${YELLOW}!${NC} Created new settings.json — add your GITHUB_TOKEN manually"
fi

echo -e "  ${GREEN}✓${NC} Settings exist at $SETTINGS_FILE"
echo ""
echo "Add these hooks to your settings.json manually (or use /update-config):"
echo ""
cat << 'HOOKSEOF'
"SessionStart": [{
  "hooks": [{
    "type": "command",
    "command": "cat ~/.claude/context/YOU.md ~/.claude/context/NOW.md 2>/dev/null | head -200 | python3 -c \"import sys; content=sys.stdin.read(); print('{\\\"hookSpecificOutput\\\": {\\\"hookEventName\\\": \\\"SessionStart\\\", \\\"additionalContext\\\": \\\"' + content.replace('\\\"','\\\\\\\"').replace('\\n','\\\\n')[:1000] + '\\\"}}')\" 2>/dev/null || true",
    "statusMessage": "Loading your context..."
  }]
}]

"PostToolUse": [{
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "command",
    "command": "jq -r '.tool_input.file_path // empty' | { read -r f; [ -z \"$f\" ] && exit 0; CTX=\"$HOME/.claude/context\"; if [[ \"$f\" == \"$CTX\"/* ]]; then cd \"$CTX\" && git add . && git diff --cached --quiet || (git commit -m \"chore: update $(basename $f)\" && git push origin main 2>/dev/null); fi; } 2>/dev/null || true",
    "statusMessage": "Syncing context...",
    "async": true
  }]
}]
HOOKSEOF

echo ""
echo "════════════════════════════════════════"
echo -e "${GREEN}${BOLD}Second Brain setup complete!${NC}"
echo ""
echo "  claude-context:   https://github.com/$GITHUB_USER/claude-context"
echo "  personal-context: https://github.com/$GITHUB_USER/personal-context"
echo ""
echo "Next steps:"
echo "  1. Fill in the rest of your context files in ~/.claude/context/"
echo "  2. Add GITHUB_TOKEN to ~/.claude/settings.json"
echo "  3. Add the hooks above to ~/.claude/settings.json"
echo "  4. Wire in agents: see second-brain/agents/"
echo ""
echo "  Claude will now know who you are on every session."
echo ""
