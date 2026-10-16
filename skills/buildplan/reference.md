# Build plan reference

## Reference: Common Edge Case Patterns

Auto-include relevant patterns based on project type:

### Authentication
| Scenario | Handling |
|----------|----------|
| Session expires during action | Show re-login prompt, preserve draft state |
| OAuth provider down | Fallback to email/password, show clear error |
| Rate-limited login attempts | Progressive delay, lockout after 5 failures |
| Concurrent sessions | Allow multiple, or invalidate oldest |

### Data & State
| Scenario | Handling |
|----------|----------|
| Empty state (no data yet) | Show helpful zero-state with CTA to get started |
| Pagination boundary | Load more / infinite scroll with loading skeleton |
| Stale data after background update | Optimistic UI or polling with refresh indicator |
| Concurrent edits | Last-write-wins or conflict resolution UI |
| Partial data (some API calls failed) | Show available data, indicate what's missing |

### Network & Performance
| Scenario | Handling |
|----------|----------|
| Slow connection (> 3s load) | Loading skeleton, progress indicator |
| Request timeout | Retry with backoff, show timeout message |
| Offline state | Show cached data if available, indicate offline |
| Large payload | Paginate, stream, or chunk the response |

### Input & Validation
| Scenario | Handling |
|----------|----------|
| XSS attempt in user input | Sanitize all inputs, escape output |
| File upload too large | Client-side size check before upload, clear limit message |
| Malformed data from external API | Validate with Zod/schema, fallback to defaults |
| Required field missing | Inline validation, don't submit until valid |

### Payments (if applicable)
| Scenario | Handling |
|----------|----------|
| Card declined | Clear error message, allow retry with different card |
| Webhook delivery failure | Idempotent handler, retry queue |
| Refund requested | Process via Stripe API, update subscription state |
| Currency mismatch | Display in user's locale, convert at charge time |

---

## Reference: Plan Sections by Project Type

Conditionally include or exclude sections based on project type:

### Web App (Next.js, React, etc.)
Include: User Journey (screen-by-screen), Data Model (Prisma), API Routes, FDD Features, Edge Cases, Pages/Routes, Motion specs (if design system exists)

### API-Only Service
Include: Endpoint Specifications (method, path, request/response schema, auth), Data Model, Error Response Format, Rate Limiting Strategy, Authentication Flow
Skip: User Journey screens, Motion specs, Component sources

### Mobile App (React Native)
Include: Screen Flows with Navigation Structure, Data Model, API Integration, Offline Handling, Platform-Specific Considerations (iOS vs Android), Push Notifications
Adapt: Use "Screens" instead of "Pages", navigation stack instead of routes

### Static Site
Include: Page Inventory, Content Structure, SEO Requirements, Deployment Config
Skip: Data Model, API Routes, Background Processing, Auth
Lighter: Edge cases focus on content display and SEO

### CLI Tool
Include: Command Structure, Input/Output Specifications, Configuration, Error Messages, Testing Strategy
Skip: User Journey screens, Motion, Components, FDD Features

