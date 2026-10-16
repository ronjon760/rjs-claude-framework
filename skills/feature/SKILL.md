---
name: feature
description: Scaffold a new feature folder using the Feature-Driven Development (FDD) layout — components/, hooks/, types.ts, index.ts, and QUICK_REF.md — under the project's features directory. Use when the user starts building a new feature area (e.g. profile, messaging, auth) and wants its folder set up.
argument-hint: feature name (e.g., "profile", "messaging", "auth")
---

# New feature folder

Set up a feature folder following the project's Feature-Driven Development (FDD) pattern, where everything for one feature lives together.

Feature name, if given: $ARGUMENTS

## Steps

1. Read `.claude/architecture.json` for `fdd.enabled`, `fdd.features_dir`, and naming conventions.
   - If FDD isn't enabled, explain briefly what it is (each feature gets its own folder with its UI, logic, types, and a short guide) and offer to enable it: set `fdd.enabled` to `true` and create the features directory.
2. If no name was given, ask "What feature are you building?" and suggest a name based on the project (and `docs/plans/` if it exists).
3. Copy the scaffold from `${CLAUDE_PLUGIN_ROOT}/templates/feature-scaffold/` to `{features_dir}/{feature_name}/`:
   - `components/` — UI components for this feature
   - `hooks/` — custom hooks (data fetching, state logic)
   - `types.ts` — types, with a starter export
   - `index.ts` — barrel export (the feature's public API)
   - `QUICK_REF.md` — the feature's short guide

   Replace any placeholder names with the feature name, following the project's naming conventions. Create the features directory if it doesn't exist.
4. Ask the user to describe the feature's purpose in one sentence, and fill in the Purpose section of `QUICK_REF.md`. Keep it consistent with other features' QUICK_REFs.
5. For a React Native project, add a placeholder screen component in `components/`, styled with the project's existing approach.
6. Tell the user what was created and what's next:
   - Build the feature's components in `components/`.
   - Put data fetching and state logic in `hooks/`.
   - Keep `QUICK_REF.md` current as the feature grows — it helps future conversations (and people) understand it quickly. `/rjs:quickref` can regenerate it from the code.
