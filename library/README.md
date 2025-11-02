# Library: Project Configuration Templates

This directory contains reusable templates for project-specific Claude Code configurations. Unlike universal configs in `skills/`, `commands/`, and `agents/` (which are symlinked and available everywhere), library templates are **copied and customized** for each project.

## Purpose

**Problem**: Some configurations are useful across projects but need customization (API endpoints, project-specific schemas, team conventions). Making them universal pollutes context; making them project-only prevents reuse.

**Solution**: Store templates here, copy to project `.claude/` directories, and customize as needed.

## Directory Structure

```
library/
├── README.md (this file)
├── skills/          # Skill templates
│   └── example-api-client/
│       └── SKILL.md # Uses placeholders: {{API_URL}}, {{PROJECT_NAME}}
├── commands/        # Command templates
│   └── deploy.md    # Template for deployment commands
└── agents/          # Agent templates
    └── project-reviewer.md # Template for project-specific reviewers
```

## Usage

### Copy Templates to a Project

Use the interactive initialization script:

```bash
cd /path/to/your/project
~/Documents/personal_scripts/claude-config/sync-scripts/init-project.sh
```

This will:
1. List available templates from `library/skills/`, `library/commands/`, `library/agents/`
2. Let you select which to copy
3. Place them in `.claude/` of your project

### Customize After Copying

After copying templates to your project:

1. Replace placeholders (e.g., `{{API_URL}}`, `{{PROJECT_NAME}}`)
2. Adjust descriptions to include project-specific markers
3. Add/remove functionality as needed

```bash
# In your project
cd .claude/skills/api-client
# Edit SKILL.md to replace {{API_URL}} with actual endpoint
vim SKILL.md
```

### Commit to Project Repo

```bash
git add .claude/
git commit -m "Add Claude Code configuration"
```

Team members automatically get the configurations when they clone/pull.

## Creating New Templates

### When to Create a Library Template

Create a library template when:
- You've built a configuration that works well in one project
- You anticipate needing it in other projects
- It requires project-specific customization (URLs, schemas, naming)

**Don't create a library template if**:
- The config works universally without changes → put in `skills/`, `commands/`, or `agents/`
- It's only needed once → keep it project-specific

### Template Creation Process

1. **Start with a working config** from an existing project

2. **Identify customization points** - what varies between projects?
   - API endpoints → `{{API_URL}}`
   - Project name → `{{PROJECT_NAME}}`
   - Database schemas → `{{DB_SCHEMA}}`
   - File paths → `{{PROJECT_ROOT}}`

3. **Replace with placeholders**:
   ```yaml
   ---
   name: {{PROJECT_NAME}}-api-client
   description: API client for {{PROJECT_NAME}}. Use when working with {{PROJECT_NAME}} API endpoints at {{API_URL}}.
   ---
   ```

4. **Document placeholders** in comments:
   ```markdown
   <!-- Replace before using:
   - {{API_URL}}: Your project's API endpoint
   - {{PROJECT_NAME}}: Name of your project
   -->
   ```

5. **Copy to library**:
   ```bash
   cp -R /path/to/project/.claude/skills/api-client ~/Documents/personal_scripts/claude-config/library/skills/
   ```

6. **Test** by using `init-project.sh` in a new project

## Example Templates

### Skill Template: API Client

```yaml
---
name: {{PROJECT_NAME}}-api-client
description: HTTP client for {{PROJECT_NAME}} API at {{API_URL}}. Use when making API calls, testing endpoints, or working with API documentation.
---

# {{PROJECT_NAME}} API Client

<!-- Replace before using:
- {{API_URL}}: Your project's API base URL (e.g., https://api.example.com)
- {{PROJECT_NAME}}: Project name (e.g., my-app)
-->

## Configuration

Base URL: `{{API_URL}}`

## Available Endpoints

[Document your endpoints here]
```

### Command Template: Deploy

```markdown
<!-- Replace before using:
- {{STAGING_ENV}}: Staging environment name
- {{PROD_ENV}}: Production environment name
-->

Deploy the application to staging or production.

Usage:
- Ask "Deploy to staging" → deploys to {{STAGING_ENV}}
- Ask "Deploy to production" → deploys to {{PROD_ENV}}

Steps:
1. Run tests
2. Build artifacts
3. Deploy to target environment
4. Verify deployment
```

### Agent Template: Project Reviewer

```yaml
---
name: {{PROJECT_NAME}}-reviewer
description: Review code for {{PROJECT_NAME}} following team conventions. Use when reviewing PRs or checking code quality in {{PROJECT_NAME}}.
---

# {{PROJECT_NAME}} Code Reviewer

<!-- Replace before using:
- {{PROJECT_NAME}}: Project name
- {{STYLE_GUIDE_URL}}: Link to style guide
-->

Review code following these team conventions:

[Add your team's conventions here]

Reference: {{STYLE_GUIDE_URL}}
```

## Maintenance

### Keep Templates Updated

When you improve a configuration in a project:

1. Consider if the improvement applies to the template
2. Update the library template
3. Optionally update other projects using that template

### Version Templates

Include a version comment in templates for tracking:

```yaml
---
name: api-client
description: API client template
# Template version: 2.0 (2025-11-02)
---
```

## Tips

- **Use clear placeholder syntax**: `{{ALL_CAPS_WITH_UNDERSCORES}}`
- **Document all placeholders**: Add comments explaining what to replace
- **Test templates**: Use `init-project.sh` to verify they work
- **Keep templates simple**: Remove project-specific complexity before templatizing
- **Add examples**: Show what the final customized version should look like
