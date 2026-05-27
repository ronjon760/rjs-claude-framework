---
description: Generate a detailed build plan from your vision and design docs — creates docs/plans/
argument-hint: optional phase to plan (e.g., "phase-1", "mvp", "all")
---

Generate phased implementation plans by reading the project's vision and design system, walking through user journeys with the user, and producing detailed build specs that Claude can execute from in any session.

## Before You Start

1. **Read `docs/VISION.md`** (REQUIRED). If it doesn't exist:
   > "No vision document found. Run `/vision` first to define your project's purpose, scope, and tech stack — then come back to `/buildplan`."
   Stop here.

2. **Read `design-system/MASTER.md`** (optional but recommended). If it doesn't exist, note:
   > "No design system found. The build plan will include layout and functionality specs but not visual details. Run `/design` after this to add colors, typography, and motion specs."

3. **Read `.claude/architecture.json`** for stack info and FDD configuration.

4. **Check if `docs/plans/` already exists:**
   - If YES and contains plan files: read them, show a summary, and ask what the user wants to do — update an existing plan, add a new phase, or start fresh.
   - If NO: proceed with the full wizard.

5. **Extract from VISION.md:**
   - Project name and description
   - North Star statement
   - Product Arc
   - MVP definition (Phase 1 scope)
   - Tech stack
   - Phase descriptions (Phase 2, 3, etc.)
   - Target audience

## Phase 1: Scope Confirmation

Present what was extracted from VISION.md:

```
Here's what I understand from your vision:

**Project:** [name]
**MVP (Phase 1):** [extracted MVP description]
**Tech Stack:** [key technologies]
**Target User:** [persona]

**Phases:**
1. [Phase 1 name] — [description]
2. [Phase 2 name] — [description]
3. [Phase 3 name] — [description]

Are we planning Phase 1 (MVP)? Or would you like to plan a different phase?
```

If the user says a different phase, adjust accordingly. Default to Phase 1.

## Phase 2: User Journey Mapping

This is the core interactive section. Walk through each key screen/page of the phase being planned.

Ask the user:

> "Let's map out the user journey for Phase 1. Walk me through the key screens — what does the user see first, what can they do, and where do they go next?"

For each screen the user describes, capture:
- **Purpose** — What this screen accomplishes
- **Layout** — What the user sees (sections, inputs, cards, etc.)
- **Actions** — What the user can do (click, submit, navigate)
- **What happens next** — Where the user goes after this screen

If `design-system/MASTER.md` exists, auto-apply design tokens to each screen:
- Reference specific colors (e.g., "emerald-600 primary CTA")
- Reference fonts (e.g., "Outfit 700, 48-64px for the heading")
- Reference animation approach (e.g., "fade in + slide up, 400ms, scroll-triggered")
- Reference component sources (e.g., "21st.dev Card variant")
- Reference border radius, shadows, spacing from the design system

If no design system exists, describe layouts functionally without visual specifics.

Continue until all screens are mapped. Most MVPs have 3-7 screens.

## Phase 3: Technical Decisions

Based on the tech stack from VISION.md, ask about:

**External APIs/Services:**
> "What external services or APIs does this need? Here are common ones for [project type]:"

Present relevant options from the reference table below. The user confirms which apply.

**Data Model:**
Based on the screens and actions described, propose a data model:
> "Based on the user journeys, here's the data I think you need to store:"

Present a proposed schema (Prisma for JS/TS, SQLAlchemy-style for Python, or plain SQL for others). The user confirms or adjusts.

**Background Processing:**
If any actions involve long-running tasks (scanning, email sending, report generation, imports):
> "These actions look like they need background processing: [list]. I'll include an Inngest/queue setup in the plan."

**Authentication:**
If the app requires user accounts:
> "Does this need user authentication? If so, what kind — email/password, social login (Google/GitHub), or magic links?"

## Phase 4: Generate Phase 1 Plan (DEEP Detail)

Create `docs/plans/` directory if needed. Write `docs/plans/phase-1.md` following this structure:

