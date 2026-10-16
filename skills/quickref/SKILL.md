---
name: quickref
description: Generate or refresh a feature's QUICK_REF.md by reading its code — purpose, key files, data flow, dependencies, edge cases, related features. Use when a feature folder is missing its QUICK_REF.md, when the user asks to document a feature, or after significant changes to a feature.
argument-hint: feature name (e.g., "profile") or path (e.g., "src/features/profile")
---

# Feature QUICK_REF

Write a short, accurate guide to one feature, generated from its actual code.

Feature, if given: $ARGUMENTS

## Steps

1. **Find the feature.** A name means a folder under `fdd.features_dir` in `.claude/architecture.json`; a path is used directly. If nothing was given, list the available features and ask which one.
2. **Read its code.** All source files in the folder: the main components, hooks, services, and types; how data flows (what calls what); what it imports from shared code or external packages; and edge cases the code handles (error handling, special conditions, validation).
3. **Write `QUICK_REF.md`** in the feature folder, using `${CLAUDE_PLUGIN_ROOT}/templates/QUICK_REF.md.template` as the structure:
   - **Purpose** — one sentence on what the feature does
   - **Key Files** — a table of each file and its role
   - **Data Flow** — how data moves through the feature
   - **Dependencies** — shared libraries and packages it relies on
   - **Edge Cases** — tricky behaviors found in the code
   - **Related Features** — other features it connects to
4. **If a QUICK_REF.md already exists**, show what would change and ask before replacing it, keeping anything the user wrote by hand that's still accurate.

Describe only what the code actually does. Keep the language simple — these guides help future conversations and people understand the feature quickly.
