# Plan file structures

## Phase 1 plan — deep detail (`docs/plans/phase-1.md`)

````markdown
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
````

## Later phase plans — lighter outlines (`docs/plans/phase-N.md`)

````markdown
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
````
