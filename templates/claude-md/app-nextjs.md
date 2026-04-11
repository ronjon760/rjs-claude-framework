# App Directory (Next.js App Router)

## Routing
- Each subdirectory with a `page.tsx` is a route
- `layout.tsx` wraps child routes with shared UI
- `loading.tsx` shows a spinner while the page loads
- `error.tsx` catches errors and shows a fallback

## Rules
- Pages should be under 200 lines — extract step components to separate files in the same directory
- Pages handle layout and composition only — business logic belongs in hooks or services in `lib/`
- API routes (`api/*/route.ts`) must be thin wrappers — delegate to services, never put business logic inline
- Co-located component files (like `StepReview.tsx` next to `page.tsx`) are fine — only `page.tsx` creates a route

## Conventions
- Use `"use client"` only when the component needs interactivity (state, effects, event handlers)
- Prefer server components (no directive) for static content
