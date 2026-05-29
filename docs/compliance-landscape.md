# Enterprise SaaS Compliance & Legal Landscape

*A strategic reference for founders and operators building a US-based SaaS product. Last updated: 2026.*

---

## How to Use This Document

This is a **landscape map**, not an implementation checklist. The goal is to give you a clear mental model of every category of "compliance" obligation that can apply to a SaaS application, and to show how those obligations change depending on **who you sell to**.

There are three companion documents:

- **`compliance-one-pager.md`** — plain-language summary for non-technical readers
- **`compliance-questionnaire-cheatsheet.md`** — the actual questions enterprise buyers ask in security review, with how to answer at each tier
- *(this file)* — the landscape map and category deep-dives

---

## Part 1 — The Mental Model

### The single most important thing to understand

When people say "compliance," they usually mean four very different things bundled together:

| Forcing function | Who imposes it | What happens if you ignore it |
|---|---|---|
| **Law** | Governments (federal, state, foreign) | Fines, lawsuits, criminal liability in some cases |
| **Contract** | Your customers (via MSAs, DPAs, security exhibits) | You can't close the deal |
| **Certification** | Third-party auditors (SOC 2, ISO, FedRAMP) | You can't even start the deal — procurement filters you out |
| **Insurance** | Cyber liability underwriters | Premiums spike, coverage shrinks, or you can't get a policy |

**The big insight:** only the *first* one is mandatory in the legal sense. The other three are entirely commercial — you only need them if you want to sell to customers who require them.

This is why the "compliance bar" for SMB SaaS (Owner.com, Website OS, Mailchimp, Squarespace) is dramatically lower than for enterprise SaaS (Salesforce, Workday, ServiceNow). It's not that the laws are different — it's that **SMB customers don't ask the questions enterprise customers ask**.

### The four-tier customer model

Throughout this doc, we use four tiers. Your **compliance posture should match your highest-tier customer**, not your typical customer.

| Tier | Who they are | Typical compliance ask |
|---|---|---|
| **SMB** | Local businesses, solo operators, small chains (Owner.com customers, Website OS customers) | None — they click "Accept" on your ToS and never read it |
| **Mid-Market** | 100–1,000 employee companies | DPA on request, basic security questionnaire, "do you have SOC 2 in progress?" |
| **Enterprise** | Fortune 1000, big logos | SOC 2 Type II, signed DPA, MSA redlines, custom SLA, cyber insurance proof, SSO/SCIM, security questionnaire (CAIQ or SIG Lite) |
| **Regulated** | Healthcare, finance, government, education | All of Enterprise *plus* sector-specific frameworks: HIPAA + BAA (health), PCI-DSS (cards), FedRAMP (US gov), FERPA (education), GLBA (finance) |

### The four forcing functions, explained

**1. Law.** The legal floor. Roughly the same for everyone in the US:
- A **Privacy Policy** is required by every major US state privacy law and by California's CalOPPA since 2003. Skipping it is illegal.
- **CCPA/CPRA** (California) applies if you have CA residents in your user base and meet revenue/volume thresholds (most do at any scale).
- **State privacy laws** (~20 states as of 2026: VA, CO, CT, UT, TX, FL, OR, MT, IA, IN, TN, DE, NH, NJ, MN, MD, RI, KY, etc.) all impose Privacy Policy + consumer rights requirements with mild variation.
- **Sectoral laws** apply only if you touch the regulated data: **HIPAA** (PHI), **GLBA** (financial), **COPPA** (kids under 13), **FERPA** (student records).
- **FTC Act §5** applies to everyone — "unfair or deceptive practices." Translation: don't lie in your Privacy Policy, don't promise security you don't have.

