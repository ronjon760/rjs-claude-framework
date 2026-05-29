# Subprocessors

**Last updated:** {{EFFECTIVE_DATE}}

A "subprocessor" is a third-party service we use that may process personal information you provide to {{PRODUCT_NAME}}. We are responsible for ensuring each subprocessor meets the privacy and security standards we describe in our [Privacy Policy](./privacy-policy.md).

This page is the **authoritative list** of every third-party service we send personal data to. Whenever we add or remove a subprocessor, this page is updated and existing customers are notified per the timeline below.

---

## Current Subprocessors

| Subprocessor | Purpose | Data category | Location | DPA / Security |
|---|---|---|---|---|
{{SUBPROCESSOR_ROWS}}
<!-- Example rows to start with — keep/edit/remove based on your actual stack:

| Vercel | Hosting, edge functions | All product data in transit; some at rest | US (global edge) | [Vercel DPA](https://vercel.com/legal/dpa) — SOC 2 Type II, ISO 27001 |
| Neon | Primary database | All customer account and content data | US | [Neon Trust Center](https://trust.neon.tech) — SOC 2 Type II |
| Stripe | Payment processing | Billing details, payment methods | US | [Stripe DPA](https://stripe.com/legal/dpa) — PCI Level 1, SOC 1/2, ISO 27001 |
| Anthropic | AI processing | Content sent to AI features | US | [Anthropic Trust Center](https://trust.anthropic.com) — SOC 2 Type II; no training on customer data |
| Resend | Transactional email | Email addresses, email content | US | [Resend Security](https://resend.com/security) — SOC 2 |
| Sentry | Error monitoring | Error logs (may include IP, user ID) | US | [Sentry DPA](https://sentry.io/legal/dpa) — SOC 2 Type II |
| Cloudflare | CDN, WAF, DDoS | IPs, request headers | US (global) | [Cloudflare DPA](https://www.cloudflare.com/cloudflare-customer-dpa) — SOC 2, ISO 27001 |
| Google Cloud | (if applicable) | Specific data types here | US | Google DPA |

Add or remove rows so this table reflects YOUR stack exactly. Every API key in your .env should map to a row here.
-->

---

## How to interpret this list

- **Purpose** — what the subprocessor does for us
- **Data category** — what kinds of data we send them (account data, content, logs, billing, etc.)
- **Location** — primary processing location
- **DPA / Security** — the subprocessor's Data Processing Agreement and security posture (links to their public trust pages)

---

## Adding new subprocessors

Before we add a new subprocessor, we:

1. Verify they have an appropriate data protection agreement
2. Confirm they meet our security baseline (encryption at rest and in transit, documented incident response)
3. Update this page
4. Notify customers via email or in-product notice **at least 14 days in advance** (for material additions)

If you object to a new subprocessor, contact {{CONTACT_EMAIL}}. Customers on Enterprise plans (when available) may have additional rights under their service agreement.

---

## Subprocessor notification list

To receive email notifications when this list changes:

- Account holders are automatically subscribed on their account email
- Anyone else can subscribe by emailing {{CONTACT_EMAIL}} with the subject "Subprocessor notifications"

---

## How to update this page

When you add a new third-party API or service to the product:

1. Edit this file — add a row for the new subprocessor
2. Update the "Last updated" date at the top
3. Update the Privacy Policy if the new subprocessor handles a new category of data
4. Send the subprocessor-change notification email (if you have customers)
5. Commit the change

**Drift rule:** every `*_API_KEY` in `.env.example` and every external service called from production code should correspond to a row in this table. If you can't find it here, you have a drift problem.

---

<!--
PLACEHOLDERS TO FILL IN:

{{EFFECTIVE_DATE}}     — Date this page was last updated
{{PRODUCT_NAME}}       — Your product's public name
{{CONTACT_EMAIL}}      — privacy@yourcompany.com
{{SUBPROCESSOR_ROWS}}  — Markdown table rows for each vendor

Auto-detected subprocessors from your project setup will be pre-filled by /compliance.
-->
