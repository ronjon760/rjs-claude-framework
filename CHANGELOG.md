# Changelog

All notable changes to RJ's Claude Framework.

## [2.3.0] - 2026-05-29

### Added

- **Design lanes** — Three design tools now have clearly separated jobs: `/design` (DECIDE — owns `MASTER.md`), `frontend-design` skill (EXECUTE — bold, anti-AI-slop build-time craft), and `ui-ux-pro-max` skill (REFERENCE — on-demand catalog). New `templates/docs/design-lanes.md` ships to every project (copied by `setup.sh`) and documents the split.
- **Auto-install of Anthropic's `frontend-design` skill** — `setup.sh` now runs a new `install_skills()` step that installs the official `frontend-design` skill project-level via the `skills` CLI. Non-fatal if Node/npx is missing; idempotent.
- **Design Conviction block** — `/design` and the `MASTER.md` template now bake a single committed creative direction into `MASTER.md`, plus anti-generic guardrails (no Inter/Roboto/Arial defaults, no purple-on-white clichés, dominant tone + sharp accent, one high-impact motion moment). This is what keeps `frontend-design` from fighting the contract at build time.
- **Custom easing curves** — `/design` and the `MASTER.md` template now ship three strong `cubic-bezier` tokens (`--ease-out`, `--ease-in-out`, `--ease-drawer`) instead of weak built-in easings, with a sub-300ms duration ceiling and a "never `ease-in` for UI" rule. Stagger gaps tightened 100ms → 60ms.

### Changed

- `/design` Phase 2 now prompts for a bold Design Conviction rather than a safe default; reference tables flag Inter/Geist as utility-only and steer toward distinctive display faces.
- `CLAUDE.md` template References section now names the three design lanes and points to `docs/design-lanes.md`.
- Framework version bumped to 2.3.0

### Why

The framework already had `/design` to pick a palette/fonts, but its tables steered toward *safe, conventional* choices — exactly what Anthropic's `frontend-design` skill is built to fight. Stacking both unmanaged meant they pulled opposite directions on the same project. This release resolves that by moving the bold "anti-AI-slop" conviction *upstream* into `/design` and `MASTER.md`, so the whole pipeline pulls one direction: decide boldly → record it in the contract → execute it faithfully. It also makes the official `frontend-design` skill a default install so every project gets distinctive, production-grade UI out of the box.

---

## [2.2.0] - 2026-05-28

### Added

- **Compliance Starter Kit** — New `templates/docs/compliance/` directory ships seven documents sized for small-business SaaS: a Privacy Policy template, Terms of Service template, Acceptable Use Policy template, subprocessor list template, one-page Incident Response plan template, a strategic compliance landscape reference, and a README index.
- **`/compliance` slash command** — Interactive questionnaire that detects subprocessors from `.env.example` and dependencies, asks for legal entity / contact / governing state / data categories / AI use, then fills in the templates and writes them to `docs/legal/` and `docs/compliance/`. Updates `architecture.json compliance.last_reviewed`.
- **SaaS-shape detection** — `lib/detect-stack.sh` now exports `IS_SAAS_STACK` (true for nextjs, nuxt, svelte, astro, gatsby, vite, CRA, express, django, fastapi, flask, react-native-expo). Used to gate compliance scaffolding.
- **Opt-out compliance prompt in setup.sh** — On detected SaaS-shape projects, `setup.sh` now prompts `Generate compliance starter docs? [Y/n]` (defaulted to Y). On accept, copies the seven templates to `docs/compliance/` and `docs/legal/` and flips `architecture.json compliance.enabled` to true.
- **`compliance` config in architecture.json** — New `compliance` section in every SaaS-shape generated architecture config tracks tier, geography, regulated data categories, doc paths, and last review date.
- **CLAUDE.md Compliance section** — Generated `CLAUDE.md` now includes a short "Compliance (SMB tier)" section pointing at the kit and explaining when to update the subprocessor list and Privacy Policy.
- **`--no-compliance` flag** — Power-user opt-out for `setup.sh`.

### Changed

- Slash command count in README updated from 11 to 12
- "What gets generated" table now includes `docs/compliance/` and `docs/legal/`
- Framework version bumped to 2.2.0

### Why

