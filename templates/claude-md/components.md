# Components Directory

## Organization
- Components are grouped by category in subdirectories (e.g., `ui/`, `forms/`, `layout/`, `cards/`)
- Each component is one file, named in PascalCase (e.g., `StepIndicator.tsx`, `OrderForm.tsx`)

## Rules
- Components handle UI only — no direct `fetch()` calls, no business logic
- Data comes from props or store hooks — components don't know where data comes from
- Shared components (used by multiple pages) go here. Page-specific components go next to their page file.

## Conventions
- Use the `cn()` utility from `lib/utils` for conditional class merging
- Follow existing Tailwind patterns — don't introduce new CSS approaches
