---
name: adr
description: Record a significant technical decision as an Architecture Decision Record in docs/decisions/NNNN-title.md — context, decision, alternatives considered, consequences. Use right after the user or Claude settles a choice that would be costly to reverse: picking a database, auth provider, hosting platform, payment provider, major library or framework, or an architecture pattern. Not for small, easily reversed choices.
argument-hint: optional decision title (e.g., "use Supabase for auth")
---

# Record a decision

Write a short Architecture Decision Record (ADR) — a dated note explaining what was decided and why — so that months from now nobody has to guess why the project uses Postgres instead of MongoDB, or Clerk instead of rolling its own login.

Decision, if given: $ARGUMENTS

## When it's worth recording

Record choices that shape the project and would be expensive to undo: database, auth provider, hosting, payments, a major library or framework, an architecture pattern (e.g. "all background work goes through a queue"). Skip small, easily reversed choices — a cluttered decisions folder gets ignored.

If Claude is about to make such a choice during other work, offer to record it once the user agrees, rather than writing one unprompted.

## Steps

1. **Gather the substance.** Use what's already in the conversation; ask only for what's missing — usually the alternatives that were considered and the main reason for the choice. Check `docs/VISION.md` and existing ADRs for related context.
2. **Number it.** Look in `docs/decisions/` (create it if needed). Take the highest existing four-digit prefix and add one; start at `0001` if empty.
3. **Name it** `docs/decisions/NNNN-<kebab-case-title>.md`, e.g. `0003-use-supabase-for-auth.md`.
4. **If it replaces an earlier decision**, set the old ADR's status to `Superseded by NNNN` and link back to it from the new one. Leave the old reasoning intact — the history is the point.
5. **Write it** in plain language, under a page:

```markdown
# NNNN. [Decision title]

- **Date:** YYYY-MM-DD
- **Status:** Accepted   <!-- Proposed | Accepted | Superseded by NNNN | Deprecated -->

## Context
[What problem or need prompted this decision, and any constraints — budget, timeline, team skills, compliance.]

## Decision
[What we chose, in one or two sentences.]

## Alternatives considered
- **[Option]** — [why it wasn't chosen]
- **[Option]** — [why it wasn't chosen]

## Consequences
[What this makes easier, what it makes harder or costs, and what would make us revisit it.]
```

6. **Confirm** in one line: what was recorded and where, e.g. "Recorded decision 0003 — using Supabase for login — in `docs/decisions/0003-use-supabase-for-auth.md`."

Be honest in Consequences: a decision with no downsides listed usually means they weren't thought through. Use status `Proposed` if the user hasn't fully committed yet.
