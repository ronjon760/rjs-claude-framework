# RJ's Claude Framework

A portable, one-command framework that makes any project enterprise-ready for AI-assisted development with Claude Code. Designed for teams where not everyone is technical.

## What It Does

When installed in a project, the framework runs **11 automated hooks** that silently enforce code quality, security, and best practices every time Claude Code is used. The developer just describes what they want — the framework handles the rest.

### Automated Hooks

| Hook | When | What It Does |
|------|------|-------------|
| **Security Guard** | Before file access | Blocks reading `.env`, `.pem`, credentials |
| **Commit Quality** | Before `git commit` | Catches debug code, hardcoded secrets, blocks `--no-verify` |
| **Config Protection** | Before config edits | Warns against weakening linter/formatter configs |
| **Auto-Format** | After file edits | Runs Prettier (JS/TS) or Ruff (Python) automatically |
| **Auto-Lint** | After file edits | Runs ESLint (JS/TS) or Ruff (Python), reports issues |
| **Console Warning** | After file edits | Warns about `console.log` / `print()` in production code |
| **Session Tracker** | After file edits | Logs every change to the session log |
| **Type Check** | After every response | Runs `tsc` or `mypy` to catch type errors |
| **Milestone Reminder** | After every response | Suggests saving after 5+ changes without a commit |
| **Desktop Notify** | After every response | System notification when Claude finishes |
| **Session Init** | On session start | Creates a new session log file |

### What Gets Generated

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Auto-generated project guide that Claude reads every session |
| `PROJECT_LESSONS.md` | Tracks corrections so Claude doesn't repeat mistakes |
| `.env.example` | Documents required environment variables |
| `.claude/settings.json` | Hook configuration |
| `.claude/hooks/*.sh` | 11 automation scripts |
| `.claude/sessions/*.md` | Session logs for collaboration visibility |

## Quick Start

### Install into an existing project

```bash
cd your-project
bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
```

The setup script automatically:
1. Detects your tech stack (Next.js, React, Express, Python, static HTML, etc.)
2. Installs the appropriate hooks and settings
3. Generates a `CLAUDE.md` tailored to your project
4. Installs missing dev tools (Prettier, etc.)
5. Initializes git if needed

### Update an existing installation

```bash
bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh) --update
```

Updates hook scripts and settings without overwriting your `CLAUDE.md`, `PROJECT_LESSONS.md`, or `.env.example`.

## Supported Stacks

| Stack | Formatter | Linter | Type Checker |
|-------|-----------|--------|-------------|
| TypeScript (Next.js, React, Node) | Prettier | ESLint | tsc |
| JavaScript | Prettier | ESLint | — |
| Python | Ruff or Black | Ruff | mypy |
| HTML/CSS (Static sites) | — | — | — |
| Mixed JS/TS + Python | Both | Both | Both |

## Daily Workflow

1. **Open terminal** in your project
2. **Type `claude`** to start Claude Code
3. **Describe what you want**: "Add a contact form that sends an email"
4. **Claude works** — hooks auto-format, lint, and type-check silently
5. **Get a notification** when Claude finishes
6. **Review in browser**, ask for changes if needed
7. **Checkpoints are suggested** automatically after significant changes

### For Collaborators

Check `.claude/sessions/` to see what was changed, when, and on which branch. Each session log documents every file modification with timestamps.

## Session Tracking

Every Claude Code session creates a log file in `.claude/sessions/`:

```markdown
# Session: 2026-04-11 14:30 PST

**Project:** my-app
**Branch:** feature/pricing-page
**Started:** 2026-04-11 14:30 PST

## Changes

- [14:32] Modified `app/pricing/page.tsx`
- [14:33] Created `components/PricingCard.tsx`
- [14:35] Modified `lib/utils.ts`
- [14:38] --- CHECKPOINT REMINDER ---
```

## Project Lessons

When Claude makes a mistake, add a lesson to `PROJECT_LESSONS.md`:

```markdown
### Don't use inline styles for the pricing cards
**Date:** 2026-04-11
**What happened:** Claude used inline styles instead of Tailwind classes
**Correction:** Always use Tailwind utility classes for styling, never inline styles
```

Claude reads this file at the start of every session and avoids repeating the mistake.

## File Structure

```
your-project/
├── CLAUDE.md                          # Auto-generated project guide
├── PROJECT_LESSONS.md                 # Corrections tracker
├── .env.example                       # Environment variable docs
└── .claude/
    ├── settings.json                  # Hook configuration
    ├── hooks/
    │   ├── pre-security-guard.sh      # Block sensitive file access
    │   ├── pre-commit-quality.sh      # Clean commit enforcement
    │   ├── pre-config-protect.sh      # Config change warnings
    │   ├── post-format.sh             # Auto-format code
    │   ├── post-lint.sh               # Auto-lint code
    │   ├── post-console-warn.sh       # Debug statement warnings
    │   ├── post-session-track.sh      # Log file changes
    │   ├── stop-typecheck.sh          # Type validation
    │   ├── stop-milestone.sh          # Checkpoint reminders
    │   ├── stop-notify.sh             # Desktop notifications
    │   └── session-init.sh            # Session start logging
    └── sessions/
        └── *.md                       # Session logs (auto-generated)
```

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- git
- Node.js 18+ (for JS/TS projects)
- Python 3.8+ (for Python projects)

## License

MIT
