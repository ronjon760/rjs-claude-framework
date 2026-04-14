---
description: Create a new feature folder with FDD structure
argument-hint: feature name (e.g., "profile", "messaging", "auth")
---

Scaffold a new feature directory following the Feature-Driven Development (FDD) pattern.

Steps:

1. Read `.claude/architecture.json` to find the features directory path and confirm FDD is enabled
2. If FDD is not enabled, explain what FDD is and offer to enable it (set `fdd.enabled` to `true` in architecture.json and create the features directory)
3. Get the feature name from the user's argument (e.g., /feature profile)
4. If no name was given, ask "What feature are you building?" and suggest a name based on the project
5. Create the feature directory structure:
   - `{features_dir}/{feature_name}/components/` — UI components for this feature
   - `{features_dir}/{feature_name}/hooks/` — Custom hooks (data fetching, state logic)
   - `{features_dir}/{feature_name}/types.ts` — TypeScript types (with starter export)
   - `{features_dir}/{feature_name}/index.ts` — Barrel export (public API)
   - `{features_dir}/{feature_name}/QUICK_REF.md` — Feature documentation
6. Ask the user to describe the feature's purpose in one sentence, then fill in the QUICK_REF.md Purpose section
7. If this is a React Native project, also create a placeholder screen component in components/
8. Tell the user what was created and suggest next steps:
   - "Start building your [feature] components in the components/ folder"
   - "Add custom hooks for data fetching and state logic in the hooks/ folder"
   - "Update QUICK_REF.md as you build — it helps future sessions understand this feature"

Important:

- Follow the existing project's naming conventions (check architecture.json)
- Use the project's existing styling approach for any starter components
- Keep the QUICK_REF.md template consistent with other features in the project
- If the features/ directory doesn't exist yet, create it
