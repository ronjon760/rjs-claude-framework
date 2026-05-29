# Compliance Starter Kit

This folder contains the legal, privacy, and security documents every SaaS project needs from day one — sized for **small-business SaaS** (the framework's default target).

## What's here

| File | What it is | When to update |
|---|---|---|
| `compliance-landscape.md` | The mental model — what compliance actually means, what's legally required vs commercially required | Read once; refer back when a customer asks for something new |
| `privacy-policy.template.md` | Fill-in-the-blank Privacy Policy (CCPA/CPRA-aligned) | Whenever you add a new vendor, data category, or feature that collects data |
| `terms-of-service.template.md` | Fill-in-the-blank Terms of Service | Rarely — when your product or liability model materially changes |
| `acceptable-use-policy.template.md` | Short AUP — what users can't do with the product | When new abuse vectors emerge |
| `subprocessors.template.md` | Living list of every external service your product calls | Every time you add or remove a third-party API |
| `incident-response.template.md` | One-page incident response plan | After any incident; quarterly review |

## How to use this kit (first week of launch)

1. **Read `compliance-landscape.md`** (15 min) — it tells you what you do and don't need at your stage.
2. **Run `/compliance`** — interactive walkthrough that fills in the templates with your specifics.
3. **Get a lawyer's eyes on the filled-in Privacy Policy and ToS** before they go live. Templates are a starting point, not a substitute for counsel.
4. **Publish the Privacy Policy and ToS** at public URLs (typically `/privacy` and `/terms`).
5. **Keep `subprocessors.md` accurate** — every time you wire up a new API key, add the vendor here.

## What's NOT here (and why)

- DPA (Data Processing Agreement) — only needed when you sell to mid-market or enterprise customers
- MSA (Master Service Agreement) — only when negotiating custom contracts with enterprise buyers
- BAA (Business Associate Agreement) — only when handling HIPAA-protected health information
- SOC 2 / ISO 27001 prep checklists — only when actively pursuing certification
- HIPAA / PCI / FedRAMP checklists — only when entering those markets

If you ever need these, they fit into a "tier-2" doc set. The `compliance-landscape.md` doc explains when each becomes relevant.

## The single most important rule

**Your Privacy Policy must accurately describe what your product actually does.** Inaccurate Privacy Policies are an FTC §5 violation ("deceptive practices"). When you add a new vendor or data flow, the Privacy Policy and the subprocessor list need to be updated *before* the change ships.

The `/audit` command (when extended) will flag drift between your code and your compliance docs. Until then, this is a manual habit worth building.

## When to upgrade

If you start selling to mid-market or enterprise customers, you'll need to add:
- A DPA template
- An MSA template
- A pen test
- SSO/SAML support
- Likely a SOC 2 Type II audit

That transition is roughly $100–400K/year in additional overhead. The `compliance-landscape.md` doc walks through it.

For now, the goal is the SMB-tier floor: legal documents that exist, are accurate, and accurately describe a small business that is not yet under enterprise-tier scrutiny.
