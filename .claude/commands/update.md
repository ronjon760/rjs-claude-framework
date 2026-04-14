---
description: Check for framework updates and install the latest version
argument-hint: (no arguments needed)
---

Check if a newer version of RJ's Claude Framework is available, and update if the user confirms.

Steps:

1. Read `.claude/.framework-version` to get the current installed version
   - If the file doesn't exist, tell the user: "Version tracking was added in v1.5 — your project may be on an older version. Running an update will add version tracking."
2. Check the latest version available from GitHub:
   - Run: `curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh | grep 'FRAMEWORK_VERSION=' | head -1`
   - Extract the version number from the result
3. Compare the versions:
   - If they match: tell the user "You're on the latest version (vX.X.X) — no update needed"
   - If the remote is newer: show the user what version they have vs what's available
4. If an update is available:
   - Fetch the changelog: `curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/CHANGELOG.md`
   - Show the user what changed between their version and the latest (just the relevant entries, not the whole file)
   - Ask: "Ready to update? Your hooks, commands, and settings will be updated. CLAUDE.md, PROJECT_LESSONS.md, and architecture.json won't be touched."
5. If the user confirms:
   - Run: `bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh) --update`
   - Report the result
6. After update, mention:
   - A backup was saved to `.claude/backups/` in case they need to roll back
   - Suggest reviewing the changelog entries for any action items

Important:

- Never update without asking first — always show what will change
- Remind the user that CLAUDE.md and PROJECT_LESSONS.md are never overwritten
- If the update fails, tell the user the backup location and how to restore
- Explain everything in plain language — no jargon
