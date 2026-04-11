---
description: Check the project for architecture and code quality issues
---

Run the architecture audit script and explain the results in plain language.

Steps:
1. Run `bash .claude/hooks/audit.sh` and capture the output
2. Summarize the results for the user in simple language:
   - What passed (green checkmarks)
   - What has issues (red X marks) — explain each one like you're talking to a 10-year-old
   - What has warnings (yellow marks) — explain what they mean and whether they matter
3. If there are issues, suggest what to fix first and offer to help fix them
4. If everything passes, celebrate — the codebase is clean

Keep the summary short and jargon-free. Use the project's plain-language communication rule.
