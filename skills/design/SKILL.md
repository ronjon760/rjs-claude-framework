---
name: design
description: Create or update a project's design SYSTEM — style, design conviction, color palette, fonts, spacing, motion, and component sources — and write it to design-system/MASTER.md as the single source of truth for visual decisions. Use when the user wants to decide how their app looks, pick colors or fonts, define a brand or visual style, or update MASTER.md. Not for drawing individual screens or mockups.
argument-hint: optional project description (e.g., "beauty spa website", "SaaS dashboard")
---

# Design system

Guide the user from a plain-language description to a confirmed design direction, then write `design-system/MASTER.md`. This skill produces the design system only — not components or app code.

User's description, if given: $ARGUMENTS

> Claude Code also has a built-in `/design` command that drafts UI mockups on a Claude Design canvas. That's a different job: this skill (`/rjs:design`) decides the *system*; the built-in is a good next step for visual mockups once the system exists.

## Before you start

- Read `.claude/architecture.json` for the stack (nextjs, node, python, static-html, react-native…).
- If `design-system/MASTER.md` exists, read it, show the current style, palette, and fonts, and ask what to change. Refine in place and keep any custom sections the user added.
- If `docs/VISION.md` exists, read it — the audience and product type inform the direction.

## 1. Understand the vibe

If no description was given, ask: "Describe your project in a sentence or two — what is it, who is it for, and what vibe are you going for?"

Infer four things: **industry**, **product type** (landing page, dashboard, web app, mobile app…), **aesthetic vibe** (warm premium, sleek minimal, playful bold, dark luxe…), and **target audience**.

## 2. Propose one committed direction

Read `${CLAUDE_SKILL_DIR}/reference-tables.md` for the industry → style mapping, curated palettes, font pairings, animation approaches, and radius by style. Use them as a starting point and combine with judgment.

Commit to a conviction rather than a safe default. The goal is a distinctive, production-grade direction, not generic AI output: one bold creative idea, a dominant tone with one sharp accent, a characterful heading font, and one or two unexpected compositional moments. Steer away from the generic-AI traps — Inter/Roboto/Arial as the identity font, purple-on-white gradients, timid evenly-spread palettes, predictable layouts.

Present it like this, then invite "yes", specific overrides, or "show me alternatives":

```
**Style:** [style name]
**Design Conviction:** [the one bold idea everything serves]
**Palette direction:** [dominant tone + one sharp accent, with hex values]
**Fonts:** [distinctive heading font] (headings) + [refined body font] (body)
**Animation approach:** [brief description, using custom easing curves]
**Component source:** shadcn/ui primitives + 21st.dev polished variants
```

## 3. Refine

If the user wants changes, offer 3–4 targeted options for just that aspect (e.g. three palettes with background/accent/text hex values). Most projects settle in 1–2 rounds.

## 4. Write `design-system/MASTER.md`

Read `${CLAUDE_SKILL_DIR}/master-structure.md` for the full annotated structure (also available as a placeholder template at `${CLAUDE_PLUGIN_ROOT}/templates/design-system/MASTER.md.template`). Adapt it to the stack using `${CLAUDE_SKILL_DIR}/stack-adaptations.md` — Tailwind config for React/Next.js, CSS custom properties for Python and static HTML, StyleSheet constants for React Native.

Quality bar for the file:
- Complete and self-contained — a future conversation can make consistent UI decisions from it alone.
- Scannable — tables and code blocks over prose.
- All text colors pass WCAG AA contrast (4.5:1); check the hex values you chose.
- Fonts come from Google Fonts for easy integration.

## 5. Finalize

1. Set `design_system.enabled` to `true` in `.claude/architecture.json`.
2. Tell the user, in plain language:
   > Your design system is saved at `design-system/MASTER.md` — future conversations will follow it for consistent UI. Run `/rjs:design` again anytime to update it.
3. If `docs/VISION.md` exists but `docs/plans/` is missing or empty, suggest `/rjs:buildplan` next. Mention the built-in `/design` if they'd like to see visual mockups of key screens.

## Design lanes

Three tools share the design work; keeping them in their lanes stops them fighting:

- **Decide — `/rjs:design` (this skill).** Owns `design-system/MASTER.md` and bakes the Design Conviction into it.
- **Execute — `frontend-design`.** Fires on UI builds and pushes for distinctive execution *within* the conviction; it doesn't override the locked palette or fonts. It's Anthropic's official plugin and the recommended install: `/plugin install frontend-design@claude-plugins-official`.
- **Reference — `ui-ux-pro-max` (optional skill).** A deeper catalog of palettes, fonts, and styles, pulled on demand when the tables here aren't enough. It doesn't generate MASTER.md.

The full write-up is in `${CLAUDE_PLUGIN_ROOT}/templates/docs/design-lanes.md`.
