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
├── README.md
├── .gitignore
├── install.sh                  # Symlinks ~/.claude/{commands,agents,skills} to this repo
├── claude_desktop_config.json  # Claude Desktop config (macOS only)
├── commands/                   # User-level slash commands (.md)
├── agents/                     # User-level subagents (.md with YAML frontmatter)
├── skills/                     # Skill folders (each containing SKILL.md)
├── project-templates/          # Templates for project-level configs
│   ├── commands/
│   └── agents/
└── sync-scripts/               # Helper scripts
    ├── push-changes.sh
    ├── pull-changes.sh
    └── package-skill.sh
```

Because we symlink entire directories, new files added here appear immediately in `~/.claude/...` without re-running `install.sh`.

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

- Edit or add files in `commands/`, `agents/`, or `skills/`
- Changes reflect instantly in Claude due to directory symlinks
- Sync changes:

```bash
./sync-scripts/push-changes.sh "Describe your change"
# On another machine:
./sync-scripts/pull-changes.sh
```

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
- Skills (Claude Code + Desktop):
  - Location: `skills/<skill-name>/`
  - Must contain `SKILL.md` with YAML frontmatter (`name`, `description`), plus optional `scripts/`, `references/`, `assets/`
  - For Claude Desktop, package a skill as ZIP with:
    ```bash
    ./sync-scripts/package-skill.sh <skill-name>
    # Upload the created ZIP via Claude Desktop > Settings > Capabilities
    ```

## Included examples (migrated)

- Commands:
  - `cleanup.md`, `linear-issue.md`, `memory_improve.md`
- Agents:
  - `marimo-notebook-specialist.md`
  - `r-code-simplifier.md`
  - `r-package-advisor.md`
  - `r-performance-optimizer.md`
  - `r-test-writer.md`
  - `targets-pipeline-reviewer.md`

Usage in Claude Code:
- Commands: `/user:cleanup`, `/user:linear-issue`, `/user:memory_improve`
- Subagents: Select by name in the subagents UI

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
