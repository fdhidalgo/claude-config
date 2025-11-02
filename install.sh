#!/bin/bash
set -euo pipefail

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_LINK="$CLAUDE_DIR/commands"
AGENTS_LINK="$CLAUDE_DIR/agents"
SKILLS_LINK="$CLAUDE_DIR/skills"

BACKUP_ROOT="$CLAUDE_DIR/install_backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

backup_and_remove_path() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    mkdir -p "$BACKUP_DIR"
    log "Backing up: $path -> $BACKUP_DIR/"
    mv "$path" "$BACKUP_DIR/" || true
  fi
}

link_dir() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  backup_and_remove_path "$dest"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

echo "Setting up Claude configuration from: $REPO_DIR"
mkdir -p "$CLAUDE_DIR"
mkdir -p "$REPO_DIR/commands" "$REPO_DIR/agents" "$REPO_DIR/skills"

# Remove existing files from commands and agents by replacing dirs with symlinks
link_dir "$REPO_DIR/commands" "$COMMANDS_LINK"
link_dir "$REPO_DIR/agents" "$AGENTS_LINK"

# Ensure skills dir exists, then symlink the entire dir for immediate reflection
link_dir "$REPO_DIR/skills" "$SKILLS_LINK"

echo
echo "✅ Installation complete!"
echo "- Commands: $COMMANDS_LINK -> $REPO_DIR/commands"
echo "- Agents:   $AGENTS_LINK   -> $REPO_DIR/agents"
echo "- Skills:   $SKILLS_LINK   -> $REPO_DIR/skills"
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups (previous content, if any): $BACKUP_DIR"
fi
echo
echo "Note: Restart Claude Code and Claude Desktop (if open) to pick up changes."
