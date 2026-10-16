---
paths:
  - "**/components/**"
---

# Components

- One component per file, PascalCase file names (`OrderForm.tsx`).
- Components render UI. They get data from props or hooks, and don't call `fetch()` or hold business rules.
- Shared UI primitives live in `components/ui/`. Feature-specific UI lives with its feature.
- Reuse what exists (check `components/ui/` and the design system in `design-system/MASTER.md`) before making a new component.
- Every interactive element needs an accessible name, keyboard support, and visible focus.
