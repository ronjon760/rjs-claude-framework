# Enterprise Procurement Questionnaire — Cheat Sheet

*The actual questions enterprise buyers ask in security review, with how to answer at each tier. Use this as a self-assessment: if you read a question and have no honest answer, that's a gap.*

---

## How this works

When an enterprise customer wants to buy your SaaS, their security/procurement team sends you a **vendor security questionnaire**. The most common formats:

- **CAIQ** (Cloud Security Alliance Consensus Assessments Initiative Questionnaire) — ~260 yes/no questions
- **SIG Lite / SIG Core** (Shared Assessments) — ~125 to 1,200+ questions depending on flavor
- **Custom questionnaires** — most large enterprises have their own, usually 100–400 questions

The questions are real and repetitive. Below is a distilled set covering ~80% of what you'll actually be asked, grouped by theme, with two answer columns:

- **SMB-tier vendor answer** — what's reasonable for a small company selling to small businesses
- **Enterprise-tier vendor answer** — what an enterprise buyer expects to hear from a vendor they're paying $100K+/year

If your honest answer is closer to "we don't do that," the answer column tells you whether that's OK at your tier or whether it's a gap.

---

## Section 1 — Organization & Governance

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you have a written information security policy? | "We have documented security practices, available on request." | "Yes, reviewed annually by leadership. Available under NDA." |
| Who owns information security at your company? | "The founders." | "Our CISO / Head of Security, reporting to the CEO. Dedicated security team of N people." |
| Do you maintain a risk register? | "Informally, in our planning docs." | "Yes, formal risk register reviewed quarterly." |
| Do you have a Board-level committee that oversees security? | "No." (Acceptable.) | "Yes, our Audit Committee receives quarterly security briefings." |
| How often do you train employees on security? | "All employees complete annual security awareness training." | "All employees: annual + monthly phishing simulations + role-based training for engineers and customer-facing staff." |
| Do you conduct background checks on employees? | "We conduct background checks on all new hires who will have access to customer data." | "Yes, all hires; refreshed every N years for staff in sensitive roles." |
| Do you have a written acceptable use policy for employees? | "Yes — included in our employee handbook." | "Yes — separate AUP, acknowledged annually in writing by every employee." |

**Gap indicators at SMB tier:** No security training at all. No documented security practices anywhere.
**Gap indicators at Enterprise tier:** No CISO or named security owner. No formal risk register. No background checks.

---

## Section 2 — Data Handling & Privacy

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| What types of customer data do you collect? | "We collect [specific list — accounts, usage data, content uploaded]. See our Privacy Policy." | Same, plus a formal data classification scheme (Public / Internal / Confidential / Restricted). |
| Do you have a published Privacy Policy? | "Yes, at [URL]." | Same. |
| Are you CCPA compliant? | "Yes — we publish a Privacy Policy, honor opt-out signals, and process deletion requests." | Same, plus formal in-product DSAR tools and documented response SLAs. |
| Can customers export their data? | "Yes, via [mechanism] or by emailing support." | "Yes, self-service export available in the product, including in machine-readable formats." |
| Can customers delete their data? | "Yes, on request via support." | "Yes, self-service deletion + documented retention/deletion schedule + audit log of deletions." |
| What is your data retention policy? | "We retain customer data for the life of the account plus 30 days after deletion." | "Documented retention schedule by data type, enforced via automated processes, reviewed annually." |
| Do you sell customer data? | "No." | "No." |
| Do you use customer data to train AI/ML models? | "[Honest answer. If yes, explain. If no, say no clearly.]" | Same — and be specific about which models, what consent, what opt-outs exist. |
| Do you have a Data Processing Agreement available? | "Yes — available on request." (Have one ready.) | "Yes — our standard DPA is at [URL]. We can also accept customer DPAs subject to review." |
| Where is customer data stored geographically? | "United States." | "United States by default; EU residency available on Enterprise plans." |

**Gap indicators at SMB tier:** No Privacy Policy. Selling data without disclosure. AI training on customer data without consent.
**Gap indicators at Enterprise tier:** No DPA template. No self-service data export/deletion. No formal data classification.

---

