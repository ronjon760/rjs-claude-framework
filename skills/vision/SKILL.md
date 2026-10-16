---
name: vision
description: Define a project's vision, target user, MVP scope, tech stack, and phased product arc through a first-principles interview, and write it to docs/VISION.md. Use when starting a new project, when the user describes an app idea and asks what to build or which stack to use, or when they want to revisit the project's direction. First step of the /rjs:vision → /rjs:design → /rjs:buildplan flow.
argument-hint: optional project description (e.g., "business analytics SaaS", "restaurant ordering app")
---

# Project vision

Guide the user through a short first-principles interview and write `docs/VISION.md` — the strategic document every future conversation can reference. This skill produces the vision document only; building features comes later.

User's description, if given: $ARGUMENTS

## Before you start

- Read `.claude/architecture.json` for the detected stack, if any.
- If `docs/VISION.md` exists, read it, summarize the current North Star, MVP, tech stack, and phases, and ask what the user wants to change. Then refine in place rather than re-running the whole interview.
- If the project already has code (`package.json`, `pyproject.toml`, etc.), frame the vision around what's next and recommend additions to the existing stack rather than replacements.

## 1. Understand the idea

If no description was given, ask: "Describe your project idea in a few sentences — what does it do, who is it for, and what problem does it solve?"

From the answer, infer the project type (web app, mobile app, API, static site, dashboard, CLI…), the audience, the core problem, and what already exists that's similar.

## 2. First-principles questions

Work through these five, skipping any the user has already answered clearly. Articulating them is the point, so ask even when the answer seems obvious — but adapt the wording to how the user talks.

1. **Who specifically is this for?** A persona, not demographics — e.g. "a local restaurant owner who's too busy to manage their website but knows they're losing customers because of it."
2. **What's the one thing it must do well?** If they list three, ask: "If you could only ship one, which proves the idea works?"
3. **What exists today, and why isn't it good enough?** This defines the differentiation and avoids rebuilding something that already works.
4. **What's the simplest version that proves the idea?** Push for concrete: "What are the 2–3 screens or steps a user goes through?" This becomes Phase 1.
5. **What does the full product look like in 6–12 months?** Aim for 2–3 phases beyond the MVP.

Push for specificity. "A local business tool" is too vague; "scans a local business's Google profile, website, and socials and scores their online health out of 100" is something you can plan from.

## 3. Recommend a tech stack

Read `${CLAUDE_SKILL_DIR}/reference.md` for the project-type → stack table, the complexity heuristic (auth, payments, background jobs, real-time), and phase-arc templates. Prefer proven, well-documented tools over cutting-edge ones.

Present it as a table (Layer | Technology | Why) and invite the user to accept, swap specific choices, or bring their own stack.

If a stack choice is significant (database, auth provider, hosting), offer to record it with `/rjs:adr` once confirmed.

## 4. Write `docs/VISION.md`

Use `${CLAUDE_PLUGIN_ROOT}/templates/docs/VISION.md.template` as the structure. `${CLAUDE_SKILL_DIR}/section-guide.md` explains what belongs in each section, with examples. Keep the file under ~150 lines — scannable, concrete enough to plan from, flexible enough to evolve. Three phases is the sweet spot.

In the References section, point to `/rjs:design` and `/rjs:buildplan` as the commands that create `design-system/MASTER.md` and `docs/plans/`.

## 5. Finalize

1. In `.claude/architecture.json`, add or update:
   ```json
   "vision": { "enabled": true, "path": "docs/VISION.md" }
   ```
2. If `CLAUDE.md` exists and doesn't already reference `docs/VISION.md`, add it to the References section.
3. Tell the user, in plain language:
   > Your vision is saved at `docs/VISION.md` — future conversations will use it for context.
   >
   > Ready to decide how it looks? Run `/rjs:design` to create your design system.
