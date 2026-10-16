---
name: audit
description: Run the project's architecture and code-quality audit (file sizes, layer boundaries, feature-folder rules, QUICK_REF coverage) and explain the results in plain language. Use when the user asks to check project health, run an audit, or find structural problems.
---

# Audit

Run the architecture audit and explain what it found in plain language.

1. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit.sh"` from the project root and capture the output.
2. Summarize for the user, simply and without jargon:
   - **What passed** (green checks).
   - **What has issues** (red marks) — explain each one as you would to someone who has never coded, and why it matters.
   - **Warnings** (yellow marks) — what they mean and whether they're worth acting on now.
   - If feature folders (FDD) are enabled, cover those findings too: missing `QUICK_REF.md` files, features importing from each other, feature files big enough to split, screens holding too much business logic.
3. If there are issues, suggest what to fix first and offer to help. If everything passes, say so and celebrate briefly — the codebase is clean.

## Going further

The script checks structure. For a deeper look, suggest Claude Code's built-in commands:

- `/code-review` — a judgment-based review of the code itself (bugs, logic, maintainability).
- `/security-review` — a dedicated security pass, worth running before launch or after changes to login, payments, or user data.

Follow the plain-language rule in `CLAUDE.md`.