```markdown
# [Phase Name] — Build Plan

## Context

[2-3 sentences: what this phase delivers, why it's first, what success looks like.
Reference the North Star from VISION.md.]

---

## User Journey

### Screen 1: [Name] (`/[route]`)

**Purpose:** [What this screen accomplishes]

**Layout:**
- [Describe the layout section by section]
- [Reference design tokens from MASTER.md if available]
- [Include responsive notes: what changes on mobile]

**Motion:**
- [Animation specs for this screen]
- [Reference Motion v12 patterns if React/Next.js]
- [Or CSS transitions if static/Python]

**Components:**
- [List components with sources: shadcn/ui, 21st.dev, custom]

**Technical:**
- [API calls, data flow, state management]
- [External service integrations]
- [Error states and edge cases for this screen]

---

### Screen 2: [Name] (`/[route]`)
[Same structure as above]

---

[Continue for all screens...]

---

## Technical Pipeline

[If the app has a multi-step backend process (like a scanning pipeline,
data import, report generation), detail each step:]

### Step 1: [Name]
```
Input: [what triggers this step]
API/Tool: [what external service or internal logic]
Output: [what data is produced]
Cost: [if external API, estimate per-call cost]
```

### Step 2: [Name]
[Same structure]

---

## Data Model

[Generate the appropriate schema for the tech stack:]

```prisma
[For JS/TS projects: Prisma schema]
```

```python
[For Python projects: SQLAlchemy models or Django models]
```

```sql
[For other projects: plain SQL CREATE TABLE statements]
```

---

## FDD Features

[Map every planned feature to its folder structure:]

### `[features_dir]/[feature-name]/`
**Purpose:** [What this feature handles]

| File | Contents |
|------|----------|
| `components/[Name].tsx` | [Description] |
| `hooks/use[Name].ts` | [Description] |
| `types.ts` | [Key types] |
| `index.ts` | Barrel export |

[Repeat for each feature]

---

## API Routes

| Method | Route | Purpose |
|--------|-------|---------|
| GET | `/api/[resource]` | [What it returns] |
| POST | `/api/[resource]` | [What it creates] |
[Continue for all routes]

---

## Edge Cases

[Include relevant edge cases from the reference table below,
plus any specific to this project:]

| Scenario | Handling |
|----------|----------|
| [Edge case] | [How the app handles it] |
[Continue]

---

## Pages / Routes

| Route | File | Purpose |
|-------|------|---------|
| `/` | `app/page.tsx` | [Description] |
| `/[route]` | `app/[route]/page.tsx` | [Description] |
[Continue for all routes]
```

## Phase 5: Generate Later Phase Plans (LIGHTER Outlines)

For each subsequent phase from VISION.md, write `docs/plans/phase-N.md` with this lighter structure:

```markdown
# [Phase Name] — Build Plan

## Context

[2-3 sentences: what this phase adds, what triggers building it,
how it relates to Phase 1.]

---

## Core Concept

[Paragraph describing the key idea and user value of this phase.]

---

## Key Screens / Sections

### [Screen/Section Name]
- [What the user sees and does — high level, not screen-level motion specs]
- [Key functionality, not implementation detail]

[Repeat for each major screen/section]

---

## Features (FDD)

| Feature | Purpose |
|---------|---------|
| `[feature-name]` | [What it handles] |
[Continue]

---

## Data Model Additions

[New models or fields that this phase adds to the schema:]

```prisma
model [NewModel] {
  [fields]
}
```

---

## Technical Considerations

- [Architecture decisions specific to this phase]
- [New integrations or services needed]
- [Scaling considerations]

---

## Pages / Routes

| Route | Purpose |
|-------|---------|
| `/[route]` | [Description] |
[Continue]
```

## Phase 6: Finalize

After generating all plan files:

1. **Update CLAUDE.md** — Add references to `docs/VISION.md` and `docs/plans/` in the References section (if not already present).