The framework already enforces structure (FDD), design (`/design`), and planning (`/vision`, `/buildplan`) — but every project still launched without a Privacy Policy, Terms of Service, or subprocessor list. SMB SaaS founders typically don't know where to start, end up using a Squarespace or template-generator Privacy Policy that doesn't match what their product actually does, and discover gaps only when a customer asks. This release makes the SMB-tier compliance floor (Privacy Policy + ToS + AUP + subprocessor list + IR plan) the default scaffold for any SaaS-shape project, with the option to refine via an interactive wizard. Higher tiers (mid-market DPA/MSA, enterprise SOC 2 prep, regulated HIPAA/PCI) are documented as future work and gated behind a `tier` field in `architecture.json`.

---

## [2.1.0] - 2026-05-27

### Added

- **Vision Wizard** (`/vision` command) — A first-principles questionnaire that captures project purpose, target audience, MVP scope, tech stack, and phased product arc. Generates `docs/VISION.md` as the persistent strategic document. Includes embedded reference tables for 10 project types with recommended tech stacks, complexity heuristics, and phase arc templates.
- **Build Plan Wizard** (`/buildplan` command) — Takes the vision and design system as input, walks through user journeys interactively, and generates phased implementation specs. Phase 1 gets deep detail (screen-by-screen user journeys, data model, API routes, FDD features, edge cases). Later phases get lighter outlines. Includes embedded edge case patterns and stack-adaptive plan sections.
- **VISION.md template** — `templates/docs/VISION.md.template` provides the canonical structure for generated vision documents.
- **Vision & Planning audit** — The `/audit` command now includes a Vision & Planning compliance section that checks for `docs/VISION.md` and `docs/plans/` with required sections.
- **Wizard chaining** — `/vision` suggests running `/design` next. `/design` suggests running `/buildplan` when a vision exists but no plans do. Creates a complete guided flow: `/vision → /design → /buildplan`.
- **Vision config in architecture.json** — New `vision` section in every generated architecture config tracks whether a vision doc exists.

### Changed

- `/design` now chains to `/buildplan` when vision exists but no build plans do
- `/welcome` introduces the full wizard chain: /vision → /design → /buildplan
- Session plan reminder now suggests `/vision` for projects without a vision doc
- CLAUDE.md template references `/vision`, `/buildplan`, `docs/VISION.md`, and `docs/plans/`
- Inline fallback CLAUDE.md blocks (static-html and generic) also reference all three wizards
- Setup install summary now shows the full chain: `/vision → /design → /buildplan`
- Framework version bumped to 2.1.0

### Why

The biggest barrier to building with Claude Code across sessions is context loss — Claude has to re-learn the project's purpose and plan every time. The Vision and Build Plan wizards create persistent documents (`docs/VISION.md` and `docs/plans/phase-*.md`) that any new session can reference. A user can open a fresh session and say "Read the vision, design system, and build plan — build the next milestone" and Claude has everything it needs. This also solves the blank-canvas problem for non-technical founders: the wizards extract their idea through simple questions and produce implementation-quality specs.

---

## [2.0.0] - 2026-05-27

### Added

- **Design System Wizard** (`/design` command) — A natural-language-first questionnaire that generates `design-system/MASTER.md` with color palette, typography, spacing, motion, and component patterns tailored to the project's industry and aesthetic. Works across all stacks (JS/TS, Python web, static HTML, React Native). Includes embedded reference tables for 12 industry verticals, 12 curated palettes, 12 font pairings, and 7 animation approaches. Available both during setup and on-demand.
- **Karpathy Principles** — Four behavioral guidelines (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) are now a standard section in every framework-generated CLAUDE.md. These are stack-agnostic and apply to all projects.
- **Plan Mode Reminder** (`session-plan-reminder.sh`) — A soft SessionStart hook that encourages planning before coding. Non-blocking — just a reminder, not a gate. Also suggests running `/design` if the project has UI files but no design system yet.
- **Design system config in architecture.json** — New `design_system` section in every generated architecture config tracks whether a design system exists, where its files live, and what component sources are used. The `/design` command sets `enabled: true` after generation.
- **Design system audit** — The `/audit` command now includes a Design System Compliance section when `design_system.enabled` is true, checking for required MASTER.md sections.
- **MASTER.md template** — `templates/design-system/MASTER.md.template` provides the canonical structure for generated design systems.

### Changed

- CLAUDE.md template now includes Behavioral Guidelines (Karpathy Principles) section
- CLAUDE.md template references `/design` in Commands and `design-system/MASTER.md` in References
- Inline fallback CLAUDE.md blocks (static-html and generic) also include Karpathy Principles
- `/welcome` command now introduces `/design` alongside other commands
- Setup summary now recommends running `/design` for UI projects
- Framework version bumped to 2.0.0

