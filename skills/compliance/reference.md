# Compliance reference

## Subprocessor metadata

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

## Stack-specific Adaptations

### For Next.js / React / Vite SaaS projects

- Default behavior above is tuned for this stack
- Subprocessor detection: read `.env.example` for `*_API_KEY` vars, `package.json` dependencies for SDKs
- Public URLs assumed: `/privacy`, `/terms`, `/subprocessors`

### For Python (Django/Flask/FastAPI) SaaS projects

- Same general flow
- Subprocessor detection: read `.env.example` and `pyproject.toml`/`requirements.txt`
- URL conventions and serving may differ but the doc structure is identical

### For static HTML projects

- The `/rjs:compliance` skill is rarely useful here — static sites usually don't collect data
- If the user runs it on a static site, ask whether they actually need any of this (probably just a Privacy Policy if they use analytics)
- Skip Terms of Service unless they have a paid product

### For React Native / mobile projects

- Same flow but flag two extras: app store privacy nutrition labels (Apple) and Google Play data safety form must match what the Privacy Policy says
- Mention SDK-level disclosures (e.g. analytics SDKs that auto-collect data)
