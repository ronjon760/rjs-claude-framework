---
description: Define your project's vision, scope, and tech stack — generates docs/VISION.md
argument-hint: optional project description (e.g., "business analytics SaaS", "restaurant ordering app")
---

Define the project's vision, scope, target audience, tech stack, and phased product arc by guiding the user through a first-principles questionnaire. Generates `docs/VISION.md` as the persistent strategic document that all future sessions reference.

## Before You Start

1. Read `.claude/architecture.json` to determine the project stack (if already detected)
2. Check if `docs/VISION.md` already exists:
   - If YES: read it, show the current vision summary (North Star, MVP, Tech Stack, Phases), and ask what the user wants to change. Skip to the refinement phase.
   - If NO: proceed with the full wizard below.

## Phase 1: Natural Language Understanding

If the user provided a description argument (e.g., `/vision restaurant ordering app for local restaurants`), use it. Otherwise ask:

> "Describe your project idea in a few sentences — what does it do, who is it for, and what problem does it solve?"

From the description, infer:
- **Project type** — web app, mobile app, API service, static site, dashboard, CLI tool, etc.
- **Target audience** — who will use this and in what context
- **Core problem** — what pain point it addresses
- **Competitive landscape** — what exists today that's similar

## Phase 2: First Principles Questioning

Ask these five questions to sharpen the vision. Use AskUserQuestion or conversational prompts — adapt to the user's communication style. Skip any question the user already answered in their description.

1. **"Who specifically is this for?"**
   Not demographics — a persona. Example: "A local restaurant owner who's too busy to manage their own website but knows they're losing customers because of it."

2. **"What's the ONE thing this product must do well?"**
   Forces prioritization. If they list three things, push back: "If you could only ship one of those, which one proves the idea works?"

3. **"What exists today that tries to solve this? Why isn't it good enough?"**
   Competitive awareness. Helps define differentiation and ensures we're not rebuilding something that already works.

4. **"What's the simplest version that proves the idea works?"**
   MVP scoping. Push for concrete: "Can you describe the 2-3 screens or steps a user would go through?" This becomes the Phase 1 definition.

5. **"What does the full product look like in 6-12 months?"**
   Product arc. Ask for 2-3 phases beyond the MVP. Example: "Phase 1 is the grader, Phase 2 rebuilds their website, Phase 3 monitors it ongoing."

## Phase 3: Tech Stack Recommendation

Based on the project type inferred from the answers, recommend a tech stack using the reference tables below. Present it as a summary for confirmation:

```
Based on your project, here's the tech stack I'd recommend:

| Layer | Technology | Why |
|-------|-----------|-----|
| Framework | [recommendation] | [one-line reason] |
| Database | [recommendation] | [one-line reason] |
| Styling | [recommendation] | [one-line reason] |
| Hosting | [recommendation] | [one-line reason] |
| [other layers as needed] |

Does this work for you? You can:
- Say "yes" to proceed
- Override specific choices (e.g., "use Supabase instead of Neon")
- Say "I already have a stack in mind" and list it
```

If the project already has a `package.json`, `pyproject.toml`, or other stack indicators, acknowledge what's already in place and recommend additions rather than replacements.

## Phase 4: Generate docs/VISION.md

Create the `docs/` directory if needed and write `docs/VISION.md` following this structure:

```markdown
# [Project Name]

> [One-line description that captures the essence]

## North Star

[A guiding principle statement — the "why" behind every decision. Keep it to one sentence.
Example: "Every local business should have a world-class digital presence — we make it effortless."]

## Product Arc

[The user journey in a few words, connected by arrows.
Example: "Scan → Fix → Monitor → Grow"]

---

## Problem

[2-3 sentences describing the pain point this solves. Include:
- Who has this problem
- What they currently do about it (or don't)
- Why existing solutions fall short]

## Target Audience

[Specific persona description. Not "small business owners" — more like:
"Local business owners (restaurants, salons, dentists) who know their online presence
is costing them customers but don't have the time, skills, or budget to fix it themselves."]

## MVP (Phase 1)

[Concrete scope of the minimum viable product. What screens/pages exist?
What can the user do? What's explicitly NOT included yet?]

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| [Framework] | [choice] | [what it handles] |
| [Language] | [choice] | [why this language] |
| [Styling] | [choice] | [approach] |
| [Database] | [choice] | [what data is stored] |
| [ORM] | [choice] | [if applicable] |
| [Auth] | [choice] | [if applicable] |
| [Hosting] | [choice] | [deployment target] |
| [Other] | [choice] | [purpose] |

---

## Phases

### Phase 1: [Name] — [one-line description]
[2-3 sentences on what this phase delivers and why it's first.
This is the MVP defined above.]

### Phase 2: [Name] — [one-line description]
[2-3 sentences on what this phase adds and what triggers it.
Example: "Once users can see their score, they'll want to fix it."]

### Phase 3: [Name] — [one-line description]
[2-3 sentences on the retention/growth layer.
Example: "Keep users coming back with ongoing monitoring and alerts."]

[Add more phases if the user described them, but 3 is the sweet spot.]

---

## Success Metrics

[How do you know the product is working? 3-5 concrete, measurable indicators.
Examples:
- "X businesses scanned in the first month"
- "Y% of users who see their score click 'fix it for me'"
- "Average scan-to-report time under 45 seconds"]

---

## References

- `design-system/MASTER.md` — Visual design system (run `/design` to create)
- `docs/plans/` — Detailed build plans by phase (run `/buildplan` to create)
- `.claude/architecture.json` — Architecture rules and boundaries
- `PROJECT_LESSONS.md` — Corrections and learnings from past sessions
```

