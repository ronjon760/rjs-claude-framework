---
paths:
  - "app/**"
  - "src/app/**"
---

# Next.js app/ folder

- A folder with `page.tsx` is a route; `layout.tsx` wraps its children; `loading.tsx` and `error.tsx` give loading and error states. Add both for any route that fetches data.
- Pages compose components. Data loading and business logic live in hooks, services, or server actions — keep `page.tsx` under ~200 lines.
- API routes (`api/**/route.ts`) are thin: parse and validate input, call a service, return a response.
- Prefer server components. Add `"use client"` only when the component needs state, effects, or event handlers.
- Validate every request body and query parameter (for example with zod) before using it.
