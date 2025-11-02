#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$REPO_DIR"

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
git fetch --all --prune
git pull --rebase origin "$BRANCH"
echo "✓ Pulled latest from origin/$BRANCH"
echo "Symlinked directories mean updates reflect immediately."
