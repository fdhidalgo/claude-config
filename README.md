# claude-config

Personal Claude Code configuration sync (commands, agents, and skills) using a GitHub repo and symlinks. This lets you version-control your Claude customizations and keep them in sync across computers.

## What this provides

- Single source of truth in this repo
- Symlinked directories so edits are reflected immediately in Claude
- Easy migration to new machines with a one-time install script
- Helper scripts to push/pull changes and package skills for Claude Desktop

## Directory structure

```
claude-config/
├── README.md                   # This file
├── CLAUDE.md                   # Guide for Claude Code instances
├── .gitignore
├── install.sh                  # Symlinks and merges skills for Code
├── claude_desktop_config.json  # Claude Desktop config (macOS only)
├── commands/                   # Universal slash commands (.md)
├── agents/                     # Universal subagents (.md with YAML frontmatter)
├── skills/                     # Universal skills (both Code + Desktop)
├── skills-code/                # Code-only universal skills
├── skills-desktop/             # Desktop-only universal skills
├── library/                    # Templates for project-specific configs
│   ├── README.md              # Template creation guide
│   ├── skills/                # Skill templates with placeholders
│   ├── commands/              # Command templates
│   └── agents/                # Agent templates
├── project-templates/          # (Legacy) Old project templates
│   ├── commands/
│   └── agents/
└── sync-scripts/               # Helper scripts
    ├── push-changes.sh
    ├── pull-changes.sh
    ├── package-skill.sh
    └── init-project.sh         # Copy library templates to projects
```

Because we symlink entire directories, new files added here appear immediately in `~/.claude/...` without re-running `install.sh`.

## Configuration Strategy

This repo uses a **three-tier architecture** to balance reuse and context efficiency:

### 1. Universal (`skills/`, `commands/`, `agents/`)
**When to use**: Domain expertise and general utilities used across all projects

- Skills use progressive disclosure (~100 words metadata always in context)
- Most skills should be universal with specific descriptions
- Examples: R package advisor, cleanup command, performance optimizer

**Decision rule**:
- Skills: Used across ALL projects? → Universal
- Commands: Universally useful? → Universal (appears as `/user:name`)
- Agents: Domain expertise applies everywhere? → Universal

### 2. Library (`library/`)
**When to use**: Reusable patterns that need project-specific customization

- Templates with placeholders (`{{API_URL}}`, `{{PROJECT_NAME}}`)
- Copy to projects with `init-project.sh` and customize
- Examples: API client template, deployment commands, code reviewer template

**Decision rule**:
- Applies to multiple projects BUT needs customization? → Library template

### 3. Project-specific (`.claude/` in each project)
**When to use**: Truly unique to one project

- Company/client-specific APIs and schemas
- Project architecture documentation
- Project-specific workflows

**Decision rule**:
- Only used in one project? → Project-specific (appears as `/project:name`)

### Quick Decision Guide

```
Universal: R package advisor, Python linter, /user:cleanup
Library:   API client (different URLs), deploy (different envs)
Project:   Acme Corp CRM API, Project X architecture specialist
```

## Prerequisites

- macOS (paths assume macOS)
- Git and GitHub CLI (`gh`) installed and authenticated

## Initial setup (this machine)

```bash
cd "$HOME/Documents/personal_scripts/claude-config"
./install.sh
```

This replaces `~/.claude/commands`, `~/.claude/agents`, and `~/.claude/skills` with symlinks pointing to this repo. Previous content is backed up to `~/.claude/install_backups/<timestamp>/`.

## New computer setup

```bash
mkdir -p "$HOME/Documents/personal_scripts"
cd "$HOME/Documents/personal_scripts"
gh repo clone fdhidalgo/claude-config
cd claude-config
./install.sh
```

## Usage workflow

### Universal Configs

- Edit or add files in `commands/`, `agents/`, or `skills/`
- Changes reflect instantly in Claude due to directory symlinks
- Sync changes:

```bash
./sync-scripts/push-changes.sh "Describe your change"
# On another machine:
./sync-scripts/pull-changes.sh
```

### Project-Specific Configs

Initialize a project with library templates:

```bash
cd /path/to/your/project
~/Documents/personal_scripts/claude-config/sync-scripts/init-project.sh
```

This copies templates from `library/` to your project's `.claude/` directory where you can customize them.

## File format requirements

