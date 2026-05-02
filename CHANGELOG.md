# Changelog

All notable changes to RJ's Claude Framework.

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
