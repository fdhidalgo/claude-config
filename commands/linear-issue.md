---
argument-hint: [issue-id]
description: Read a Linear issue and all its comments
allowed-tools: Linear:get_issue, Linear:list_comments
---

Retrieve and present Linear issue $1 with all comments.

## Tasks

1. Use Linear:get_issue with id: $1 to get the full issue details
2. Use Linear:list_comments with issueId: $1 to get all comments
3. Present the information in this structure:

### Issue Details
- Title, description, and current state
- Priority, assignee, labels
- Due date if set
- Git branch name if exists
- Attachments if any

### Comments (chronological order)
- Show each comment with author and timestamp
- Include any threaded replies

Focus on making the information scannable - this is reference material for further work.