- Commands (Claude Code):
  - Location: `commands/`
  - Format: Markdown (`.md`)
  - Filename becomes command name (e.g., `cleanup.md` => `/user:cleanup`)
- Subagents (Claude Code):
  - Location: `agents/`
  - Format: Markdown with YAML frontmatter containing at least:
    - name: string
    - description: string
    - optional: allowed-tools, examples, etc.
- Skills (three separate directories):
  - **`skills/` - Both Code + Desktop**: Skills that work in both environments
    - Automatically available in Claude Code (symlinked)
    - Can be packaged for Claude Desktop
    - Use when skill works with tools available in both
  - **`skills-code/` - Code-only**: Skills that only work in Claude Code
    - Automatically available in Claude Code (symlinked)
    - NOT available in Desktop (prevents confusion about missing tools)
    - Use when skill requires Code-specific features or MCP tools
  - **`skills-desktop/` - Desktop-only**: Skills that only work in Claude Desktop
    - NOT available in Code (prevents confusion about missing MCP tools)
    - Must be packaged and uploaded to Desktop
    - Use when skill requires Desktop-specific MCP tools
  - All skills must contain `SKILL.md` with YAML frontmatter (`name`, `description`), plus optional `scripts/`, `references/`, `assets/`
  - **Package for Desktop**:
    ```bash
    ./sync-scripts/package-skill.sh <skill-name>
    # Automatically searches all three directories
    # Upload the created ZIP via Claude Desktop > Settings > Capabilities
    ```

## Included examples (migrated)

**Commands**:
- `cleanup.md`, `linear-issue.md`, `memory_improve.md`

**Agents**:
- `marimo-notebook-specialist.md`
- `r-code-simplifier.md`
- `r-package-advisor.md`
- `r-performance-optimizer.md`
- `r-test-writer.md`
- `targets-pipeline-reviewer.md`

**Skills**:
- **Both (Code + Desktop)** (`skills/`):
  - `skill-creator` - Create new skills with proper structure
- **Code-only** (`skills-code/`):
  - _(empty - add Code-specific skills here)_
- **Desktop-only** (`skills-desktop/`):
  - `academic-reviewer`, `code-agent-builder`, `mochi-flashcards`, `student-feedback`, `weekly-reflection`

**Usage in Claude Code**:
- Commands: `/user:cleanup`, `/user:linear-issue`, `/user:memory_improve`
- Subagents: Select by name in the subagents UI
- Skills: All skills from `skills/` and `skills-code/` are automatically available

**Usage in Claude Desktop**:
- Skills must be packaged and uploaded manually:
  ```bash
  ./sync-scripts/package-skill.sh <skill-name>
  # Then upload via Settings > Capabilities > Upload skill
  ```

## Project-level components

To add project-specific commands/agents to a code repo:

```bash
mkdir -p .claude/commands .claude/agents
cp -R ~/Documents/personal_scripts/claude-config/project-templates/commands/* .claude/commands/ 2>/dev/null || true
cp -R ~/Documents/personal_scripts/claude-config/project-templates/agents/* .claude/agents/ 2>/dev/null || true
git add .claude/
git commit -m "Add Claude Code configuration"
```

Team members can use `/project:<command-name>`.

## Claude Desktop integration (macOS only)

The install script also symlinks `claude_desktop_config.json` on macOS. This syncs your MCP server configurations and Desktop preferences.

**Important**: Before committing changes to `claude_desktop_config.json`, review it for secrets:
- API keys in `env` sections
- Tokens or passwords
- Any sensitive configuration

Either:
1. Remove secrets from the file and manage them separately (recommended)
2. Use environment variables instead of hardcoded values
3. Add the file to `.gitignore` if it contains too many secrets

On Linux systems, the Desktop config is ignored (Claude Desktop uses a different location).

## Troubleshooting

- Verify symlinks:
  ```bash
  ls -l ~/.claude
  # On macOS, also check:
  ls -l ~/Library/Application\ Support/Claude/claude_desktop_config.json
  ```
  You should see `commands -> .../claude-config/commands`, etc.
- Restart Claude Code after major changes
- Restart Claude Desktop after changing `claude_desktop_config.json`
- If symlinks break, just re-run `./install.sh`

## Security

- Never commit API keys or secrets. Use environment variables or `.env` files (ignored by `.gitignore`).
- This repo ignores common secret patterns and OS junk.

---

Personal setup by fdhidalgo to keep Claude Code configurations portable, versioned, and instantly synced across machines.
