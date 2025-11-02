#!/bin/bash
set -euo pipefail

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_LINK="$CLAUDE_DIR/commands"
AGENTS_LINK="$CLAUDE_DIR/agents"
SKILLS_LINK="$CLAUDE_DIR/skills"
DESKTOP_CONFIG_DIR="$HOME/Library/Application Support/Claude"
DESKTOP_CONFIG_LINK="$DESKTOP_CONFIG_DIR/claude_desktop_config.json"

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

link_file() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$src" ]; then
    log "Warning: Source file not found: $src"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  backup_and_remove_path "$dest"
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

echo "Setting up Claude configuration from: $REPO_DIR"
mkdir -p "$CLAUDE_DIR"
mkdir -p "$REPO_DIR/commands" "$REPO_DIR/agents" "$REPO_DIR/skills" "$REPO_DIR/skills-code" "$REPO_DIR/skills-desktop"

# Remove existing files from commands and agents by replacing dirs with symlinks
link_dir "$REPO_DIR/commands" "$COMMANDS_LINK"
link_dir "$REPO_DIR/agents" "$AGENTS_LINK"

# Handle skills: merge skills/ (both) and skills-code/ (Code-only) for Claude Code
# skills-desktop/ is NOT symlinked to Code
backup_and_remove_path "$SKILLS_LINK"
mkdir -p "$SKILLS_LINK"
log "Creating merged skills directory for Claude Code"

# Symlink skills from skills/ (both)
if [ -d "$REPO_DIR/skills" ]; then
  for skill_dir in "$REPO_DIR/skills"/*; do
    if [ -d "$skill_dir" ] && [ "$(basename "$skill_dir")" != "." ] && [ "$(basename "$skill_dir")" != ".." ]; then
      skill_name=$(basename "$skill_dir")
      if [ "$skill_name" != ".gitkeep" ]; then
        ln -sf "$skill_dir" "$SKILLS_LINK/$skill_name"
        log "  Linked skill (both): $skill_name"
      fi
    fi
  done
fi

# Symlink skills from skills-code/ (Code-only)
if [ -d "$REPO_DIR/skills-code" ]; then
  for skill_dir in "$REPO_DIR/skills-code"/*; do
    if [ -d "$skill_dir" ] && [ "$(basename "$skill_dir")" != "." ] && [ "$(basename "$skill_dir")" != ".." ]; then
      skill_name=$(basename "$skill_dir")
      if [ "$skill_name" != ".gitkeep" ]; then
        ln -sf "$skill_dir" "$SKILLS_LINK/$skill_name"
        log "  Linked skill (Code-only): $skill_name"
      fi
    fi
  done
fi

# Link Claude Desktop config on macOS only
if [[ "$OSTYPE" == "darwin"* ]]; then
  if link_file "$REPO_DIR/claude_desktop_config.json" "$DESKTOP_CONFIG_LINK"; then
    DESKTOP_LINKED=true
  else
    DESKTOP_LINKED=false
  fi
else
  DESKTOP_LINKED=false
fi

echo
echo "✅ Installation complete!"
echo "- Commands: $COMMANDS_LINK -> $REPO_DIR/commands"
echo "- Agents:   $AGENTS_LINK   -> $REPO_DIR/agents"
echo "- Skills:   $SKILLS_LINK (merged from skills/ and skills-code/)"
if [ "$DESKTOP_LINKED" = true ]; then
  echo "- Desktop:  $DESKTOP_CONFIG_LINK -> $REPO_DIR/claude_desktop_config.json"
fi
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups (previous content, if any): $BACKUP_DIR"
fi
echo
echo "Note: Restart Claude Code and Claude Desktop (if open) to pick up changes."
