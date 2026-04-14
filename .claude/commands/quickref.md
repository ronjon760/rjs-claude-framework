---
description: Generate or update QUICK_REF.md for a feature
argument-hint: feature name (e.g., "profile") or path (e.g., "src/features/profile")
---

Generate a QUICK_REF.md for an existing feature by analyzing its code.

Steps:

1. Find the feature directory:
   - If a feature name is given, look in the features directory from architecture.json
   - If a path is given, use that directly
   - If nothing is given, list available features and ask which one
2. Analyze the feature's code:
   - Read all source files in the feature directory
   - Identify the main components, hooks, services, and types
   - Trace the data flow (what calls what)
   - Find dependencies on shared code (lib/ imports, external packages)
   - Note any edge cases in the code (error handling, special conditions, validation)
3. Generate QUICK_REF.md with:
   - **Purpose**: One sentence describing what this feature does
   - **Key Files**: Table of every file and its role
   - **Data Flow**: How data moves through the feature
   - **Dependencies**: External imports (shared libs, packages)
   - **Edge Cases**: Tricky behaviors found in the code
   - **Related Features**: Other features this one relates to
4. Write the QUICK_REF.md file
5. If QUICK_REF.md already exists, show what changed and ask if the user wants to update it

Keep the language simple and jargon-free — these docs help future Claude sessions and humans understand the feature quickly.
