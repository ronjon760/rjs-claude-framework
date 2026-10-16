# VISION.md — section guide

What each section of `docs/VISION.md` should contain. The bare template with placeholders is at `${CLAUDE_PLUGIN_ROOT}/templates/docs/VISION.md.template`; this is the annotated version with examples. Keep the finished file under ~150 lines.


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

- `design-system/MASTER.md` — Visual design system (run `/rjs:design` to create)
- `docs/plans/` — Detailed build plans by phase (run `/rjs:buildplan` to create)
- `.claude/architecture.json` — Architecture rules and boundaries
- `.claude/rules/lessons.md` — Corrections and learnings from past sessions
```
