#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <skill-folder-name> [output-dir]"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
SKILL_NAME="$1"
SKILL_DIR="$REPO_DIR/skills/$SKILL_NAME"
OUT_DIR="${2:-$HOME/Desktop}"

if [ ! -d "$SKILL_DIR" ]; then
  echo "Error: Skill directory not found: $SKILL_DIR"
  exit 1
fi

mkdir -p "$OUT_DIR"
OUT_ZIP="$OUT_DIR/${SKILL_NAME}-skill.zip"

cd "$SKILL_DIR"
zip -r "$OUT_ZIP" . -x "*.DS_Store" -x "__MACOSX/*"

echo "✓ Created $OUT_ZIP"
echo "Upload via Claude Desktop > Settings > Capabilities > Upload skill"
