#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <skill-folder-name> [output-dir]"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
SKILL_NAME="$1"
OUT_DIR="${2:-$HOME/Desktop}"

# Check skills/ first (shared), then skills-desktop/ (Desktop-only)
if [ -d "$REPO_DIR/skills/$SKILL_NAME" ]; then
  SKILL_DIR="$REPO_DIR/skills/$SKILL_NAME"
elif [ -d "$REPO_DIR/skills-desktop/$SKILL_NAME" ]; then
  SKILL_DIR="$REPO_DIR/skills-desktop/$SKILL_NAME"
else
  echo "Error: Skill directory not found: $SKILL_NAME"
  echo "Checked:"
  echo "  - $REPO_DIR/skills/$SKILL_NAME"
  echo "  - $REPO_DIR/skills-desktop/$SKILL_NAME"
  exit 1
fi

mkdir -p "$OUT_DIR"
OUT_ZIP="$OUT_DIR/${SKILL_NAME}-skill.zip"

cd "$SKILL_DIR"
zip -r "$OUT_ZIP" . -x "*.DS_Store" -x "__MACOSX/*"

echo "✓ Created $OUT_ZIP"
echo "Upload via Claude Desktop > Settings > Capabilities > Upload skill"
