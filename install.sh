#!/bin/bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}Claude Workflow Kit — Installer${NC}"
echo "================================"
echo ""

# Detect project root or use current dir
PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_GLOBAL="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}Installing to:${NC} $PROJECT_DIR"
echo -e "${YELLOW}Global config:${NC} $CLAUDE_GLOBAL"
echo ""

# 1. Copy CLAUDE.md to project
echo "→ Copying CLAUDE.md to project root..."
cp "$SCRIPT_DIR/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/CLAUDE.md"

# 2. Copy .claude/ directory
echo "→ Copying .claude/ directory..."
cp -r "$SCRIPT_DIR/.claude/" "$PROJECT_DIR/.claude/"
echo -e "  ${GREEN}✓${NC} $PROJECT_DIR/.claude/ (commands, rules, templates, snippets)"

# 3. Merge settings into ~/.claude/settings.json
echo "→ Merging settings..."
SETTINGS_SRC="$SCRIPT_DIR/settings/settings.json"
SETTINGS_DEST="$CLAUDE_GLOBAL/settings.json"

if [ ! -f "$SETTINGS_DEST" ]; then
  mkdir -p "$CLAUDE_GLOBAL"
  cp "$SETTINGS_SRC" "$SETTINGS_DEST"
  echo -e "  ${GREEN}✓${NC} Created $SETTINGS_DEST"
else
  echo -e "  ${YELLOW}!${NC} $SETTINGS_DEST already exists — merge manually"
  echo -e "     See $SETTINGS_SRC for the hooks and env blocks to add"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo "Next steps:"
echo "  1. Add your tokens to ~/.claude/settings.json:"
echo '     "env": { "GITHUB_TOKEN": "...", "TODOIST_API_TOKEN": "..." }'
echo "  2. Run 'gh auth login' if you haven't already"
echo "  3. Open Claude Code and try: /new-project my-app"
echo ""
echo "See SETUP.md for full configuration options."
