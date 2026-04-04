#!/bin/bash
# D1 Vibe Coding — Quick install
# Copies CLAUDE.md + .claude/ into the current project directory.
# For full infrastructure setup (second brain, iMessage agent, MCP), run setup.sh instead.

set -e

GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "D1 Vibe Coding — Project Install"
echo "================================="
echo ""
echo "Installing to: $PROJECT_DIR"
echo ""

# Copy CLAUDE.md
cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
echo -e "  ${GRN}✓${NC} CLAUDE.md"

# Copy .claude/ (commands, rules, hooks)
mkdir -p "$PROJECT_DIR/.claude"
cp -r "$SCRIPT_DIR/.claude/commands" "$PROJECT_DIR/.claude/"
cp -r "$SCRIPT_DIR/.claude/rules"    "$PROJECT_DIR/.claude/"
cp -r "$SCRIPT_DIR/.claude/hooks"    "$PROJECT_DIR/.claude/"
echo -e "  ${GRN}✓${NC} .claude/ ($(ls "$SCRIPT_DIR/.claude/commands/" | wc -l | tr -d ' ') commands, $(ls "$SCRIPT_DIR/.claude/rules/" | wc -l | tr -d ' ') rules)"

# Merge settings if no global settings exist
SETTINGS_DEST="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS_DEST" ]; then
  mkdir -p "$HOME/.claude"
  cp "$SCRIPT_DIR/settings/settings.json" "$SETTINGS_DEST"
  echo -e "  ${GRN}✓${NC} ~/.claude/settings.json (created)"
else
  echo -e "  ${YLW}!${NC} ~/.claude/settings.json exists — merge settings/settings.json manually"
fi

echo ""
echo -e "${GRN}Done.${NC} CLAUDE.md and .claude/ are in your project."
echo ""
echo "Next steps:"
echo "  1. Add your tokens to ~/.claude/settings.json:"
echo '     "env": { "GITHUB_TOKEN": "...", "ANTHROPIC_API_KEY": "...", "TODOIST_API_TOKEN": "..." }'
echo ""
echo "For full infrastructure (second brain + iMessage agent + MCP):"
echo "  chmod +x setup.sh && ./setup.sh"
echo ""