2. **Tell the user:**
   > Build plan ready:
   > - `docs/plans/phase-1.md` — Detailed Phase 1 implementation spec
   > - `docs/plans/phase-2.md` — Phase 2 outline
   > - `docs/plans/phase-3.md` — Phase 3 outline
   >
   > Start Phase 1 — run `/feature <name>` to scaffold your first feature, then build from the plan.

---

## Reference: Common Edge Case Patterns

Auto-include relevant patterns based on project type:

### Authentication
| Scenario | Handling |
|----------|----------|
| Session expires during action | Show re-login prompt, preserve draft state |
| OAuth provider down | Fallback to email/password, show clear error |
| Rate-limited login attempts | Progressive delay, lockout after 5 failures |
| Concurrent sessions | Allow multiple, or invalidate oldest |

### Data & State
| Scenario | Handling |
|----------|----------|
| Empty state (no data yet) | Show helpful zero-state with CTA to get started |
| Pagination boundary | Load more / infinite scroll with loading skeleton |
| Stale data after background update | Optimistic UI or polling with refresh indicator |
| Concurrent edits | Last-write-wins or conflict resolution UI |
| Partial data (some API calls failed) | Show available data, indicate what's missing |

### Network & Performance
| Scenario | Handling |
|----------|----------|
| Slow connection (> 3s load) | Loading skeleton, progress indicator |
| Request timeout | Retry with backoff, show timeout message |
| Offline state | Show cached data if available, indicate offline |
| Large payload | Paginate, stream, or chunk the response |

### Input & Validation
| Scenario | Handling |
|----------|----------|
| XSS attempt in user input | Sanitize all inputs, escape output |
| File upload too large | Client-side size check before upload, clear limit message |
| Malformed data from external API | Validate with Zod/schema, fallback to defaults |
| Required field missing | Inline validation, don't submit until valid |

### Payments (if applicable)
| Scenario | Handling |
|----------|----------|
| Card declined | Clear error message, allow retry with different card |
| Webhook delivery failure | Idempotent handler, retry queue |
| Refund requested | Process via Stripe API, update subscription state |
| Currency mismatch | Display in user's locale, convert at charge time |

---

## Reference: Plan Sections by Project Type

Conditionally include or exclude sections based on project type:

### Web App (Next.js, React, etc.)
Include: User Journey (screen-by-screen), Data Model (Prisma), API Routes, FDD Features, Edge Cases, Pages/Routes, Motion specs (if design system exists)

### API-Only Service
Include: Endpoint Specifications (method, path, request/response schema, auth), Data Model, Error Response Format, Rate Limiting Strategy, Authentication Flow
Skip: User Journey screens, Motion specs, Component sources

### Mobile App (React Native)
Include: Screen Flows with Navigation Structure, Data Model, API Integration, Offline Handling, Platform-Specific Considerations (iOS vs Android), Push Notifications
Adapt: Use "Screens" instead of "Pages", navigation stack instead of routes

### Static Site
Include: Page Inventory, Content Structure, SEO Requirements, Deployment Config
Skip: Data Model, API Routes, Background Processing, Auth
Lighter: Edge cases focus on content display and SEO

### CLI Tool
Include: Command Structure, Input/Output Specifications, Configuration, Error Messages, Testing Strategy
Skip: User Journey screens, Motion, Components, FDD Features

---

## Important Notes

- Generate ONLY the build plan documents — do not start building features or writing code
- Phase 1 plans should be detailed enough that Claude can build from them without additional context — include specific component names, API endpoints, and data structures
- Later phase plans should be lighter — they'll be refined when the time comes
- If design-system/MASTER.md exists, weave its tokens into every screen spec (colors, fonts, radius, animation timing) — this is the primary value of the chained wizard flow
- Keep Phase 1 plans under 700 lines. If it's getting longer, the MVP scope is probably too big — suggest splitting
- Reference existing patterns from the codebase when applicable
- FDD feature mapping should match the architecture.json features_dir setting
- When proposing a data model, prefer simple schemas that can evolve — don't over-engineer for future phases