## Section 3 — Access Control & Identity

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you enforce MFA for all employees? | "Yes — required for all employees accessing production systems." | "Yes — hardware MFA required for engineers; phishing-resistant MFA for everyone." |
| Do you support SSO for customers? | "Not currently — on our roadmap." (Acceptable for SMB tier.) | "Yes, SAML 2.0 and OIDC supported. Customer-configurable via standard IdPs (Okta, Azure AD, Google Workspace, OneLogin, JumpCloud)." |
| Do you support SCIM for user provisioning? | "Not currently." | "Yes — SCIM 2.0 supported." |
| How do you control employee access to customer data? | "Least-privilege; access granted on need-to-know basis." | "RBAC enforced via [tool]. All access logged and reviewed quarterly. Production access requires ticketed approval and time-bounded." |
| Do you review user access regularly? | "Yes, ad-hoc when employees change roles or leave." | "Quarterly access reviews for all systems containing customer data." |
| What happens when an employee leaves? | "We have a documented offboarding checklist that revokes all access on the last day." | Same, plus automated deprovisioning via IdP integration. |
| Do you log administrative actions? | "Yes — most actions are logged in [system]." | "All admin actions logged to a tamper-evident audit log retained for [N] years." |
| Can customers view audit logs of their account's activity? | "Limited — available on request via support." | "Yes — exportable audit logs available to admins in-product." |

**Gap indicators at SMB tier:** No MFA. Shared admin credentials. No offboarding process.
**Gap indicators at Enterprise tier:** No SSO. No SCIM. No customer-facing audit logs. Standing access to production.

---

## Section 4 — Infrastructure & Encryption

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Where do you host customer data? | "[Cloud provider — AWS, GCP, Azure, Vercel, Neon, etc.]. SOC 2 / ISO 27001 certified provider." | Same, with specific data center regions named. |
| Is data encrypted in transit? | "Yes — TLS 1.2+ for all customer-facing and internal communications." | Same, plus mutual TLS for service-to-service where applicable. |
| Is data encrypted at rest? | "Yes — AES-256 at the database and backup layer." | Same, plus customer-managed encryption keys (BYOK) available on Enterprise plans. |
| Do you support customer-managed encryption keys? | "Not currently." | "Yes — BYOK via [KMS integration] available on Enterprise." |
| How are encryption keys managed? | "Managed by our cloud provider's KMS." | Same, with detailed key rotation procedures documented. |
| Do you maintain separation between customer data in a multi-tenant environment? | "Yes — logical separation via [mechanism: tenant ID, row-level security, separate schemas]." | Same, with specifics on isolation guarantees and tested cross-tenant access controls. |
| Can customers be provisioned in a single-tenant environment? | "No." | "Yes — single-tenant deployment available on Enterprise/dedicated plans." |
| Do you back up customer data? | "Yes — daily automated backups, retained [N days]." | Same, plus documented RTO and RPO, tested quarterly, geographically redundant. |
| Do you have a disaster recovery plan? | "Yes — documented and tested annually." | "Yes — documented, tested at least annually, RTO of N hours, RPO of N minutes." |

**Gap indicators at SMB tier:** Unencrypted data in transit or at rest. Untested backups.
**Gap indicators at Enterprise tier:** No documented RTO/RPO. No tested DR. No single-tenant option for sensitive customers.

---

## Section 5 — Application Security & Development

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you have a secure SDLC? | "Yes — code review required for all changes; security checks via [linters, static analysis]." | Same, plus formal threat modeling for new features, SAST + DAST + SCA in CI, documented secure coding standards. |
| Do you require peer code review? | "Yes — every PR requires review before merge." | Same, with specific reviewer requirements for security-sensitive code. |
| Do you run vulnerability scans on your code dependencies? | "Yes — Dependabot / Snyk / similar." | Same, plus SLA on patching critical vulnerabilities (e.g. 7 days for criticals). |
| Do you conduct application penetration testing? | "Not annually yet — planned." (Acceptable for SMB tier with planned date.) | "Yes — annual third-party pen test by [firm]. Summary report available under NDA." |
| Do you have a bug bounty or vulnerability disclosure program? | "We accept vulnerability reports at security@[domain]." | "Yes — public VDP. Bug bounty via [HackerOne / Bugcrowd / private] with payouts for valid findings." |
| How quickly do you patch critical vulnerabilities? | "Criticals are patched as soon as a fix is available, typically within days." | "Critical: 7 days. High: 30 days. Medium: 90 days. Documented SLA." |
| Do you have a WAF in front of your application? | "Yes — [Cloudflare / AWS WAF / similar]." | Same, with managed rule sets and custom rule capability. |

