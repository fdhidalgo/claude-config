# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal Claude configuration management system that uses Git and symlinks to version-control and sync Claude Code customizations (commands, agents, skills) across machines. Changes made here are instantly reflected in `~/.claude/` due to directory symlinks.

## Architecture Overview

### Three-Tier Skill System

The repository uses three separate skill directories to manage environment compatibility:

1. **`skills/`** - Shared skills for both Claude Code and Desktop
   - Symlinked to `~/.claude/skills/` (immediately available in Code)
   - Can be packaged for Desktop upload

2. **`skills-code/`** - Code-only skills
   - Symlinked to `~/.claude/skills/` (immediately available in Code)
   - NOT available in Desktop (prevents tool availability confusion)

3. **`skills-desktop/`** - Desktop-only skills
   - NOT symlinked (prevents Code from seeing unavailable MCP tools)
   - Must be packaged and manually uploaded to Desktop

**Critical**: The `install.sh` script creates a merged `~/.claude/skills/` directory by symlinking individual skill directories from both `skills/` and `skills-code/`, but NOT from `skills-desktop/`.

### Configuration Components

- **Commands** (`commands/`): Slash commands (`.md` files) → `/user:<filename>`
- **Agents** (`agents/`): Subagents (`.md` with YAML frontmatter)
- **Skills** (three directories): Bundled capabilities with optional scripts/references/assets
- **Library** (`library/`): Templates for project-specific configurations (not symlinked)
- **Desktop config** (`claude_desktop_config.json`): MCP server configs (macOS only)

All component directories (except `library/`) are symlinked to `~/.claude/`, meaning new files appear instantly without reinstalling.

### Universal vs Project-Specific Strategy

**Key Principle**: Skills use progressive disclosure (only metadata always in context), so context pollution is minimal. Commands and agents appear in UI, so separation matters more.

**Universal** (this repo, synced across machines):
- **Skills**: Most skills go here with specific descriptions that trigger only when relevant
- **Commands**: Small set of general-purpose commands (`/user:cleanup`, `/user:linear-issue`)
- **Agents**: Domain expertise used across projects (R, Python, general code review)

**Project-Specific** (`.claude/` in each project repo):
- **Skills**: Company APIs, project architecture, client workflows
- **Commands**: Project operations (`/project:deploy`, `/project:run-tests`)
- **Agents**: Project-specific specialists

**Library** (templates for reuse):
- Store reusable but project-adaptable configurations in `library/`
- Copy to project `.claude/` directories and customize as needed
- Enables reuse without polluting universal context

## Common Development Tasks

### Setup and Installation

```bash
# Initial setup (current machine)
./install.sh

# New machine setup
mkdir -p "$HOME/Documents/personal_scripts"
cd "$HOME/Documents/personal_scripts"
gh repo clone fdhidalgo/claude-config
cd claude-config
./install.sh
```

The install script:
- Backs up existing `~/.claude/` content to `~/.claude/install_backups/<timestamp>/`
- Symlinks `commands/`, `agents/` directories
- Creates merged `skills/` from `skills/` + `skills-code/` (excludes `skills-desktop/`)
- On macOS: symlinks `claude_desktop_config.json` to `~/Library/Application Support/Claude/`

### Sync Changes Across Machines

```bash
# Push changes
./sync-scripts/push-changes.sh "Description of change"

# Pull changes on another machine
./sync-scripts/pull-changes.sh
```

### Package Skills for Desktop

```bash
# Package any skill (searches all three directories automatically)
./sync-scripts/package-skill.sh <skill-name>

# Upload the created ZIP via:
# Claude Desktop > Settings > Capabilities > Upload skill
```

## File Format Requirements

### Commands
- Location: `commands/`
- Format: Markdown (`.md`)
- Filename becomes command: `cleanup.md` → `/user:cleanup`
- Content: Plain markdown with instructions

### Agents
- Location: `agents/`
- Format: Markdown with YAML frontmatter
- Required frontmatter fields: `name`, `description`
- Optional fields: `model`, `allowed-tools`, `examples`

