---
description: Generate or update the project's compliance starter docs — Privacy Policy, ToS, AUP, subprocessor list, IR plan
argument-hint: optional description (e.g., "small SaaS for restaurants")
---

Generate or update the project's compliance documents — Privacy Policy, Terms of Service, Acceptable Use Policy, subprocessor list, and Incident Response plan — by guiding the user through a short questionnaire, then writing filled-in versions of the templates into `docs/legal/` and `docs/compliance/`.

This is sized for **SMB (small-business) SaaS** — the framework's default target. Higher tiers (mid-market, enterprise, regulated) are recorded in `architecture.json` for future use but not generated in v1.

## Before You Start

1. Read `.claude/architecture.json` to determine the project stack (nextjs, node, python, static-html, etc.)
2. Check if compliance has already been set up:
   - If `architecture.json` has `compliance.enabled: true` AND `docs/legal/` exists with filled-in files: read them, show the current settings, ask what the user wants to update. Skip to the refinement phase.
   - If templates exist but placeholders are unfilled: walk through the questionnaire to fill them.
   - If nothing exists: proceed with the full wizard below.

3. Look for source templates in this order:
   - `docs/compliance/*.template.md` and `docs/compliance/*.md` in the project (placed there by `setup.sh`)
   - If missing, fetch from the framework: `templates/docs/compliance/` in the framework repo

4. Look for signals about the project:
   - Read `docs/VISION.md` if it exists — pull product name, target customer, what data is collected
   - Read `.env.example` and `package.json` / `pyproject.toml` — detect third-party API integrations to pre-populate the subprocessor list
   - Read `README.md` — pull the product description

## Phase 1: Detect and Confirm Project Context

From the available signals, infer:
- **Product name** (from package.json `name`, VISION.md, or README.md)
- **What the product does** (one sentence from VISION.md or README.md)
- **Third-party services in use** (every `*_API_KEY` in .env.example; common SDKs in package.json)

Present what you found and ask the user to confirm or correct. Example:

```
Here's what I detected about your project:

**Product name:** {detected}
**What it does:** {detected}
**Detected subprocessors:**
  - Vercel (hosting)
  - Neon (database)
  - Anthropic (AI)
  - Stripe (payments)

Is this right? Anything to add, remove, or change?
```

## Phase 2: Compliance Questionnaire

Walk through these questions one at a time (or as a batched block, depending on what feels natural). Use the AskUserQuestion tool when helpful, or just plain conversation.

### Required (must answer to fill the templates)

1. **Legal entity name** — the formal name on your incorporation paperwork (e.g. "Acme Co, Inc.")
2. **Contact email for privacy/legal matters** — typically `privacy@yourcompany.com` or `support@`
3. **Mailing address** — required by CCPA so users can reach you offline
4. **Governing state for the ToS** — usually Delaware (if DE-incorporated) or your home state. Ask which.

### Strongly recommended (but skippable with defaults)

5. **Target customer tier** — confirm SMB (default), or note if planning to sell upmarket. Recorded in architecture.json; affects future work but not the docs generated today.
6. **Geography of customers** — US-only (default), or expanding to EU/global? US-only is assumed; if EU, flag that the docs would need GDPR additions (not generated in v1).
7. **What data does the product collect?** Walk through:
   - Account data (almost always yes)
   - Content uploaded by users (often yes)
   - Payment info (yes if you charge; almost always via Stripe — keeps you out of PCI scope)
   - Sensitive categories: health/PHI, financial info, kids under 13, biometric, precise geolocation (usually no for an SMB SaaS)
8. **AI features?** — Does the product send user content to an AI API (Anthropic, OpenAI, Gemini)? Affects the Privacy Policy AI disclosure clause.
9. **Incident response owner** — who's on call when something breaks? (Default: the technical founder)
10. **Customer notification SLA for incidents** — default 72 hours; enterprise contracts often demand 24

### Inferred / defaulted (don't ask unless ambiguous)

- **Retention period** — default 30 days after account deletion
- **Backup retention** — default 30 days
- **Dispute resolution** — default to arbitration (more enforceable, cheaper); offer "courts only" alternative if user prefers

