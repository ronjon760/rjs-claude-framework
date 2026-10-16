---
paths:
  - "**/features/**"
---

# Feature folders

- Each feature is self-contained: `components/`, `hooks/`, `types.ts`, `index.ts` (its public API), and `QUICK_REF.md`.
- Read the feature's `QUICK_REF.md` before changing it, and update it (user journey, wiring, known gaps) when you finish.
- Features don't import from each other. Code two features need moves to `lib/`.
- When a file passes ~200 lines, extract `services/` (API calls), `handlers/`, or `utils/` inside the feature.
- New features start with `/rjs:feature <name>`; refresh docs with `/rjs:quickref <name>`.