### Why

The biggest source of inconsistency in generated projects is UI design drift — Claude makes different visual choices across sessions when there's no design system. The Design System Wizard creates a single source of truth (`MASTER.md`) that Claude references during every build. The Karpathy Principles address a second pattern: Claude sometimes jumps to coding without stating a plan, leading to wasted work and scope creep. These are now first-class framework features.

### Upgrade Notes

- **CLAUDE.md is not overwritten on update.** To add the Karpathy Principles to an existing project, copy the "Behavioral Guidelines" section from a fresh install, or delete CLAUDE.md and re-run `setup.sh`.
- **architecture.json is not overwritten on update.** Run `/design` in an existing project to automatically add the `design_system` configuration.

---

## [1.6.0] - 2026-05-02

### Changed

- **FDD is now enabled by default.** New projects (except static HTML) start with Feature-Driven Development turned on in `.claude/architecture.json`. The previous `--fdd` flag is retained for back-compat but no longer required. Pass `--no-fdd` to opt out.

### Added

- **`pre-fdd-guard.sh` hook** — a PreToolUse hook that hard-blocks file writes that violate FDD structure. It refuses to let Claude create:
  - Non-shadcn components inside `src/components/` (those belong in `src/features/<name>/components/`)
  - Feature components inside `src/app/` (router files like `page.tsx`, `layout.tsx`, `route.ts` still pass)
  - New files inside a feature folder before its `QUICK_REF.md` exists
  The hook is a no-op when `fdd.enabled` is false, so opt-out projects are unaffected.
- **Session-start FDD reminder** — `session-init.sh` now prints a short reminder to Claude's session context when FDD is enabled, so the rules are visible at the top of every session instead of buried in CLAUDE.md.

### Why

FDD documentation existed in CLAUDE.md and the `/feature` command, but nothing actually enforced the structure. Claude routinely created components in `src/app/` or `src/components/` without scaffolding a feature folder, and forgot to write `QUICK_REF.md`. This release closes the gap with a hard pre-write block plus a per-session reminder.

## [1.5.0] - 2026-04-13

### Added

- Version tracking — projects now record which framework version installed them (`.claude/.framework-version`)
- `/update` command — check for and install framework updates from within Claude
- Session-start version check — notifies when a newer framework version is available
- Timestamped backups before updates (`.claude/backups/`)
- This CHANGELOG for tracking what changed between versions

### Changed

- `--update` flag now shows version comparison and changelog before updating
- Framework version constant updated to match release history (was stuck at 1.0.0)

## [1.4.0] - 2026-04-13

### Added

- Static HTML site support (auto-detection, appropriate hooks, simplified settings)
- Test runner detection (Vitest, Jest, Mocha, pytest)
- `/test` command for test-first development workflow
- `stop-test.sh` hook — runs relevant tests after Claude stops

## [1.3.0] - 2026-04-12

### Added

- Hierarchical CLAUDE.md support (subdirectory-specific context files)
- `/welcome` command for onboarding new contributors
- Subdirectory templates for components, lib, store, and more

## [1.2.0] - 2026-04-11

### Added

- `/audit` command — project architecture and code quality check
- `/save` command — commit and push workflow
- `/share` command — pull request creation workflow
- Plain-language communication rule in CLAUDE.md template

## [1.1.0] - 2026-04-11

### Added

- Architecture audit system (`audit.sh` — 330 lines)
- `.claude/architecture.json` with stack-specific rules and boundaries
- `post-architecture-check.sh` hook for boundary enforcement

## [1.0.0] - 2026-04-11

### Added

- Initial release
- 11 automated hooks (security guard, config protection, commit quality, auto-format, auto-lint, console warning, session tracking, type checking, milestone reminders, desktop notifications, session init)
- Auto-detection for Node.js, Python, Next.js, React, Express, Django, FastAPI, Flask, and more
- `CLAUDE.md` template generation with stack-specific content
- `PROJECT_LESSONS.md` corrections tracker
- `.env.example` auto-generation
- Session logging system
- Package manager detection (npm, yarn, pnpm, bun)
- Tool detection (Prettier, ESLint, Biome, Ruff, Black, mypy, Jest, Vitest, Mocha, pytest)
