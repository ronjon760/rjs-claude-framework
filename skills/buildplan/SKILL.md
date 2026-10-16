---
name: buildplan
description: Turn docs/VISION.md (and design-system/MASTER.md if present) into phased implementation plans in docs/plans/ — a detailed phase-1.md built from a screen-by-screen user journey, plus lighter outlines for later phases. Use when the user has a vision and wants to plan the build, map user journeys, define the data model and routes, or asks "what do we build first?".
argument-hint: optional phase to plan (e.g., "phase-1", "mvp", "all")
---

# Build plan

Read the project's vision and design system, walk through the user journey with the user, and write build specs in `docs/plans/` that any future conversation can build from. This skill produces plan documents only — no feature code.

Phase requested, if any: $ARGUMENTS

## Before you start

- **`docs/VISION.md` is required.** If it's missing, tell the user: "There's no vision document yet. Run `/rjs:vision` first to define the project's purpose, scope, and tech stack — then come back to `/rjs:buildplan`." and stop.
- **`design-system/MASTER.md` is optional.** If it's missing, note that the plan will cover layout and functionality but not visual details, and that `/rjs:design` can add them later.
- Read `.claude/architecture.json` for the stack and FDD settings (`fdd.features_dir`).
- If `docs/plans/` already has plans, summarize them and ask whether to update one, add a phase, or start fresh.
- From VISION.md, pull the project name, North Star, product arc, MVP, tech stack, phases, and target user.

## 1. Confirm scope

Show what you understood (project, MVP, key technologies, target user, the phase list) and ask which phase to plan. Default to Phase 1.

## 2. Map the user journey

This is the core of the conversation. Ask: "Let's walk through the key screens — what does the user see first, what can they do, and where do they go next?"

For each screen capture its **purpose**, **layout**, **actions**, and **what happens next**. If MASTER.md exists, weave its tokens into each screen — specific colors, fonts and sizes, animation timing, radius, shadows, component sources. That's the main payoff of running the wizards in order. Without a design system, describe layouts functionally.

Most MVPs have 3–7 screens.

## 3. Technical decisions

Based on the stack, work through with the user:

- **External services/APIs** — suggest the common ones for this project type and confirm which apply.
- **Data model** — propose a schema from the screens and actions (Prisma for JS/TS, SQLAlchemy/Django for Python, plain SQL otherwise). Keep it simple enough to evolve; don't design for future phases yet.
- **Background processing** — flag long-running actions (scans, emails, imports, reports) and plan a queue (e.g. Inngest).
- **Authentication** — if accounts are needed, which kind: email/password, social login, or magic links.

Significant choices here (database, auth provider, queue, hosting) are good candidates for `/rjs:adr` — offer to record them.

## 4. Write the plans

Read `${CLAUDE_SKILL_DIR}/plan-structures.md` for both file structures, and `${CLAUDE_SKILL_DIR}/reference.md` for common edge-case patterns (auth, data, network, input, payments) and which sections apply to each project type (web app, API, mobile, static site, CLI).

- **`docs/plans/phase-1.md` — deep detail.** Detailed enough to build from without extra context: component names, API endpoints, data structures, edge cases, and FDD feature folders matching `fdd.features_dir`. Reference existing codebase patterns where they exist. Keep it under ~700 lines; if it's running longer, the MVP is probably too big — suggest splitting it.
- **`docs/plans/phase-N.md` — lighter outlines** for each later phase in VISION.md. These get refined when their time comes.

## 5. Finalize

1. If `CLAUDE.md` exists, add `docs/VISION.md` and `docs/plans/` to its References section if they aren't there.
2. Tell the user, in plain language, which plan files were written and how to start:
   > Start Phase 1 — run `/rjs:feature <name>` to set up your first feature folder, then build from the plan.
