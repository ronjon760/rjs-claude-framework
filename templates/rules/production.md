---
paths:
  - "**/*.{ts,tsx,js,jsx,py,go,rs}"
---

# Production readiness

- Handle errors where they can be acted on; show people a helpful message and log the technical detail. Don't swallow errors silently.
- Configuration (URLs, feature flags, limits) comes from environment variables or a config module, not hardcoded values.
- Database schema changes go through migrations that can be rolled back.
- Anything that can be retried (webhooks, background jobs, payments) must be safe to run twice.
- Use structured logging with enough context (request id, user id — not personal data) to debug a production issue.
