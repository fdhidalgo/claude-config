# Secret Management

This repository uses environment variables for sensitive configuration.

## Required Environment Variables

Add these to your shell configuration file (`~/.zshrc`, `~/.bashrc`, etc.):

### Obsidian MCP Server

```bash
export OBSIDIAN_API_KEY="<your-api-key>"
```

**To get your API key**: Check your existing config backup or regenerate from Obsidian.

## Setup on New Machine

After cloning this repo and running `./install.sh`, add the environment variables:

```bash
# Edit your shell config
nano ~/.zshrc  # or ~/.bashrc for bash

# Add the exports above
# Save and reload
source ~/.zshrc
```

Then restart Claude Desktop for it to pick up the environment variables.

## Security Notes

- Environment variables are loaded when Claude Desktop starts
- Never commit actual secrets to this repository
- Keep `claude_desktop_config.json` using `${VAR_NAME}` syntax for secrets
- The actual values should only be in your shell config files (which are NOT in this repo)
