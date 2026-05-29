# Privacy Policy

**Effective date:** {{EFFECTIVE_DATE}}
**Last updated:** {{EFFECTIVE_DATE}}

{{COMPANY_NAME}} ("we," "our," or "us") operates {{PRODUCT_NAME}} (the "Service"). This Privacy Policy explains what information we collect, how we use it, who we share it with, and the rights you have.

If you are a California resident, see the [California Residents](#california-residents-ccpacpra) section. If you are in another US state with a privacy law (Virginia, Colorado, Connecticut, Utah, Texas, Florida, Oregon, Montana, Iowa, Indiana, Tennessee, Delaware, New Hampshire, New Jersey, Minnesota, Maryland, Rhode Island, Kentucky), see the [US State Privacy Rights](#us-state-privacy-rights) section.

Contact: {{CONTACT_EMAIL}}

---

## 1. Information We Collect

We collect the following categories of information:

**Information you provide to us:**
{{DATA_USER_PROVIDED}}
<!-- Examples to keep / remove:
- Name, email address, and password when you create an account
- Billing information when you subscribe (processed by Stripe; we do not store full card numbers)
- Content you upload, create, or submit through the Service
- Communications you send to our support team
-->

**Information collected automatically:**
{{DATA_COLLECTED_AUTO}}
<!-- Examples:
- IP address, browser type, device information
- Pages you view, features you use, time spent
- Cookies and similar technologies (see Cookies section)
- Approximate location derived from IP address
-->

**Information from third parties:**
{{DATA_FROM_THIRD_PARTIES}}
<!-- Examples (delete if not applicable):
- Authentication providers (Google, GitHub) if you sign in with them
- Public business information from Google Places, Yelp, or similar APIs (only for products that look up businesses)
-->

We do not knowingly collect personal information from children under 13. If you believe a child has provided us information, contact {{CONTACT_EMAIL}} and we will delete it.

---

## 2. How We Use Information

We use the information we collect to:

- Provide, operate, and maintain the Service
- Authenticate you and secure your account
- Process payments and prevent fraud
- Respond to your support requests
- Send service-related communications (account confirmations, billing, security)
- Send marketing communications **only if you opt in**, with an unsubscribe link in every email
- Improve and develop new features
- Detect and prevent abuse, fraud, or violations of our Terms of Service
- Comply with legal obligations

{{AI_USE_DISCLOSURE}}
<!-- If product uses AI APIs (Anthropic, OpenAI, Gemini, etc.), include language like:
We use third-party AI services to process content you submit (for example, [Anthropic Claude / OpenAI GPT / Google Gemini]).
Your content is sent to these services to generate responses or analyses.
We do not permit these providers to train their models on your content where opt-out is available, and we configure our integrations to disable training by default.
See our subprocessor list for details.
-->

We do **not** sell your personal information for money. We may "share" personal information for cross-context behavioral advertising under California law if you have opted in or if applicable; you can opt out using the link at the bottom of every page.

---

## 3. Who We Share Information With

We share information only with:

**Subprocessors** — third-party service providers we rely on to operate the Service. A current list is at {{SUBPROCESSORS_URL}}. Each subprocessor is contractually obligated to handle your data with at least the same protections we provide.

**At your direction** — when you choose to integrate, export, or share data with another service.

**Legal compliance** — when required by law, subpoena, or to protect the rights, safety, or property of {{COMPANY_NAME}}, our users, or the public.

**Business transfers** — if {{COMPANY_NAME}} is involved in a merger, acquisition, or sale of assets, your information may be transferred. We will notify you before your information becomes subject to a different privacy policy.

We do not sell personal information to data brokers.

---

## 4. Data Retention

We retain personal information for as long as your account is active and as needed to provide the Service. After you delete your account or request deletion, we delete or anonymize your personal information within **{{RETENTION_DAYS}} days**, except where we are required to retain it for legal, accounting, or fraud-prevention purposes.

Backups containing your information are purged on a rolling **{{BACKUP_RETENTION_DAYS}}-day** cycle.

---

## 5. Security

We use industry-standard practices to protect your information, including:

- TLS encryption for all data in transit
- Encryption at rest for our databases and backups
- Multi-factor authentication required for all employee access to production systems
- Least-privilege access controls reviewed periodically
- Secret management via environment variables (never in source code)
- Routine dependency and vulnerability scanning

No security control is perfect. If you suspect your account has been compromised, contact {{CONTACT_EMAIL}} immediately.

---

## 6. Your Rights

Regardless of where you live, you can:

- **Access** the personal information we hold about you
- **Correct** inaccurate information
- **Delete** your account and associated personal information
- **Export** a copy of your data in a portable format
- **Opt out** of marketing communications at any time

To exercise these rights, email {{CONTACT_EMAIL}} or use the relevant tools in your account settings. We respond within **45 days**.

### California Residents (CCPA/CPRA)

If you are a California resident, you have additional rights under the California Consumer Privacy Act and California Privacy Rights Act:

- The right to know what categories of personal information we collect, the purposes, and the categories of third parties we share with (described above)
- The right to delete personal information we hold about you
- The right to correct inaccurate personal information
- The right to opt out of "sale" or "sharing" of personal information for cross-context behavioral advertising
- The right to limit use of sensitive personal information
- The right to non-discrimination for exercising these rights

To exercise these rights, email {{CONTACT_EMAIL}} or use the **"Do Not Sell or Share My Personal Information"** link in our footer. We will not discriminate against you for exercising these rights.

We honor browser-based universal opt-out signals such as the Global Privacy Control (GPC).

### US State Privacy Rights

If you are a resident of Virginia, Colorado, Connecticut, Utah, Texas, Florida, Oregon, Montana, Iowa, Indiana, Tennessee, Delaware, New Hampshire, New Jersey, Minnesota, Maryland, Rhode Island, or Kentucky, you have rights substantially similar to those of California residents above. To exercise them, contact {{CONTACT_EMAIL}}.

---

## 7. Cookies and Similar Technologies

We use cookies and similar technologies for:

- **Strictly necessary** — keeping you logged in, remembering your preferences
- **Analytics** — understanding how the Service is used (aggregate)
- **Marketing** (only if applicable) — measuring the effectiveness of campaigns

You can disable non-essential cookies through your browser settings or our cookie preferences tool (if displayed). Disabling necessary cookies may break the Service.

---

## 8. International Users

The Service is hosted in the United States. If you access it from outside the US, your information will be transferred to and processed in the US, which may have different data protection laws than your jurisdiction.

---

## 9. Changes to This Policy

We may update this Privacy Policy from time to time. Material changes will be communicated via email (to registered users) or a prominent notice in the Service before they take effect. The "Last updated" date at the top reflects the most recent revision.

---

## 10. Contact

Questions about this Privacy Policy or our handling of your information:

**{{COMPANY_NAME}}**
{{CONTACT_EMAIL}}
{{MAILING_ADDRESS}}

---

<!--
PLACEHOLDERS TO FILL IN (run /compliance to do this interactively, or fill manually):

{{EFFECTIVE_DATE}}            — e.g. May 28, 2026
{{COMPANY_NAME}}              — Your legal entity name
{{PRODUCT_NAME}}              — Your product's public name
{{CONTACT_EMAIL}}             — privacy@yourcompany.com
{{MAILING_ADDRESS}}           — Your business address (CCPA requires this be reachable)
{{DATA_USER_PROVIDED}}        — Bullet list of what users give you
{{DATA_COLLECTED_AUTO}}       — Bullet list of what you collect automatically
{{DATA_FROM_THIRD_PARTIES}}   — Bullet list (or "(none)" if not applicable)
{{AI_USE_DISCLOSURE}}         — Paragraph about AI vendors (or "(not applicable)")
{{SUBPROCESSORS_URL}}         — Public URL where subprocessor list lives, e.g. yourdomain.com/subprocessors
{{RETENTION_DAYS}}            — Standard: 30 or 60
{{BACKUP_RETENTION_DAYS}}     — Standard: 30 or 90

NOT LEGAL ADVICE. Have a lawyer review before publishing.
-->
