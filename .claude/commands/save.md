---
description: Save your work — commits all changes and pushes to GitHub
argument-hint: optional message describing what you did
---

Save the user's work by creating a git commit and pushing it.

Steps:
1. Run `git status` to see what changed
2. If there are no changes, tell the user "Nothing new to save — you're up to date"
3. If there are changes:
   a. Stage all changed files (but NOT .env, .env.local, or other secret files)
   b. Look at what changed to understand the work that was done
   c. Write a commit message in plain language that explains:
      - What changed (in simple terms)
      - Why it matters
   d. If the user provided a message with the command, use that as the basis
   e. Commit the changes
   f. Push to the current branch
4. Confirm to the user: "Saved! Your work is backed up on [branch name]"

Important:
- Never commit .env, .env.local, or files containing secrets
- Write commit messages following the project's plain-language rule from PROJECT_LESSONS.md
- End the commit message with: Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
