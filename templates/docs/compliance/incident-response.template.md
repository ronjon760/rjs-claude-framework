# Incident Response Plan

**Last reviewed:** {{EFFECTIVE_DATE}}
**Owner:** {{IR_OWNER}}

A short, runbook-style plan for what happens when {{COMPANY_NAME}} detects a security incident. Optimized for a small team — when you grow past ~10 employees, expand this into a formal IR program.

---

## What counts as an "incident"?

Anything that affects the **confidentiality**, **integrity**, or **availability** of customer data or the Service. Examples:

- Unauthorized access to production systems or customer data
- Lost or stolen device with access to production credentials
- Suspected phishing of an employee that may have leaked credentials
- A vulnerability in our code or a dependency that may have been exploited
- A data leak (e.g. a misconfigured S3 bucket, an exposed log file)
- Prolonged unplanned downtime (>2 hours)
- A subprocessor reporting a breach that affects our customers' data

If you're not sure whether it qualifies — assume it does and trigger the plan. Easier to stand down than to under-react.

---

## Severity levels

| Level | Definition | Response time |
|---|---|---|
| **SEV-1** | Confirmed unauthorized access to customer data, OR full Service outage | Immediate — drop everything |
| **SEV-2** | Suspected unauthorized access, OR partial Service degradation affecting most customers | Within 1 hour |
| **SEV-3** | Internal anomaly with no confirmed customer impact (e.g. failed phishing attempt) | Within 24 hours |

---

## The plan (in order)

### 1. Detect & Report (anyone)

If you observe something:
- **Don't try to fix it alone.** Page the on-call.
- **Don't delete logs or evidence.** Preservation matters.
- **Write down what you saw, when, and what you did.** This becomes the incident timeline.

Channel: {{INCIDENT_CHANNEL}}
<!-- e.g. #incident-response on Slack, or text {{IR_OWNER_PHONE}} -->

### 2. Triage (Incident Commander)

The Incident Commander (initially {{IR_OWNER}}; rotating as the team grows) takes ownership and:

- Assigns a severity (SEV-1/2/3)
- Opens an incident document at `docs/incidents/YYYY-MM-DD-<short-name>.md`
- Decides who's needed: engineer, communications lead, legal contact ({{LEGAL_CONTACT}})
- Sets a check-in cadence (every 30 min for SEV-1, hourly for SEV-2)

### 3. Contain

Goal: stop the bleeding before investigating.

- Revoke or rotate compromised credentials immediately
- Disable suspect accounts or sessions
- If suspected code exploit: roll back, disable the feature, or take the Service down rather than leak more data
- Take forensic snapshots (database state, logs) before changing anything if feasible

### 4. Investigate

- Reconstruct the timeline from logs (Vercel/cloud logs, audit logs, application logs)
- Identify scope: what data was accessed, by whom, when, from where
- Identify root cause: how did this happen?
- Identify whether other systems are affected

Keep the incident document updated as new facts emerge.

### 5. Notify

**Internal:** Update all stakeholders at the agreed cadence.

**Customers:** If customer data is affected, customers are notified within **{{CUSTOMER_NOTIFICATION_HOURS}} hours** of confirmation. The notice should include:

- What happened
- What data was affected
- What we've done
- What customers should do (rotate passwords, watch for phishing, etc.)
- A point of contact for questions

Template draft is in `docs/incidents/_templates/customer-notification.md` (create when needed).

**Legal:** {{LEGAL_CONTACT}} is looped in for any SEV-1 or SEV-2 to advise on statutory notifications (state breach notification laws, EU GDPR Article 33 if applicable).

**Regulators:** Depending on the data and the state:
- California — within 30 days under most circumstances
- HHS for HIPAA — within 60 days (only if you handle PHI)
- State attorneys general — varies by state

**Subprocessors / customers if we are the cause of their incident:** If our service is the source of an incident affecting our customers, the customer notification above is the path.

### 6. Recover

- Confirm containment is complete
- Restore Service from clean backups if needed
- Patch the root cause (not just the symptom)
- Run a verification check that the vulnerability is closed

### 7. Post-Mortem

Within 7 days of containment:

- Write a blameless post-mortem in `docs/incidents/YYYY-MM-DD-<name>/postmortem.md`
- Sections: Summary, Timeline, Root Cause, Impact, What Went Well, What Didn't, Action Items
- Identify 1–3 action items that would prevent recurrence
- Track action items to completion

Share the post-mortem internally. Share externally if customers are owed transparency.

---

## Key contacts

| Role | Person | Contact |
|---|---|---|
| Incident Commander (primary) | {{IR_OWNER}} | {{IR_OWNER_CONTACT}} |
| Engineering escalation | {{ENG_LEAD}} | {{ENG_LEAD_CONTACT}} |
| Legal contact | {{LEGAL_CONTACT}} | {{LEGAL_CONTACT_INFO}} |
| Cyber insurance carrier | {{INSURANCE_CARRIER}} | {{INSURANCE_PHONE}} |

Keep this section current. Out-of-date contact info during an incident is a real failure mode.

---

## Detection sources

What we actively monitor for incident signals:

- Production error rates ({{ERROR_MONITORING_TOOL}})
- Authentication anomalies (failed logins, geo anomalies)
- Cloud provider security alerts (Vercel, Neon, Cloudflare, etc.)
- Subprocessor security advisories (email subscriptions)
- Customer reports to {{SECURITY_EMAIL}}
- Vulnerability disclosure submissions

---

## Annual tabletop

Once a year, run a one-hour tabletop exercise:

- Pick a realistic scenario (e.g. "an engineer's laptop was stolen on a flight")
- Walk through this plan as a team
- Note what was unclear or out of date
- Update this document

---

<!--
PLACEHOLDERS TO FILL IN:

{{EFFECTIVE_DATE}}              — Today's date
{{COMPANY_NAME}}                — Your legal entity
{{IR_OWNER}}                    — Person responsible for incident response (usually the technical founder)
{{IR_OWNER_CONTACT}}            — How to reach them fast (cell, Signal)
{{IR_OWNER_PHONE}}              — Phone number for paging
{{INCIDENT_CHANNEL}}            — Slack channel or text thread
{{ENG_LEAD}}                    — Engineering escalation
{{ENG_LEAD_CONTACT}}            — Phone/Signal
{{LEGAL_CONTACT}}               — Outside counsel name
{{LEGAL_CONTACT_INFO}}          — Counsel's emergency contact
{{INSURANCE_CARRIER}}           — Cyber insurance company (if you have one)
{{INSURANCE_PHONE}}             — Their incident hotline
{{CUSTOMER_NOTIFICATION_HOURS}} — Standard: 72 (often 24 in enterprise contracts)
{{ERROR_MONITORING_TOOL}}       — Sentry, Datadog, etc.
{{SECURITY_EMAIL}}              — security@yourcompany.com

NOT LEGAL ADVICE. Specific notification timelines vary by jurisdiction and the type of data involved. Have counsel review.
-->
