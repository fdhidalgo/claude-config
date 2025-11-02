#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$REPO_DIR"

git add -A
if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

MSG="${1:-}"
if [ -z "$MSG" ]; then
  read -r -p "Commit message: " MSG
  MSG="${MSG:-Update: $(date -Iseconds)}"
fi

git commit -m "$MSG" || true
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
git push -u origin "$BRANCH"
echo "✓ Changes pushed to origin/$BRANCH"