## Phase 5: Finalize

After generating VISION.md:

1. Update `.claude/architecture.json` — add or update the `vision` section:
   ```json
   "vision": {
     "enabled": true,
     "path": "docs/VISION.md"
   }
   ```

2. Update `CLAUDE.md` if it exists — add a reference to `docs/VISION.md` in the References section (if not already present).

3. Tell the user:
   > Vision documented at `docs/VISION.md`. Every session will reference this for project context.
   >
   > Ready to define how it looks? Run `/design` to create your design system.

---

## Reference Tables

### Project Type to Tech Stack Recommendations

Use these as starting points — adapt based on the user's specific needs, existing code, and stated preferences.

| Project Type | Framework | Database | Key Libraries | Hosting |
|---|---|---|---|---|
| Full-stack web app (SaaS) | Next.js 15 + TypeScript + Tailwind | Neon Postgres or Supabase | Prisma, Inngest, Resend, shadcn/ui | Vercel |
| Marketing / landing page | Next.js (static export) or Astro | None or lightweight CMS | Motion v12, shadcn/ui | Vercel / Netlify |
| API-first service | Node.js (Express/Fastify) or Python (FastAPI) | Postgres or MongoDB | Zod, Drizzle or SQLAlchemy | Railway / Fly.io |
| Mobile app | React Native (Expo) + TypeScript | Supabase | React Navigation, Reanimated | EAS Build |
| Static site / portfolio | HTML/CSS/JS or Astro | None | Vanilla JS or Alpine.js | Netlify / GitHub Pages |
| Dashboard / admin panel | Next.js + TypeScript + Tailwind | Postgres | Prisma, Recharts/Tremor, shadcn/ui | Vercel |
| E-commerce | Next.js + TypeScript | Postgres + Stripe | Prisma, Stripe SDK, shadcn/ui | Vercel |
| AI/ML tool | Python (FastAPI) + React frontend | Postgres | Anthropic SDK, LangChain | Railway + Vercel |
| CLI tool | Node.js (TypeScript) or Python | SQLite (if needed) | Commander.js or Click, Chalk or Rich | npm / PyPI |
| Real-time app (chat, collab) | Next.js + TypeScript | Supabase (realtime) or Redis | Supabase Realtime or Socket.io | Vercel + Supabase |

### Complexity Heuristic

Use this to calibrate the MVP scope and tech recommendations:

| Signal | Recommendation |
|---|---|
| Single page, no login | Static HTML or single Next.js page — keep it minimal |
| Multi-page, no auth | Next.js static pages or Astro — no database needed |
| Auth required | Add Supabase Auth, NextAuth, or Clerk |
| Background processing needed | Add Inngest (MVP) or BullMQ + Redis (scale) |
| Payments | Add Stripe — never build custom payment handling |
| External APIs | Factor in API costs; add rate limiting and caching |
| Real-time updates needed | Supabase Realtime, SSE, or WebSockets |
| Mobile + web | React Native (Expo) for mobile, Next.js for web, shared API |

### Phase Arc Templates

Typical phase structures by project type — use as starting points:

**SaaS / Tool:**
- Phase 1: Core tool (the thing users come for)
- Phase 2: Account system + saved data
- Phase 3: Team features + billing

**Marketplace / Platform:**
- Phase 1: One side of the marketplace (supply or demand)
- Phase 2: The other side + matching
- Phase 3: Payments + trust/safety

**Content / Media:**
- Phase 1: Content delivery + discovery
- Phase 2: User accounts + personalization
- Phase 3: Creator tools + monetization

**Internal Tool / Dashboard:**
- Phase 1: Data display + core workflows
- Phase 2: Automation + alerts
- Phase 3: Reporting + integrations

---

## Important Notes

- Generate ONLY the vision document — do not start building features or writing application code
- The vision should be concrete enough to plan from but flexible enough to evolve
- Push for specificity: "a local business tool" is too vague; "a tool that scans any local business's Google profile, website, and social media and scores their online health out of 100" is actionable
- If the user has an existing codebase, acknowledge what's already built and frame the vision around what's next
- When recommending tech stacks, prefer proven, well-documented tools over cutting-edge ones
- Keep VISION.md under 150 lines — it should be scannable, not a novel
- All five first-principles questions should be asked even if some answers seem obvious — the exercise of articulating them creates clarity
