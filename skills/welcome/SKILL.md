---
name: welcome
description: Give a friendly, plain-language introduction to this project — what it is, how it's organized, how to run it, what's automated, and which commands to use. Use when someone is new to the project, asks "what is this?", "where do I start?", or "how does this project work?".
---

# Welcome

Introduce the project to someone new, adapting to what you actually find in its files.

## Read first

- `CLAUDE.md` — what the project is and its rules.
- The directory structure — how it's organized.
- `.claude/rules/lessons.md` (or `PROJECT_LESSONS.md` in older projects) — lessons from past work.
- `docs/VISION.md` and `docs/plans/`, if present — the direction and current plan.

## Then cover, briefly

- **What is this project?** One or two sentences, no jargon.
- **How is it organized?** The main folders and what lives in each.
- **How do I run it?** The exact commands to get started.
- **What's automated?** Hooks handle formatting, linting, type checking, and security checks automatically, so they don't have to think about them.
- **What commands are there?** The recommended flow for a new project is `/rjs:vision` → `/rjs:design` → `/rjs:buildplan`. Day to day: `/rjs:feature` to start a feature, `/rjs:test` to build test-first, `/rjs:save` to back up work, `/rjs:share` to open a pull request with a fresh-eyes review, `/rjs:audit` to check project health, `/rjs:adr` to record a big technical decision, and `/rjs:compliance` for legal starter docs. Claude Code's own `/resume` picks up a past conversation and `/rewind` undoes recent changes.
- **Important lessons** from `.claude/rules/lessons.md`, if any.
- **Current state** — offer to run `/rjs:audit` to show project health.

End with: "What would you like to work on?"

Tone: friendly and encouraging, like helping a friend get set up. Explain technical terms in parentheses when they come up, and follow the project's plain-language rule.