**2. Contract.** This is where 90% of enterprise compliance cost lives. Your customer's procurement team sends you a 60-page MSA + security exhibit. You sign it or you don't sell. Common asks:
- DPA (Data Processing Agreement) with specific subprocessor and breach-notification terms
- Audit rights ("we can audit your security controls annually")
- Liability caps removed or raised
- Specific control requirements (encryption at rest, MFA, audit logs, etc.)
- Notification SLAs ("notify us within 24 hours of any security incident")

**3. Certification.** A third party audits you and issues a report or certificate. The big ones for SaaS:
- **SOC 2 Type II** — the de facto US enterprise SaaS baseline. Costs $15–60K/year for an audit. Required by ~80% of enterprise buyers.
- **ISO 27001** — international equivalent, more common when selling internationally. Also $20–50K/year.
- **HIPAA** — there is no formal HIPAA certificate; you self-attest and sign BAAs. But healthcare buyers often want a SOC 2 + HITRUST stack.
- **PCI-DSS** — only if you store/process/transmit card data. Most SaaS apps offload this to Stripe and become "out of scope."
- **FedRAMP** — required for US federal government sales. Costs $500K–$2M+ and 12–24 months to achieve. Don't pursue unless you have a federal customer in hand.

**4. Insurance.** Cyber liability insurance has gotten strict. Underwriters now require:
- MFA on email and admin accounts
- Documented incident response plan
- Endpoint detection on company devices
- Regular backups, tested restores
- Employee security training

You buy this once you have real customer data or once your largest customer requires proof of $1M–$10M cyber coverage in the MSA.

### The SMB vs Enterprise difference, in one paragraph

An SMB SaaS company like **Owner.com** can legitimately operate with: ToS + Privacy Policy + Stripe for payments + reasonable hygiene (MFA, encrypted backups, password manager). Their customers are independent restaurants who would never ask for a SOC 2 report. The legal floor (Privacy Policy, CCPA compliance, no deceptive practices) is met; nothing else is required to sell.

An enterprise SaaS company selling the same product to **Chipotle corporate** would need: ToS + Privacy Policy + DPA + MSA template + SOC 2 Type II + cyber insurance + SSO/SAML + SCIM + audit logs + subprocessor list + incident response plan + annual pentest + vendor risk program + custom redlines. Same product. Same data. Different buyer. ~$200–500K/year more in compliance overhead.

**The decision isn't "what does the law require?" — it's "what customer am I building for?"**

---

## Part 2 — Master Comparison Table

Cells use four values:
- **MUST** — required to operate (legally or to close any deal in that tier)
- **SHOULD** — strongly expected, you'll lose deals or be flagged in procurement without it
- **NICE** — differentiator, sometimes asked about, helpful but not blocking
- **N/A** — does not apply at this tier

### Legal documents

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| Terms of Service (Click-through) | MUST | MUST | MUST | MUST |
| Privacy Policy (published, accurate) | MUST | MUST | MUST | MUST |
| Acceptable Use Policy (AUP) | NICE | SHOULD | MUST | MUST |
| Cookie Notice / Consent Banner | SHOULD* | MUST | MUST | MUST |
| DPA (Data Processing Agreement) template | NICE | SHOULD | MUST | MUST |
| MSA (Master Service Agreement) template | NICE | SHOULD | MUST | MUST |
| Order Form template | NICE | SHOULD | MUST | MUST |
| EULA (if you ship software/SDK) | situational | situational | situational | situational |
| BAA (HIPAA Business Associate Agreement) | N/A | N/A | N/A | MUST (health) |
| Sub-DPA with each subprocessor | N/A | NICE | MUST | MUST |

\* SHOULD if you serve any EU traffic incidentally; otherwise NICE in pure US. Most analytics tools (GA4, Mixpanel) trigger this.

