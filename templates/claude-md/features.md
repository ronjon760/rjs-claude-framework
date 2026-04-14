# Features Directory (FDD)

## Organization

- Each feature has its own directory (e.g., `profile/`, `messaging/`, `auth/`)
- Features are self-contained: UI, hooks, types, and documentation together
- Shared code between features goes in `../lib/` or `../components/` (shared)

## Required Structure (every feature)

- `components/` — UI components for this feature
- `hooks/` — Custom hooks (data fetching, state logic)
- `types.ts` — TypeScript types for this feature
- `index.ts` — Public API (barrel export)
- `QUICK_REF.md` — Feature documentation

## Recommended Structure (when files grow past ~200 lines)

- `api/` or `services/` — API/service calls extracted from hooks
- `handlers/` — Event handlers extracted from components
- `utils/` — Feature-specific utility functions

## Rules

- Features CANNOT import from other features — use shared `lib/` instead
- Each feature must have a `QUICK_REF.md` documenting purpose, data flow, and edge cases
- Business logic belongs in `hooks/` or `services/`, NOT in screen/page components
- Use `/feature <name>` to scaffold a new feature
- Use `/quickref <name>` to generate documentation for an existing feature
