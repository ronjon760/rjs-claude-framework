---
name: compliance
description: Generate or update a SaaS project's starter legal and compliance docs — Privacy Policy, Terms of Service, Acceptable Use Policy, subprocessor list, and Incident Response plan — into docs/legal/ and docs/compliance/. Use when the user asks for a privacy policy, terms, legal pages, a subprocessor list, an incident response plan, or "compliance docs", or when they're preparing to launch to real customers.
argument-hint: optional description (e.g., "small SaaS for restaurants")
---

# Compliance starter docs

Guide the user through a short questionnaire, then write filled-in versions of the compliance templates. This is sized for **SMB (small-business) SaaS**. Higher tiers (mid-market, enterprise, regulated) are recorded in `architecture.json` for later but not generated.

User's description, if given: $ARGUMENTS

## Before you start

- Read `.claude/architecture.json` for the stack.
- If `compliance.enabled` is true and `docs/legal/` already has filled-in files, read them, show the current settings, and ask what to update. If templates exist but placeholders are unfilled, use the questionnaire to fill them. Otherwise run the full flow.
- Find the source templates: first `docs/compliance/*.template.md` in the project; if missing, use `${CLAUDE_PLUGIN_ROOT}/templates/docs/compliance/`.
- Gather signals: `docs/VISION.md` (product name, customer, data collected), `.env.example` and `package.json` / `pyproject.toml` / `requirements.txt` (third-party services — every `*_API_KEY` and common SDKs), and `README.md` (product description).

## 1. Confirm the project context

Show what you detected — product name, what it does, and the likely subprocessors (e.g. Vercel for hosting, Neon for the database, Anthropic for AI, Stripe for payments) — and ask the user to confirm, add, or remove.

## 2. Questionnaire

Read `${CLAUDE_SKILL_DIR}/questionnaire.md` for the full question list, defaults, and how each answer maps to template placeholders. Four answers are needed to fill the templates (legal entity name, contact email, mailing address, governing state); the rest have sensible defaults.

## 3. Generate the documents

Fill each template and write it to its destination (mapping and substitution rules are in `questionnaire.md`):

- `docs/legal/privacy-policy.md`
- `docs/legal/terms-of-service.md`
- `docs/legal/acceptable-use-policy.md`
- `docs/legal/subprocessors.md`
- `docs/compliance/incident-response.md`

For the subprocessor table, use the vendor metadata in `${CLAUDE_SKILL_DIR}/reference.md`. That file also has stack-specific notes (static sites usually need only a Privacy Policy; mobile apps need app-store privacy labels to match).

If a destination file already has real content, show a diff and ask before replacing it, and keep any custom sections the user added.

## 4. Update `architecture.json`

Add or update the `compliance` block (shape in `questionnaire.md`), with `last_reviewed` set to today.

## 5. Report and next steps

Tell the user, in plain language:

1. **What was generated** — the files written.
2. **What to do this week** — review each doc (placeholders are filled, but the content needs their eyes); get a lawyer to review the Privacy Policy and Terms before publishing (roughly $1–5K for an SMB review); publish them at public URLs like `/privacy`, `/terms`, `/subprocessors`.
3. **What was deferred and why** — DPA, MSA, BAA, SOC 2 prep, HIPAA docs. These are for higher customer tiers; wait until enterprise customers ask.
4. **Habits to build** — update `subprocessors.md` in the same PR that adds a new third-party API; re-run `/rjs:compliance` (or edit the docs) when a feature collects new data; re-review every 6 months (`compliance.last_reviewed` tracks this).

If `docs/compliance/compliance-landscape.md` exists, point the user to it for the bigger picture (e.g. "do I need SOC 2?").

## Principles

- **This is not legal advice.** The docs are starting points; say so.
- **Don't promise security the product doesn't have.** The Privacy Policy makes specific claims (TLS, encryption at rest, MFA). If one isn't true for this project, either implement it or soften the language, and tell the user which.
- **Accuracy matters legally.** An inaccurate Privacy Policy can be an FTC §5 violation, so new vendors and data flows belong in the same change as the code that adds them.
- **Keep the doc set small.** Generate only the SMB set, even for users aiming upmarket — note what's deferred instead.