### Skills
- Structure: `skill-name/SKILL.md` (required) + optional `scripts/`, `references/`, `assets/`
- Required SKILL.md frontmatter: `name`, `description`
- Choose directory based on environment compatibility:
  - Both environments → `skills/`
  - Code-only features → `skills-code/`
  - Desktop-only MCP tools → `skills-desktop/`

## Writing Effective Skill Descriptions

Skills use **model-invoked activation** - Claude decides when to use them based on the description. Write descriptions that are specific enough to activate only when relevant.

**Progressive Disclosure**: Only metadata (name + description, ~100 words) is always in context. Full SKILL.md content loads only when Claude activates the skill.

### Description Best Practices

**❌ Too generic** (activates unnecessarily):
```yaml
description: Helps with data analysis
```

**✅ Specific with clear triggers**:
```yaml
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when working with Excel files, .xlsx spreadsheets, or analyzing tabular data with formulas.
```

**✅ Include project-specific markers** (for project skills):
```yaml
description: Review R package code for CRAN compliance before commits. Use when working in R package projects with DESCRIPTION, R/, man/, and tests/ directories, or when explicitly asked to review package structure.
```

**Structure**: Include both WHAT the skill does and WHEN to use it:
- What: Core capabilities and features
- When: File types, project patterns, explicit keywords that should trigger activation

This ensures skills activate automatically when relevant but stay dormant otherwise, minimizing context pollution.

## Secret Management

**Critical**: Never commit API keys or tokens. The repository uses environment variables for sensitive configuration.

1. Store secrets in shell config (`~/.zshrc`, `~/.bashrc`):
   ```bash
   export OBSIDIAN_API_KEY="<your-key>"
   ```

2. Reference in `claude_desktop_config.json` using `${VAR_NAME}` syntax

3. Restart Claude Desktop after changing environment variables

See `SECRETS.md` for current required environment variables.

## Development Workflow

1. **Edit files** in `commands/`, `agents/`, or `skills/` directories
2. **Test immediately** (changes reflect instantly due to symlinks)
3. **Commit changes**: Use standard git workflow
4. **Sync to other machines**: Run `./sync-scripts/pull-changes.sh`
5. **For Desktop skills**: Package and upload via `package-skill.sh`

## Project-Level Configurations

### Initialize a New Project with Templates

Use the interactive initialization script to copy templates from the library:

```bash
cd /path/to/your/project
~/Documents/personal_scripts/claude-config/sync-scripts/init-project.sh
```

The script will:
1. List available templates from `library/skills/`, `library/commands/`, `library/agents/`
2. Let you select which to copy to `.claude/` in your project
3. Create project-specific configurations you can customize

### Manual Setup (Alternative)

To add project-specific configurations manually:

```bash
cd /path/to/your/project
mkdir -p .claude/commands .claude/agents .claude/skills

# Copy templates or create new configs
cp ~/Documents/personal_scripts/claude-config/library/commands/example.md .claude/commands/
# Or use old project-templates if still available
cp -R ~/Documents/personal_scripts/claude-config/project-templates/commands/* .claude/commands/ 2>/dev/null || true

# Customize the files, then commit
git add .claude/
git commit -m "Add Claude Code configuration"
```

### Usage in Projects

Team members automatically get access to project configs:
- Commands: `/project:<command-name>`
- Agents: Available in subagent selector (project-scoped)
- Skills: Auto-discovered based on description (project-scoped)

### Creating Library Templates

To create reusable templates for future projects:

```bash
# Create template in library
mkdir -p ~/Documents/personal_scripts/claude-config/library/skills/my-template-skill
# Edit SKILL.md with placeholder variables: {{PROJECT_NAME}}, {{API_URL}}, etc.

# The template is now available for init-project.sh
```

## Platform Constraints

- Designed for macOS (paths assume macOS)
- Desktop config symlink only works on macOS
- Requires: Git, GitHub CLI (`gh`) authenticated

## Verification Commands

```bash
# Verify symlinks are correct
ls -l ~/.claude

# On macOS, also check Desktop config
ls -l ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Should see:
# commands -> .../claude-config/commands
# agents -> .../claude-config/agents
# skills (directory containing symlinks to individual skills)
```

If symlinks break, re-run `./install.sh`.
