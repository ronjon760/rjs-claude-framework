# Store Directory

## Pattern
- Uses Zustand for state management
- Each ordering flow has its own store (e.g., `designStore.ts`, `uploadStore.ts`)
- All stores extend a shared base from `orderBase.ts` for common fields (name, email, address, billing, etc.)

## Rules
- Store files contain state + actions only — no UI rendering, no side effects
- Flow-specific fields go in the flow's store, shared fields go in `orderBase.ts`
- Adding a new common field (like "country") means adding it once in `orderBase.ts`, not in every store
- Static data (like accessories list) belongs in `lib/constants.ts`, not in a store
