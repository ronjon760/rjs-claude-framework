# Compliance, in Plain English

*A one-page primer for non-technical readers. For depth, see `compliance-landscape.md`.*

---

## What is "compliance," really?

Compliance is **a set of rules other people make you follow if you want to do business with them.** That's it.

Three groups make those rules:

1. **Governments** make **laws.** If you break them, you get fined or sued. *(Example: a Privacy Policy is required by California law. If you don't publish one, you're breaking the law.)*

2. **Customers** make **contracts.** If you don't agree to their rules, they don't buy from you. *(Example: a Fortune 500 buyer says "we won't sign unless you have a SOC 2 report." That's not a law. It's their purchasing standard.)*

3. **Insurance companies** make **underwriting rules.** If you don't follow them, you can't get cyber insurance. *(Example: most cyber insurers now require two-factor authentication on all employee accounts.)*

People conflate all three and call it "compliance," but they're very different. **Only the first one is legally required.** The other two are commercial — you only need them if you want to sell to certain customers or buy certain insurance.

---

## The most important question

> **"Who is our biggest customer going to be?"**

That answer decides 90% of what you actually need.

| If you sell to... | Your compliance bar is... |
|---|---|
| Small businesses (local shops, restaurants, independent operators) | **Low.** Privacy Policy, Terms of Service, basic security hygiene, and don't lie to anyone. Done. |
| Mid-sized companies (100–1,000 employees) | **Medium.** Add a Data Processing Agreement, a security questionnaire response, and ideally start the SOC 2 process. |
| Big enterprises (Fortune 1000) | **High.** Add SOC 2 Type II, cyber insurance, single sign-on, formal incident response plan, custom contracts. ~$200–400K/year of overhead. |
| Healthcare, finance, government, or schools | **Very high.** All of the above *plus* industry-specific rules (HIPAA, PCI, FedRAMP, FERPA). Often a year or more of work and $500K+. |

---

## The Big Lie founders tell themselves

> "We need SOC 2 before we can launch."

**Usually false.** No law requires SOC 2. It's only required if you want to sell to enterprises who demand it. If you're targeting small businesses, you don't need it. Launching with a Privacy Policy, Terms, and reasonable security practices is enough.

The opposite mistake is also common:

> "We're small, so we don't need any of this."

**Also false.** Every product needs a Privacy Policy and Terms of Service from day one. Every product needs to honor California's privacy law if it has any users in California. Every product needs basic security (no plaintext passwords, MFA on admin accounts, encrypted backups).

The truth is: **there's a real floor everyone has to meet, and then there's a long ladder of things you only do if your customers demand them.**

---

## What this costs

| Stage | Annual cost | What you're paying for |
|---|---|---|
| Launching a small-business SaaS | **$5K–$20K** | Legal templates, basic insurance, hygiene tools |
| Selling to mid-market | **$30K–$80K** | DPA, compliance platform, basic SOC 2 prep |
| Selling to enterprise | **$100K–$400K** | SOC 2 audit, pen tests, cyber insurance, legal capacity |
| Selling to regulated industries (healthcare, gov, finance) | **$300K–$1M+** | Industry-specific certifications on top of everything |

---

## The three things to do this year (if launching an SMB SaaS)

1. **Get a real Privacy Policy and Terms of Service drafted by a lawyer** (or a high-quality service like Termly), and make sure your Privacy Policy actually matches what your product does. *Cost: $1K–$5K.*

2. **Turn on two-factor authentication** on every admin account, every cloud service, every email. *Cost: free.*

3. **Make a one-page list of every outside service you send data to** (every API, every vendor) and publish it on your website. *Cost: an hour of someone's time.*

That gets you legally compliant in the US and meets the bar most SMB customers care about.

---

## What to ignore until later

- **SOC 2** — wait until a customer specifically requires it.
- **Cyber insurance over $1M** — wait until a contract requires it.
- **Penetration testing** — wait until you have real production data worth testing.
- **HIPAA, PCI-DSS, FedRAMP** — only if you've decided to enter those markets.
- **ISO 27001** — only if you're selling internationally.

Doing these too early wastes money. Doing them too late kills enterprise deals. The right time is **when a real customer asks**.

---

## The one paragraph version

You need a Privacy Policy and Terms of Service from day one — those are legally required. Almost everything else people call "compliance" is just a list of things enterprise customers demand before they'll sign a contract. If you sell to small businesses, you can skip most of it. If you sell to big companies, you'll need SOC 2, cyber insurance, and formal contracts. The cost difference between the two paths is roughly $400K/year. **Choose your customer first, then choose your compliance.**

---

*See `compliance-landscape.md` for the full landscape and `compliance-questionnaire-cheatsheet.md` for the actual questions enterprise buyers will ask.*