**Gap indicators at SMB tier:** No dependency scanning. No code review. No way to report a vulnerability.
**Gap indicators at Enterprise tier:** No pen test. No published SLA on patching. No formal SDLC documentation.

---

## Section 6 — Incident Response & Monitoring

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you have a documented incident response plan? | "Yes — one-page plan covering detection, containment, notification, and post-mortem." | "Yes — formal IR plan with named roles, runbooks per incident type, tested via annual tabletop." |
| How do you detect security incidents? | "Cloud provider alerts + error monitoring + anomaly alerts on key metrics." | Same, plus SIEM (e.g. Datadog, Panther, Splunk) with custom detections and 24/7 monitoring." |
| Do you have 24/7 security monitoring? | "No — business hours response with on-call escalation." | "Yes — 24/7 monitoring (internal SOC or MSSP)." |
| What is your customer notification SLA for security incidents? | "We will notify affected customers within 72 hours of confirmation." | "Within 24 hours of confirmation for incidents affecting customer data; without undue delay for material incidents per applicable law." |
| Have you experienced any security incidents in the past 24 months? | [Honest answer. If yes, brief, factual, what was done.] | Same — same standard. |
| Do you conduct annual tabletop exercises? | "Not yet — planned." (Acceptable for SMB.) | "Yes — at minimum annually, often quarterly, covering different scenarios." |
| Do you have cyber liability insurance? | "Yes — $1M coverage with [carrier]." (Or "Not yet, planned.") | "Yes — $5M – $25M+ coverage with [carrier]. Certificate available on request." |

**Gap indicators at SMB tier:** No documented IR plan. No way to know if an incident occurred.
**Gap indicators at Enterprise tier:** Notification SLA over 72 hours. No tabletop exercises. Insurance under $5M.

---

## Section 7 — Third-Party Risk & Subprocessors

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you maintain a list of subprocessors? | "Yes — published at [URL]." | Same, plus 30-day notification before adding new subprocessors with customer right to object. |
| Do you assess the security of your subprocessors? | "We use established providers (AWS / GCP / Stripe / etc.) with industry-standard certifications." | "Yes — formal vendor risk management program with tiered assessment, ongoing monitoring, contractual flow-down of security obligations." |
| Do your subprocessors sign data protection agreements? | "Yes — all subprocessors that handle customer data are bound by DPAs or equivalent terms." | Same — and we can provide the chain of agreements on audit. |
| How do you notify customers when you add a subprocessor? | "We update our subprocessors page; major changes are communicated via email." | "Email notification 30 days in advance; customers can object." |
| Do you allow customer audit of your subprocessors? | "On reasonable request." | "Yes — annual right to review subprocessor list and risk assessments." |

**Gap indicators at SMB tier:** No subprocessor list at all. No DPAs with anyone.
**Gap indicators at Enterprise tier:** No advance notice of new subprocessors. No formal VRM program.

---

