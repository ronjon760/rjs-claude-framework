# Compliance questionnaire and fill rules

## Questions

Ask one at a time or as a batched block, whichever feels natural. Skip anything the project signals already answered.

### Needed to fill the templates

1. **Legal entity name** — the formal name on the incorporation paperwork (e.g. "Acme Co, Inc.").
2. **Contact email for privacy/legal matters** — typically `privacy@yourcompany.com` or `support@`.
3. **Mailing address** — required by CCPA so users can reach the company offline.
4. **Governing state for the ToS** — usually Delaware (if DE-incorporated) or the home state.

### Strongly recommended (skippable with defaults)

5. **Target customer tier** — SMB (default), or planning to sell upmarket. Recorded in `architecture.json`; affects future work, not today's docs.
6. **Customer geography** — US-only (default), or EU/global. If EU, flag that the docs would need GDPR additions (not generated in v1).
7. **What data does the product collect?**
   - Account data (almost always yes)
   - Content uploaded by users (often yes)
   - Payment info (yes if it charges; almost always via Stripe, which keeps it out of PCI scope)
   - Sensitive categories: health/PHI, financial info, kids under 13, biometric, precise geolocation (usually no for SMB SaaS)
8. **AI features?** — Does the product send user content to an AI API (Anthropic, OpenAI, Gemini)? Drives the Privacy Policy AI disclosure.
9. **Incident response owner** — who is on call when something breaks (default: the technical founder).
10. **Customer notification SLA for incidents** — default 72 hours; enterprise contracts often demand 24.

### Defaults (ask only if ambiguous)

- Retention period: 30 days after account deletion
- Backup retention: 30 days
- Dispute resolution: arbitration (more enforceable, cheaper); offer "courts only" if the user prefers

## Template → output mapping

| Template (source) | Output (destination) |
|---|---|
| `privacy-policy.template.md` | `docs/legal/privacy-policy.md` |
| `terms-of-service.template.md` | `docs/legal/terms-of-service.md` |
| `acceptable-use-policy.template.md` | `docs/legal/acceptable-use-policy.md` |
| `subprocessors.template.md` | `docs/legal/subprocessors.md` |
| `incident-response.template.md` | `docs/compliance/incident-response.md` |

## Placeholder substitution

- Simple placeholders (`{{COMPANY_NAME}}`, `{{CONTACT_EMAIL}}`, `{{EFFECTIVE_DATE}}`) — fill from the answers; today's date for `{{EFFECTIVE_DATE}}`.
- Block placeholders like `{{DATA_USER_PROVIDED}}` — write a real bulleted list from question 7.
- `{{SUBPROCESSOR_ROWS}}` — one table row per confirmed vendor, using `reference.md` for location and DPA links.
- `{{AI_USE_DISCLOSURE}}` and `{{AI_OUTPUTS_CLAUSE}}` — include the AI paragraphs if question 8 was yes; otherwise replace with "(not applicable — this product does not use AI features)" or remove the section.
- `{{COMPANY_NAME_UPPER}}` — all-caps company name, for the liability cap section.
- Strip the example-content `<!-- ... -->` comments inside the templates, but keep the placeholder documentation block at the bottom of each file for future maintainers.

## `architecture.json` compliance block

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

Set `last_reviewed` to today. Set `regulated_data` to any sensitive categories from question 7 (e.g. `["PHI"]`; almost always `[]` for SMB). If the user targets mid-market, enterprise, or regulated tiers, set `tier` accordingly and note that the generated docs are still SMB-sized.
