#!/bin/bash
set -euo pipefail

# Initialize Claude Code project configurations from library templates
# Usage: ./sync-scripts/init-project.sh [project-path]

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
LIBRARY_DIR="$REPO_DIR/library"

cd "$PROJECT_DIR"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

# Create project .claude directory structure
mkdir -p .claude/commands .claude/agents .claude/skills

log "Initializing Claude Code project configuration in: $(pwd)"

# Check if library directory exists
if [ ! -d "$LIBRARY_DIR" ]; then
  log "Warning: Library directory not found at $LIBRARY_DIR"
  log "Creating empty library directories..."
  mkdir -p "$LIBRARY_DIR"/{skills,commands,agents}
fi

# Function to list available templates
list_templates() {
  local type=$1
  local dir="$LIBRARY_DIR/$type"

  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    log "\nAvailable $type templates:"
    for item in "$dir"/*; do
      if [ -e "$item" ]; then
        echo "  - $(basename "$item")"
      fi
    done
    return 0
  else
    log "No $type templates found in library"
    return 1
  fi
}

# Function to copy template
copy_template() {
  local type=$1
  local name=$2
  local src="$LIBRARY_DIR/$type/$name"
  local dest=".claude/$type/$name"

  if [ ! -e "$src" ]; then
    log "Error: Template not found: $src"
    return 1
  fi

  if [ -e "$dest" ]; then
    log "Warning: $dest already exists, skipping"
    return 1
  fi

  cp -R "$src" "$dest"
  log "✓ Copied $type/$name"
  return 0
}

# Interactive mode: ask which templates to copy
echo "================================================"
echo "Claude Code Project Configuration Setup"
echo "================================================"
echo ""

# Skills
if list_templates "skills"; then
  echo ""
  read -p "Copy skill templates? (y/n or specify names separated by spaces): " -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for skill in "$LIBRARY_DIR/skills"/*; do
      if [ -d "$skill" ]; then
        copy_template "skills" "$(basename "$skill")"
      fi
    done
  elif [[ ! $REPLY =~ ^[Nn]$ ]]; then
    for name in $REPLY; do
      copy_template "skills" "$name"
    done
  fi
fi

# Commands
if list_templates "commands"; then
  echo ""
  read -p "Copy command templates? (y/n or specify names separated by spaces): " -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for cmd in "$LIBRARY_DIR/commands"/*; do
      if [ -f "$cmd" ]; then
        copy_template "commands" "$(basename "$cmd")"
      fi
    done
  elif [[ ! $REPLY =~ ^[Nn]$ ]]; then
    for name in $REPLY; do
      copy_template "commands" "$name"
    done
  fi
fi

# Agents
if list_templates "agents"; then
  echo ""
  read -p "Copy agent templates? (y/n or specify names separated by spaces): " -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for agent in "$LIBRARY_DIR/agents"/*; do
      if [ -f "$agent" ]; then
        copy_template "agents" "$(basename "$agent")"
      fi
    done
  elif [[ ! $REPLY =~ ^[Nn]$ ]]; then
    for name in $REPLY; do
      copy_template "agents" "$name"
    done
  fi
fi

echo ""
log "Project initialization complete!"
log "Project .claude directory: $(pwd)/.claude"
echo ""
echo "Next steps:"
echo "1. Customize the project-specific configs in .claude/"
echo "2. Add .claude/ to git:"
echo "   git add .claude/"
echo "   git commit -m 'Add Claude Code configuration'"
echo ""
echo "Team members will automatically have access to these configs when they clone/pull."