## Section 8 — Compliance & Certifications

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Are you SOC 2 Type II certified? | "Not yet — pursuing in [year]." (Acceptable for SMB if there's a real plan.) Otherwise: "We operate aligned to SOC 2 trust services criteria; report not yet available." | "Yes — SOC 2 Type II report available under NDA via our Trust Center." |
| Are you ISO 27001 certified? | "No." | "Yes" or "Not currently; aligned to ISO 27001." |
| Are you HIPAA compliant? Can you sign a BAA? | "We do not currently support HIPAA workloads." (Honest is best.) | "Yes — we operate HIPAA-aligned controls and sign BAAs with Enterprise customers." |
| Are you PCI-DSS compliant? | "We do not store or process cardholder data directly; payments are handled by Stripe (PCI Level 1)." | Same, unless you've taken on PCI scope. |
| Are you GDPR compliant? | "We are not subject to GDPR (US-only operation), but we operate practices consistent with GDPR." | "Yes — we operate as a Data Processor under GDPR. Standard Contractual Clauses available." |
| Do you have a CAIQ on file? | "We do not maintain a CAIQ; happy to answer specific questions." (Acceptable for SMB.) | "Yes — current CAIQ available via Trust Center / on request." |

**Gap indicators at SMB tier:** None — saying "no" to certifications is acceptable.
**Gap indicators at Enterprise tier:** No SOC 2 Type II. No BAA option if you serve healthcare-adjacent customers. No Trust Center.

---

## Section 9 — Personnel Security

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do all employees sign confidentiality agreements? | "Yes — included in employment agreements." | Same. |
| Do you conduct background checks? | "Yes — all new hires." | Same, with documented standards and refresh cycles. |
| Do employees use company-managed devices? | "Yes — company-issued laptops with [MDM]." (Or honest: "Mix of personal and company devices with security baseline enforced.") | "Yes — company-managed devices required for all access to production and customer data, with MDM, EDR, and disk encryption enforced." |
| Do you have a process for terminating access when employees leave? | "Yes — same-day revocation of all access on departure." | Same, with documented checklist and audit trail. |

**Gap indicators at SMB tier:** Shared accounts. No NDAs. Personal devices accessing production with no controls.
**Gap indicators at Enterprise tier:** No MDM. No EDR. No documented offboarding audit trail.

---

## Section 10 — Business Continuity

| Question | SMB-tier answer | Enterprise-tier answer |
|---|---|---|
| Do you have a documented business continuity plan? | "Yes — covers key failure scenarios and recovery procedures." | "Yes — formal BCP reviewed annually, tested at least annually." |
| What is your stated uptime SLA? | "We target 99.5% – 99.9%. No formal credits at SMB tier." | "99.9% with service credits per contract." |
| Where do you store backups? | "Geographically separate region within [cloud provider]." | Same, with details on encryption, retention, and tested restoration. |
| How often do you test backup restoration? | "At least annually." | "Quarterly, with documented results." |
| What is your Recovery Time Objective (RTO)? | "Best effort — typically within 24 hours for major incidents." | "RTO: 4 hours. RPO: 15 minutes." |

**Gap indicators at SMB tier:** No backups. Untested backups.
**Gap indicators at Enterprise tier:** No documented RTO/RPO. No SLA credits. Backup testing less than quarterly.

---

## How to use this for self-assessment

1. **Print or open this doc.** Go through each section.
2. **For each question, write your honest answer.** Not the aspirational answer — the answer you'd give a security auditor.
3. **Compare to the tier you're selling to.** If you sell to SMB only, you only need to match the SMB column. If you sell to Enterprise, you need to match the Enterprise column.
4. **List the gaps.** Anything where your honest answer is weaker than the tier column you need to match.
5. **Triage the gaps.**
   - "Cheap and fast" gaps (write a policy, turn on a setting): fix now.
   - "Expensive or slow" gaps (SOC 2, pen test, SSO build): build a 6–12 month roadmap.
   - "Not actually needed" gaps (you're answering above your tier): leave them.

---

## Common red flags reviewers look for

These are the answers that immediately downgrade or kill a deal in enterprise procurement:

- **"We don't have a Privacy Policy."** Disqualifying.
- **"We share admin passwords."** Disqualifying.
- **"We don't have backups."** Disqualifying.
- **"We use customer data to train our AI without consent."** Often disqualifying; always a red flag.
- **"No, we don't support MFA."** Disqualifying for anyone above SMB tier.
- **"We've never had a security incident."** Sounds good — security teams read this as "they don't have detection."
- **"We're working on SOC 2."** Acceptable answer; ask for a target date and current auditor.
- **Vague answers everywhere.** Security teams interpret vagueness as the absence of a control. Specifics — even imperfect ones — score higher than generalities.

---

## The minimum you need to be able to answer

If you can't answer **these 10 questions** clearly, you're not ready to sell to anyone above SMB tier:

1. Where is customer data stored?
2. Who has access to customer data and how is that access controlled?
3. Is customer data encrypted in transit and at rest?
4. How are backups handled, and have you tested restoring from one?
5. Do you have MFA on all employee accounts that access production?
6. Do you have a Privacy Policy, and does it accurately describe what your product does?
7. If a security incident happened, what would you do, and how would customers find out?
8. Who are your subprocessors and what data do they receive?
9. What happens to customer data when they cancel?
10. Do you have cyber liability insurance?

These ten are the floor. Everything else builds from here.

---

*Companion to `compliance-landscape.md` and `compliance-one-pager.md`. Not legal advice — when answering an actual questionnaire for an actual deal, route through your legal/security lead and don't say anything you can't substantiate.*