### Cybersecurity controls

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| TLS 1.2+ for all traffic | MUST | MUST | MUST | MUST |
| Encryption at rest (database, backups) | MUST | MUST | MUST | MUST |
| MFA on admin accounts | MUST | MUST | MUST | MUST |
| MFA on customer accounts (offered) | SHOULD | MUST | MUST | MUST |
| SSO / SAML support | N/A | SHOULD | MUST | MUST |
| SCIM auto-provisioning | N/A | NICE | MUST | MUST |
| Role-based access control (RBAC) | NICE | SHOULD | MUST | MUST |
| Audit logs (customer-exportable) | NICE | SHOULD | MUST | MUST |
| Secrets management (no plaintext keys) | MUST | MUST | MUST | MUST |
| Dependency vulnerability scanning | NICE | SHOULD | MUST | MUST |
| Static application security testing (SAST) | NICE | SHOULD | MUST | MUST |
| Annual third-party penetration test | NICE | SHOULD | MUST | MUST |
| Bug bounty program | N/A | NICE | SHOULD | SHOULD |
| WAF (Web Application Firewall) | NICE | SHOULD | MUST | MUST |
| DDoS protection | NICE | SHOULD | MUST | MUST |
| Endpoint detection on company devices | NICE | SHOULD | MUST | MUST |

### Privacy

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| CCPA/CPRA compliance (if any CA users) | MUST | MUST | MUST | MUST |
| Other state law compliance (VA, CO, CT...) | MUST | MUST | MUST | MUST |
| Data Subject Access Request (DSAR) flow | SHOULD | MUST | MUST | MUST |
| Data deletion / right-to-be-forgotten flow | SHOULD | MUST | MUST | MUST |
| Public subprocessor list (with notice on change) | NICE | SHOULD | MUST | MUST |
| Data retention policy (documented + enforced) | SHOULD | MUST | MUST | MUST |
| Data residency options (e.g. EU-only) | N/A | NICE | SHOULD | MUST (sometimes) |
| Privacy by design / DPIAs for new features | NICE | SHOULD | MUST | MUST |
| Children's data handling (COPPA) | situational | situational | situational | MUST if kids |

### Operational / governance

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| Documented Incident Response Plan | SHOULD | MUST | MUST | MUST |
| Tabletop exercise (annual) | NICE | SHOULD | MUST | MUST |
| Vendor / subprocessor risk management program | N/A | SHOULD | MUST | MUST |
| Employee security training (annual) | SHOULD | MUST | MUST | MUST |
| Background checks on employees | NICE | SHOULD | MUST | MUST |
| Documented hiring/offboarding access controls | SHOULD | MUST | MUST | MUST |
| Business continuity / disaster recovery plan | NICE | SHOULD | MUST | MUST |
| Tested restores from backup | NICE | SHOULD | MUST | MUST |
| Change management / code review policy | SHOULD | MUST | MUST | MUST |
| Asset inventory | NICE | SHOULD | MUST | MUST |
| Data classification scheme | N/A | NICE | MUST | MUST |
| Risk register | N/A | NICE | MUST | MUST |

### Commercial / contractual

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| Cyber liability insurance ($1M+ minimum) | NICE | SHOULD | MUST | MUST |
| E&O / Professional liability insurance | NICE | SHOULD | MUST | MUST |
| Documented SLA with uptime credits | NICE | SHOULD | MUST | MUST |
| Custom contract redlines (legal review capacity) | N/A | SHOULD | MUST | MUST |
| Security questionnaire response capacity | NICE | SHOULD | MUST | MUST |
| Trust Center / public security page | NICE | SHOULD | MUST | MUST |

### Certifications

| Item | SMB | Mid-Market | Enterprise | Regulated |
|---|---|---|---|---|
| SOC 2 Type I (one-time snapshot) | NICE | SHOULD | (interim) | (interim) |
| SOC 2 Type II (continuous, annual) | NICE | SHOULD | MUST | MUST |
| ISO 27001 | N/A | NICE | SHOULD | SHOULD |
| ISO 27701 (privacy extension) | N/A | N/A | NICE | NICE |
| HITRUST CSF | N/A | N/A | NICE | MUST (some health) |
| PCI-DSS (if you handle cards directly) | depends | depends | depends | MUST |
| HIPAA self-attestation + BAA | N/A | N/A | N/A | MUST (health) |
| FedRAMP Low/Moderate/High | N/A | N/A | situational | MUST (US gov) |
| StateRAMP | N/A | N/A | situational | situational |
| CMMC (defense contractors) | N/A | N/A | N/A | MUST (DoD) |

