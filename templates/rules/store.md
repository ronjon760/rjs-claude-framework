---
paths:
  - "**/store/**"
  - "**/stores/**"
---

# State stores

- Stores hold state and the actions that change it — no rendering and no network calls inside them.
- Fields shared by several stores belong in one shared base store, added once.
- Static data (lists, options, constants) belongs in `lib/constants`, not in a store.