## Phase 3: Generate Filled Documents

For each of these template files, replace placeholders with the answers from Phase 2 and write the result:

| Template (source) | Output (destination) |
|---|---|
| `docs/compliance/privacy-policy.template.md` | `docs/legal/privacy-policy.md` |
| `docs/compliance/terms-of-service.template.md` | `docs/legal/terms-of-service.md` |
| `docs/compliance/acceptable-use-policy.template.md` | `docs/legal/acceptable-use-policy.md` |
| `docs/compliance/subprocessors.template.md` | `docs/legal/subprocessors.md` |
| `docs/compliance/incident-response.template.md` | `docs/compliance/incident-response.md` |

**Placeholder substitution rules:**

- Standard placeholders like `{{COMPANY_NAME}}`, `{{CONTACT_EMAIL}}`, `{{EFFECTIVE_DATE}}` → fill from questionnaire answers (use today's date for `{{EFFECTIVE_DATE}}`)
- Block placeholders like `{{DATA_USER_PROVIDED}}` → write a real bulleted list based on what the user said in question 7
- `{{SUBPROCESSOR_ROWS}}` → generate one Markdown table row per detected/confirmed subprocessor with sensible defaults for the Location and DPA columns (look up the vendor's standard trust page URL — Vercel = vercel.com/legal/dpa, Stripe = stripe.com/legal/dpa, etc.)
- `{{AI_USE_DISCLOSURE}}` and `{{AI_OUTPUTS_CLAUSE}}` → include the AI paragraphs if the user said yes to question 8; otherwise replace with "(not applicable — this product does not use AI features)" or remove the section
- `{{COMPANY_NAME_UPPER}}` → all-caps version of `{{COMPANY_NAME}}` for the liability cap section
- Leave the `<!-- ... -->` HTML comments at the bottom of each file in place (they document the placeholders for future maintainers)

**Important behaviors:**

- If a destination file already exists with content beyond placeholders, do NOT overwrite — instead, show a diff and ask the user before replacing
- Preserve any custom sections the user has added beyond the template structure
- Strip the example `<!-- ... -->` comment blocks from inside the templates (the ones showing example content) but keep the placeholder documentation block at the bottom

## Phase 4: Update `architecture.json`

Add or update the `compliance` block:

```json
"compliance": {
  "enabled": true,
  "tier": "smb",
  "geography": ["US"],
  "regulated_data": [],
  "privacy_policy_path": "docs/legal/privacy-policy.md",
  "terms_path": "docs/legal/terms-of-service.md",
  "subprocessors_path": "docs/legal/subprocessors.md",
  "aup_path": "docs/legal/acceptable-use-policy.md",
  "incident_response_path": "docs/compliance/incident-response.md",
  "last_reviewed": "YYYY-MM-DD"
}
```

Use today's date (read from the system, or ask the user if you can't). Set `regulated_data` to a list of any sensitive categories the user identified in question 7 (e.g. `["PHI"]` if they handle health data — though for SMB tier this is almost always `[]`).

If the user identified themselves as targeting mid-market, enterprise, or regulated tiers, set `tier` accordingly and note that the v1 docs are still SMB-sized — they should plan to upgrade.

## Phase 5: Report and Next Steps

Tell the user, in plain language:

1. **What was generated** — list the files written
2. **What to do this week**:
   - Review each generated doc — placeholders are filled but the content needs your eyes
   - Get a lawyer's review on `privacy-policy.md` and `terms-of-service.md` before publishing (~$1–5K for an SMB-sized review)
   - Publish the Privacy Policy at a public URL like `yourdomain.com/privacy`
   - Publish the Terms at `yourdomain.com/terms`
   - Publish the subprocessor list at `yourdomain.com/subprocessors`
3. **What was deferred** — items not generated and why (DPA, MSA, SOC 2 prep — wait until enterprise customers ask)
4. **Habits to build**:
   - When you add a new third-party API, update `subprocessors.md` in the same PR
   - Re-run `/compliance` (or just edit the docs) whenever you add a new feature that collects new data
   - Re-review every 6 months — `architecture.json compliance.last_reviewed` tracks this

If `docs/compliance/compliance-landscape.md` exists in the project (it does, if setup.sh ran with compliance enabled), point the user to it as the reference for the bigger picture.

---

## Reference: Common subprocessor metadata

When generating the subprocessor table, use these standard values where applicable:

| Vendor | Standard purpose | Typical location | Public DPA / trust page |
|---|---|---|---|
| Vercel | Hosting / edge | US (global edge) | vercel.com/legal/dpa |
| Neon | Postgres database | US | trust.neon.tech |
| Supabase | Database / auth | US | supabase.com/security |
| AWS | Compute / storage | US (region varies) | aws.amazon.com/compliance/data-protection |
| Cloudflare | CDN / WAF / DDoS | US (global) | cloudflare.com/cloudflare-customer-dpa |
| Stripe | Payments | US | stripe.com/legal/dpa |
| Anthropic | AI (Claude) | US | trust.anthropic.com |
| OpenAI | AI (GPT) | US | openai.com/policies/data-processing-addendum |
| Google (Gemini) | AI | US | cloud.google.com/terms/data-processing-addendum |
| Resend | Transactional email | US | resend.com/security |
| Postmark | Transactional email | US | postmarkapp.com/legal/dpa |
| SendGrid | Transactional email | US | twilio.com/legal/data-protection-addendum |
| Sentry | Error monitoring | US | sentry.io/legal/dpa |
| Datadog | Monitoring | US (region varies) | datadoghq.com/legal/data-processing-addendum |
| PostHog | Product analytics | US or EU | posthog.com/dpa |
| Mixpanel | Product analytics | US | mixpanel.com/legal/dpa |
| Inngest | Background jobs | US | inngest.com/security |
| Google Maps / Places | Maps and POI data | US | cloud.google.com/maps-platform/terms |
| Yelp Fusion | Business data | US | yelp.com/developers/api_terms |

If the project uses a vendor not in this table, generate a row anyway with the vendor name and purpose, and leave the DPA cell as "(look up vendor's DPA URL and fill in)" for the user to complete.

---

## Stack-Specific Adaptations

### For Next.js / React / Vite SaaS projects

- Default behavior above is tuned for this stack
- Subprocessor detection: read `.env.example` for `*_API_KEY` vars, `package.json` dependencies for SDKs
- Public URLs assumed: `/privacy`, `/terms`, `/subprocessors`

### For Python (Django/Flask/FastAPI) SaaS projects

- Same general flow
- Subprocessor detection: read `.env.example` and `pyproject.toml`/`requirements.txt`
- URL conventions and serving may differ but the doc structure is identical

### For static HTML projects

- The `/compliance` command is rarely useful here — static sites usually don't collect data
- If the user runs it on a static site, ask whether they actually need any of this (probably just a Privacy Policy if they use analytics)
- Skip Terms of Service unless they have a paid product

### For React Native / mobile projects

- Same flow but flag two extras: app store privacy nutrition labels (Apple) and Google Play data safety form must match what the Privacy Policy says
- Mention SDK-level disclosures (e.g. analytics SDKs that auto-collect data)

---

## Important Notes

- **This is not legal advice.** The generated docs are starting points. A lawyer should review before publishing — budget $1–5K for an SMB review.
- **Don't promise security you don't have.** The Privacy Policy makes specific claims (TLS, encryption at rest, MFA). If those aren't actually true in the project, either implement them or weaken the language.
- **Keep the docs accurate.** An inaccurate Privacy Policy is an FTC §5 violation. When you add a new vendor or data flow, update the Privacy Policy and subprocessor list in the same PR.
- **The reference doc matters.** `docs/compliance/compliance-landscape.md` (installed by setup.sh) has the full mental model. Point users there when they ask "do I need SOC 2?"
- **Don't bloat the doc set.** This command intentionally does NOT generate DPA, MSA, BAA, SOC 2 prep, or HIPAA docs — those are for higher customer tiers and would distract an SMB-tier project. If the user identifies as mid-market or enterprise, set `architecture.json compliance.tier` accordingly but still generate only SMB docs (with a note about what's deferred).