---

## Part 3 — Category Deep-Dives

### 1. Legal Documents

**What they are.** The text-based agreements that govern your relationship with users and customers — what they can do, what you can do with their data, who's liable when things go wrong.

**Why they exist.** Some are statutorily required (Privacy Policy), some are contract-of-adhesion liability shields (ToS, EULA), and some are concessions to enterprise procurement (DPA, MSA).

**Minimum viable (SMB launch):**
- **ToS** — generated from Termly / Iubenda / a $500 lawyer review. Limit your liability to fees paid in the last 12 months, disclaim warranties, name a venue (Delaware or your home state), require arbitration.
- **Privacy Policy** — must be accurate. Lists every category of data collected, every purpose, every third party it's shared with, retention periods, user rights (CCPA-compliant). Update when you add a vendor or feature.

**Enterprise-grade additions:**
- **DPA** — your standard data processing agreement. Mirrors GDPR Article 28 + CCPA service-provider language even for US-only. Includes flow-down obligations to subprocessors, breach notification window (24–72 hours), audit rights.
- **MSA** — your standard master agreement that you actually want customers to sign. Most enterprises will redline it heavily. Have a "fallback positions" doc for your legal team.
- **AUP** — explicit prohibitions (no scraping, no resale, no illegal content, no using your service to violate others' rights).
- **Trust Center** — a single public URL that hosts your Privacy Policy, ToS, DPA, subprocessor list, SOC 2 report (gated), security overview, status page.

**Gotchas.**
- Don't copy ToS from another company verbatim — you'll inherit liability and miss your specifics.
- Your Privacy Policy must match what your code actually does. Mismatch = FTC §5 violation.
- "Sale of personal information" under CCPA includes some data sharing arrangements you might not think of as sales (e.g. cross-context behavioral advertising). Default to including a "Do Not Sell or Share My Information" link.

### 2. Cybersecurity Controls

**What they are.** Technical and procedural mechanisms that protect data — encryption, authentication, access control, monitoring, vulnerability management.

**Why they exist.** Some controls are required by law (CCPA: "reasonable security"), most are required by contract (customer security exhibits, cyber insurance underwriting), all are required by SOC 2 if you pursue it.

**Minimum viable (SMB launch):**
- TLS 1.2+ everywhere (Vercel/Cloudflare give you this for free)
- Encryption at rest on database + backups (Neon, Supabase, RDS all default to this)
- MFA mandatory on all admin/employee accounts (use a password manager: 1Password, Bitwarden)
- No plaintext secrets in code or shared in Slack — use environment variables, Vercel/Doppler/1Password Secrets Automation
- A password reset flow that doesn't leak user existence
- Reasonable session management (HttpOnly cookies, secure flag, sensible TTL)

**Enterprise-grade additions:**
- **SSO/SAML** — usually via Auth0, WorkOS, or Stytch. Customers want to provision via their Okta/Azure AD.
- **SCIM** — automated user provisioning/deprovisioning from the customer's IdP.
- **Customer-side audit logs** — exportable record of every action a customer's users took.
- **Penetration test** — annual, by a credentialed firm (Bishop Fox, NCC Group, smaller boutiques like Cobalt or HackerOne pentest-as-a-service).
- **Dependency scanning** (Snyk, Dependabot, GitHub Advanced Security) + SAST (Semgrep, CodeQL).
- **WAF + DDoS** (Cloudflare, AWS WAF + Shield).
- **Endpoint detection** on employee devices (Crowdstrike, SentinelOne, or budget: Apple's built-in + JAMF).

**Gotchas.**
- SSO sold separately is a tax customers hate but tolerate. SSO behind a paywall is industry standard for SaaS.
- "Bring Your Own Encryption Key" (BYOK) is asked about by ~10% of enterprise buyers. Don't build it preemptively.
- "Reasonable security" under CCPA is the floor — courts have read this as something like the CIS Critical Security Controls.

### 3. Security Certifications

**What they are.** Independent third-party attestation that you operate certain controls. They are *not* a guarantee of security — they're a signal that an auditor checked your homework once a year.

**Why they exist.** Procurement teams cannot evaluate every vendor's security from scratch. Certifications let them filter and standardize. They are commercial gates, not legal requirements.

**SOC 2 Type II — the US enterprise baseline.**
- A report (not a certificate) issued by a CPA firm covering 5 "trust services criteria": Security (mandatory), Availability, Confidentiality, Processing Integrity, Privacy (optional).
- "Type I" = snapshot at a moment. "Type II" = controls operated effectively over a period (usually 3, 6, or 12 months).
- Cost: $15K–$60K for the audit itself; $20K–$100K of internal time + tooling (Drata, Vanta, Secureframe) to prepare.
- Timeline: 3–6 months to get ready + 3–12 months of observation period before Type II is issued. Realistically a 9–18 month project from zero.
- **When to pursue:** when an enterprise prospect tells you they need it. Not before.

**ISO 27001.**
- International standard. More common in EU sales and at scale.
- Higher rigor than SOC 2 in some ways (formal ISMS, mandatory risk treatment), less in others.
- Often pursued after SOC 2 once international sales pick up.

**HIPAA.**
- Not a certification — you self-attest, sign BAAs with covered entities, and operate the Security Rule + Privacy Rule + Breach Notification Rule controls.
- BAAs are mandatory. No BAA = you can't legally accept PHI.
- HITRUST CSF is the private-sector "certification" that demonstrates HIPAA + more.

**PCI-DSS.**
- Required only if you store, process, or transmit cardholder data.
- 4 merchant levels by transaction volume. Most SaaS uses Stripe/Adyen and qualifies as "SAQ A" (lightest tier) by never touching card numbers directly.
- **The trick:** keep cards out of your systems entirely. Stripe Elements, Stripe Checkout, or a tokenized card-on-file flow keeps you at SAQ A indefinitely.

**FedRAMP.**
- Required for US federal sales. Three levels: Low, Moderate, High.
- Costs $500K–$2M+ and 12–24 months minimum.
- **Don't pursue unless:** you have a named federal customer ready to sponsor you or you're an established enterprise vendor expanding into gov.

**Gotchas.**
- A SOC 2 report is gated under NDA — when you publish "We have SOC 2," buyers ask for the report. Have it ready.
- Compliance automation tools (Drata/Vanta/Secureframe) are useful but they don't replace the auditor and they don't replace actually operating the controls.
- "SOC 2 in progress" is a real answer that buys you 6–9 months in mid-market deals.

### 4. Privacy Regulations

**What they are.** Laws that govern how personal information is collected, used, shared, retained, and deleted.

**Why they exist.** Originally consumer protection; increasingly used as a competitive weapon and a revenue stream for state attorneys general.

**The US landscape (as of 2026).**
- **Federal:** No comprehensive privacy law yet. Sectoral laws apply (HIPAA, GLBA, COPPA, FERPA, CAN-SPAM, TCPA, VPPA). FTC §5 covers everyone.
- **California:** CCPA + CPRA. The most aggressive. Applies if you have CA residents *and* meet one of: >$25M revenue, buy/sell/share PI of 100K+ Californians, or 50%+ revenue from selling PI.
- **~20 other states with comprehensive laws** (in force or coming in 2026): VA, CO, CT, UT, TX, FL, OR, MT, IA, IN, TN, DE, NH, NJ, MN, MD, RI, KY, plus more pending.
- **Practical implication:** if you comply with California's CCPA/CPRA at scale, you're 90% of the way to every other state. Build for California, layer the deltas.

**Minimum viable (SMB launch in US):**
- Published Privacy Policy that accurately reflects practice.
- "Do Not Sell or Share My Personal Information" link in your footer if you do any cross-context behavioral advertising (most analytics + ad pixels trigger this).
- Honor browser-based universal opt-out signals (Global Privacy Control / GPC).
- A documented (even if informal) way to handle deletion requests.
- Don't collect data you don't need (data minimization is both legally smart and operationally cheap).

**Enterprise-grade additions:**
- **In-product DSAR flow** — customer-facing tools to export and delete data on demand.
- **Subprocessor inventory** maintained as a living document, published publicly, with email notification on changes.
- **Data Processing Inventory / Record of Processing Activities (RoPA)** — internal map of what data you have, where, why, and for how long.
- **DPIAs** (Data Protection Impact Assessments) for new features that involve sensitive data or automated decisioning.
- **Vendor privacy review** before signing with any new processor.

**Gotchas.**
- "Anonymized" is a legal term of art. Most "anonymized" data is actually pseudonymized and still triggers privacy law.
- AI features are now privacy-regulated. Training on customer data without explicit, granular consent is increasingly risky and may already be illegal under some state laws.
- The COPPA tripwire is harsh — if you "know or reasonably should know" you have under-13 users, you're subject to it. Don't market to kids.

### 5. Operational / Governance

**What they are.** The processes and documented practices that surround your technical controls — how you respond to incidents, manage vendors, train employees, handle access.

**Why they exist.** Most security failures are people/process failures, not technical ones. Auditors and enterprise buyers know this, so they ask about your *program*, not just your tools.

**Minimum viable (SMB launch):**
- A one-page **Incident Response Plan** stored somewhere findable. Who calls who, when do you notify customers, when do you notify a lawyer.
- **Offboarding checklist** — when an employee leaves, what gets revoked.
- **Backups** that you've actually tested restoring from at least once.
- Don't share admin credentials. Don't email passwords. Don't store API keys in Notion.

**Enterprise-grade additions:**
- **Documented programs** for: vendor risk management, change management, access management, asset management, vulnerability management, business continuity, disaster recovery, employee training, secure SDLC.
- **Annual tabletop exercises** — simulate an incident and walk through the response.
- **Background checks** on new hires (Checkr is the SaaS default).
- **Risk register** — a maintained list of identified risks with owners, likelihoods, impacts, and mitigations.
- **Asset inventory** — what hardware, software, and data you have, where, and who's responsible.

**Gotchas.**
- The single most common SOC 2 finding is "you have the policy but you're not actually following it." Don't write policies you won't enforce.
- "Vendor risk management" doesn't mean a 40-page assessment for every Slack subscription. Risk-tier your vendors (high/medium/low) and only do the deep dive for the high-risk ones.
- Employees clicking phishing links is your #1 incident vector. Knowbe4 / Hoxhunt training pays for itself.

### 6. Commercial / Contractual

**What they are.** The contracts and insurance products that govern the commercial relationship and allocate risk.

**Why they exist.** Enterprise procurement needs to be able to point at a contract clause when something goes wrong. You need insurance because liability claims can exceed your company's net worth.

**Minimum viable (SMB launch):**
- A standard click-through ToS that disclaims everything possible.
- General liability insurance (most likely a CGL policy from your business package).
- An "uptime promise" that's vague enough not to commit you to anything specific.

**Enterprise-grade additions:**
- **Cyber liability insurance:** $1M–$10M+ in coverage. Premiums $5K–$30K/year for SMB-stage companies. Underwriters will require MFA, EDR, backups, training as preconditions.
- **E&O / Tech E&O insurance:** covers professional negligence claims related to your product.
- **Written SLA with credits:** typical commitments are 99.9% (8.76 hours of downtime/year) or 99.95%. Credits are usually 10–25% of monthly fees, capped at the monthly fee.
- **MSA with negotiable redlines:** standard enterprise asks include uncapped liability for data breaches, indemnification for IP claims, mutual indemnification for confidentiality.
- **Trust Center page** — single URL hosting SOC 2 (gated), DPA, subprocessor list, status page, security overview, vulnerability disclosure policy.

**Gotchas.**
- Liability caps. Default to "fees paid in the last 12 months" with carve-outs for indemnification, confidentiality, and gross negligence. Enterprises will ask to remove the cap for data breaches.
- Indemnification is asymmetric in standard MSAs — you indemnify them, they don't indemnify you. Negotiate mutual.
- Your SLA credits are a refund of the customer's money — they're not a budget for actual damages. Don't let an SLA become an implicit insurance policy.

---

## Part 4 — Website OS: Applied Recommendations

Based on the project context in `CLAUDE.md`:

**Stack:** Next.js 15 on Vercel, Neon Postgres, Inngest, Playwright, Anthropic + Gemini APIs, Google Maps/Places, Yelp, Facebook Graph, PageSpeed Insights.

**Data handled:**
- Public business data (Google Places, Yelp)
- Scraped website content from third-party sites (via Playwright)
- AI prompts and outputs (sent to Anthropic + Gemini)
- Customer account data (presumably; for users who sign up)
- Generated reports and rebuild artifacts

**Customer tier (current):** SMB — local businesses.

### Minimum viable launch bar (what you actually need)

1. **Published Privacy Policy** that accurately discloses every third-party API you send data to: Google, Anthropic, Gemini, Yelp, Facebook, PageSpeed, Inngest, Neon, Vercel.
2. **ToS** with: liability cap (fees in last 12 months), disclaimer of warranties on rebuilt sites and AI outputs, prohibition on using your service to defame or harass businesses they don't own, venue/arbitration clause.
3. **Acceptable Use Policy** — explicit clause that customers must own or have authority over any business they ask you to rebuild or monitor (otherwise they're using you to harass competitors).
4. **CCPA compliance:** "Do Not Sell or Share My Personal Information" link, deletion request handling (even if manually via support email), accurate Privacy Policy.
5. **Reasonable security hygiene:** MFA on all admin accounts, secrets in Vercel env vars (not in code), Neon's default encryption at rest, no plaintext customer data in logs.
6. **Subprocessor disclosure:** even as an SMB tool, having a public subprocessors list is cheap and demonstrates good faith. List every API you call.
7. **AI disclosure:** explicit notice in Privacy Policy that prompts may be sent to Anthropic and Gemini, and what their data retention policies are. Anthropic's API does not train on customer data by default; Gemini's does on some tiers — check the specific endpoint.
8. **Scraping ethics:** robots.txt respect in Playwright crawls, identifiable user agent, rate limiting. This is reputational, not legal, but you don't want to be sued by a competitor whose site you scraped aggressively.

### First three things to add if you want to move upmarket

If Website OS ever pivots to selling to multi-location chains or marketing agencies serving enterprise:

1. **SOC 2 Type I → Type II.** Pick Vanta or Drata, allocate a $30–50K budget, plan for 9 months. This is the single biggest unlock for upmarket sales.
2. **DPA + MSA templates.** Have a lawyer draft them; use them as your "starting position" in any deal that needs custom contracting.
3. **SSO/SAML via WorkOS.** ~$125/month, unlocks the question "Can we use Okta?" — which kills SMB-tier procurement immediately.

### Subprocessor list (draft)

To publish at `/legal/subprocessors` once you have a Privacy Policy:

| Subprocessor | Purpose | Data category | Location |
|---|---|---|---|
| Vercel | Hosting, edge functions | All product data in transit | US (Global edge) |
| Neon | Primary database | Customer accounts, scan results | US |
| Inngest | Background job orchestration | Scan job metadata | US |
| Anthropic | AI analysis | Scan content, business data | US |
| Google (Gemini) | AI analysis | Scan content, business data | US |
| Google (Places/Maps) | Business discovery, maps | Business names, addresses | US |
| Yelp | Reviews, ratings | Business identifiers | US |
| Facebook (Meta) | Page metadata | Business page IDs | US |
| Google (PageSpeed) | Performance analysis | Target URLs | US |

(Add Stripe, Resend, your email provider, your analytics, your error tracking once those are wired up.)

### What to ignore (for now)

- HIPAA, PCI-DSS, FedRAMP, ISO 27001, HITRUST, CMMC — none of these apply to your current customer or data.
- Cyber liability insurance — get it once you have paying customers, but $1M is fine until you sign a contract that requires more.
- Pen testing — wait until you have meaningful production traffic and customer data. A pentest of an empty product is a waste of money.
- Trust Center — wait until you have a SOC 2 report to put behind it. A Trust Center with only a Privacy Policy looks worse than no Trust Center.

---

## Appendix — Quick Reference

### "What do I do if a customer asks for X?"

| They ask for... | If you don't have it, say... |
|---|---|
| SOC 2 report | "We don't have SOC 2 yet. Here's our security overview and a list of the controls we operate." |
| Signed DPA | Send your standard DPA template. Negotiate redlines. |
| Custom MSA | Default to your MSA. If forced to use theirs, get legal review on liability, indemnification, and data ownership. |
| Pen test results | "We have not done a third-party pen test. We do [X internal practices]." |
| Cyber insurance certificate | If you have a policy, request a Certificate of Insurance from your broker — it's a free 1-day request. |
| HIPAA BAA | Decline unless you're actually built for healthcare. Refusing a BAA is a legitimate answer. |
| ISO 27001 cert | "We are not ISO certified. We are [SOC 2 stage] / preparing for ISO in [year]." |
| List of subprocessors | Send your subprocessors page. |

### When to invest in what (rough order)

1. ToS + Privacy Policy (Day 0, before any user)
2. AUP + Subprocessor list (Day 0)
3. MFA + secrets hygiene + basic security practices (Day 0)
4. CCPA "Do Not Sell" + DSAR handling (before California user #1)
5. Cyber liability insurance (before first paying enterprise customer or first customer with sensitive data)
6. Standard DPA template (before first mid-market sales conversation)
7. SOC 2 Type I (when a deal is contingent on it)
8. SSO/SAML (when a deal is contingent on it)
9. SOC 2 Type II (3–12 months after Type I)
10. Annual pen test (year 2+)
11. ISO 27001 (international expansion)
12. HIPAA / PCI / FedRAMP (only if you've decided to enter those markets)

### Cost ballparks (annual, US, 2026)

| Item | Range |
|---|---|
| ToS + Privacy Policy (template + legal review) | $1K – $5K |
| MSA + DPA templates (legal drafting) | $5K – $15K |
| Compliance platform (Vanta, Drata, Secureframe) | $10K – $40K |
| SOC 2 Type II audit | $15K – $60K |
| Annual penetration test | $10K – $50K |
| Cyber liability insurance ($1M – $5M coverage) | $5K – $30K |
| SSO infrastructure (WorkOS, Auth0, etc.) | $1K – $20K |
| Employee security training | $1K – $10K |
| Background checks (per hire) | $30 – $150 each |
| ISO 27001 (initial + surveillance) | $30K – $80K |
| FedRAMP Moderate (initial) | $500K – $2M |

**Realistic SMB SaaS annual compliance spend:** $5K–$20K (legal templates + insurance + basic tooling).

**Realistic enterprise SaaS annual compliance spend:** $100K–$400K (SOC 2 + pen test + insurance + platform + training + legal + part of one FTE's time).

---

*This document is a strategic reference, not legal advice. Engage qualified counsel for actual contract drafting, regulatory interpretation, and incident response.*
