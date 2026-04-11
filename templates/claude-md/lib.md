# Lib Directory

## Organization
- `constants.ts` — Static values, configuration, email addresses (things that don't change at runtime)
- `utils.ts` — Pure helper functions (like `cn()` for class merging)
- `types.ts` or `emailTypes.ts` — Shared TypeScript type definitions
- Service files (e.g., `sensaInvoices.ts`, `pendingOrders.ts`) — API interaction and business logic
- Hooks (e.g., `useOrderSubmission.ts`) — Shared React hooks used across multiple pages

## Rules
- lib/ cannot import from components/, store/, or app/ — it's a shared foundation layer
- Search here before creating new utilities — check if something similar already exists
- Keep service functions pure where possible — accept data in, return results out
