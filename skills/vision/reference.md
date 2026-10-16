# Vision reference tables

Starting points for the tech stack and phase recommendations. Adapt them to the user's needs, existing code, and stated preferences.

### Project Type to Tech Stack Recommendations

Use these as starting points — adapt based on the user's specific needs, existing code, and stated preferences.

| Project Type | Framework | Database | Key Libraries | Hosting |
|---|---|---|---|---|
| Full-stack web app (SaaS) | Next.js 15 + TypeScript + Tailwind | Neon Postgres or Supabase | Prisma, Inngest, Resend, shadcn/ui | Vercel |
| Marketing / landing page | Next.js (static export) or Astro | None or lightweight CMS | Motion v12, shadcn/ui | Vercel / Netlify |
| API-first service | Node.js (Express/Fastify) or Python (FastAPI) | Postgres or MongoDB | Zod, Drizzle or SQLAlchemy | Railway / Fly.io |
| Mobile app | React Native (Expo) + TypeScript | Supabase | React Navigation, Reanimated | EAS Build |
| Static site / portfolio | HTML/CSS/JS or Astro | None | Vanilla JS or Alpine.js | Netlify / GitHub Pages |
| Dashboard / admin panel | Next.js + TypeScript + Tailwind | Postgres | Prisma, Recharts/Tremor, shadcn/ui | Vercel |
| E-commerce | Next.js + TypeScript | Postgres + Stripe | Prisma, Stripe SDK, shadcn/ui | Vercel |
| AI/ML tool | Python (FastAPI) + React frontend | Postgres | Anthropic SDK, LangChain | Railway + Vercel |
| CLI tool | Node.js (TypeScript) or Python | SQLite (if needed) | Commander.js or Click, Chalk or Rich | npm / PyPI |
| Real-time app (chat, collab) | Next.js + TypeScript | Supabase (realtime) or Redis | Supabase Realtime or Socket.io | Vercel + Supabase |

### Complexity Heuristic

Use this to calibrate the MVP scope and tech recommendations:

| Signal | Recommendation |
|---|---|
| Single page, no login | Static HTML or single Next.js page — keep it minimal |
| Multi-page, no auth | Next.js static pages or Astro — no database needed |
| Auth required | Add Supabase Auth, NextAuth, or Clerk |
| Background processing needed | Add Inngest (MVP) or BullMQ + Redis (scale) |
| Payments | Add Stripe — never build custom payment handling |
| External APIs | Factor in API costs; add rate limiting and caching |
| Real-time updates needed | Supabase Realtime, SSE, or WebSockets |
| Mobile + web | React Native (Expo) for mobile, Next.js for web, shared API |

### Phase Arc Templates

Typical phase structures by project type — use as starting points:

**SaaS / Tool:**
- Phase 1: Core tool (the thing users come for)
- Phase 2: Account system + saved data
- Phase 3: Team features + billing

**Marketplace / Platform:**
- Phase 1: One side of the marketplace (supply or demand)
- Phase 2: The other side + matching
- Phase 3: Payments + trust/safety

**Content / Media:**
- Phase 1: Content delivery + discovery
- Phase 2: User accounts + personalization
- Phase 3: Creator tools + monetization

**Internal Tool / Dashboard:**
- Phase 1: Data display + core workflows
- Phase 2: Automation + alerts
- Phase 3: Reporting + integrations
