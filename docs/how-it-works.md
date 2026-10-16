# How it works

The details behind the [README](../README.md). You don't need any of this to use the framework.

## What runs automatically

| When | What happens |
|---|---|
| Claude opens or edits a file | Secret files (`.env`, keys, credentials) are blocked. `.env.example` is fine. |
| Claude edits a lint, format or TypeScript config | You're asked first, so errors can't be "fixed" by loosening the rules. |
| Claude creates a file | Features stay in their own folders (`src/features/<name>/`). |
| Claude runs a git command | Blocked: skipping safety checks, force-pushing to main, committing secrets or debug code. Asked first: anything that throws work away. |
| After each edit | The file is formatted and linted; anything worth fixing goes straight back to Claude. |
| Claude finishes with code changes | Type checks and related tests run. If they fail, Claude fixes them before handing back. |
| Claude is waiting on you | Desktop notification. |
| A session ends | Uncommitted work is snapshotted (see `/rjs:checkpoints`). Never pushed, never touches your branch. |

Switch any check off in `.claude/architecture.json` → `"checks"`.

## What `/rjs:init` sets up

It never overwrites a file you already have.

| File | Why |
|---|---|
| `CLAUDE.md` | A short project guide Claude reads every session |
| `.claude/rules/` | Focused guidance that loads only when relevant (security, production, your stack, lessons) |
| `.claude/settings.json` | Rules that stop Claude reading secret files, and registers the plugin for teammates |
| `.claude/architecture.json` | Folder rules and the on/off switches for each check |
| `.gitignore`, `.env.example` | Secrets stay out of git; every variable the app needs is listed |
| `.github/` (optional) | Tests, type checks, build and a dependency audit on every pull request; secret scanning; Dependabot; optional Claude security review |

## Saving your work

You don't need to save sessions — Claude Code does it:

- `/resume` reopens an earlier conversation.
- `/rewind` (Esc Esc) undoes Claude's edits.
- Auto memory carries what Claude learned into future sessions.
- The framework snapshots uncommitted work when a session ends; `/rjs:checkpoints` restores it.

Conversations are kept for 30 days by default; `/rjs:init` sets 90. Git is still your real backup — `/rjs:save` often.

## Upgrading from v2

In each project:

```
/plugin install rjs --marketplace ronjon760/rjs-claude-framework
/rjs:init
```

- Old hooks, commands and session logs move to `.claude/backups/v2-<date>/` (delete it when you're happy).
- Your CLAUDE.md, your own settings and your own hooks are kept.
- Commands are now `/rjs:save`, `/rjs:vision`, and so on. `/update` is gone — use `/plugin update rjs`.
- `PROJECT_LESSONS.md` moves into `.claude/rules/lessons.md`, which loads every session.

## Why v3 changed

v2 was built in April 2026. Since then Claude Code added plugins, skills, `/rewind`, auto memory, auto mode, `/verify` and `/security-review`, and the models got good enough that heavy instructions backfire. Testing v2 against the docs showed most of its checks never reached Claude, and the guards could be bypassed. Full write-up with sources: [`reviews/2026-10-v3-review.md`](reviews/2026-10-v3-review.md).

The v3 rule: hooks enforce only what must never happen, skills teach on demand, and CLAUDE.md stays short.

## Technical notes

- Hooks reply in JSON: `additionalContext` reaches Claude, `systemMessage` reaches you, `permissionDecision` / `decision: "block"` control the action.
- Guards use `onFailure: "block"`, so a crashed guard blocks instead of allowing.
- Scripts run through `${CLAUDE_PLUGIN_ROOT}`, from any folder, on macOS's stock bash 3.2.

```
.claude-plugin/   plugin.json, marketplace.json
skills/           one folder per /rjs: skill
agents/           reviewer.md (read-only, fresh-eyes review)
hooks/            hooks.json + scripts/
scripts/          init-project.sh, detect-stack.sh, audit.sh
templates/        CLAUDE.md, rules/, architecture/, ci/, docs/, design-system/
tests/            bash tests/run.sh
```

**Contributing:** run `bash tests/run.sh` and `claude plugin validate .` before a pull request, and bump `version` in `.claude-plugin/plugin.json` for each release — installed copies only update when it changes.
