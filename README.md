# RJ's Claude Framework

Guardrails and guided workflows that help new builders ship enterprise-grade software with [Claude Code](https://code.claude.com). Designed for teams where not everyone is technical.

---

## TL;DR

You describe what you want. Claude writes the code. The framework keeps it safe and honest: it stops Claude from reading your secrets or skipping safety checks, makes Claude fix failing tests before it hands back, snapshots your work automatically, and gives every pull request a test run and a security check.

- **What it is:** a Claude Code **plugin** (a bundle of skills, hooks and a reviewer agent), plus a one-time project setup.
- **Who it's for:** non-technical owners who want trustworthy AI-built software, and developers who want guardrails that stay out of the way.
- **Install** — inside Claude Code, in your project:

  ```
  /plugin install rjs --marketplace ronjon760/rjs-claude-framework
  /rjs:init
  ```

  Or from a terminal in your project folder:

  ```bash
  bash <(curl -fsSL https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
  ```

Coming from v2? Run either one in your project — your old hooks, commands and session logs are moved to `.claude/backups/` and replaced. Your CLAUDE.md and your own settings are kept. See [Upgrading from v2](#upgrading-from-v2).

---

## A day in the life

It's Tuesday morning. You want to add a contact form to your site. You open a terminal, type `claude`, and describe it:

> Add a contact form to the home page that emails me when someone submits it.

For something this size, ask for a plan first — press **Shift + Tab** until you see plan mode, or just say "plan this before you build it". Claude reads the project and proposes: a `contact-form` feature folder, a form built from your existing inputs, an API route using the email service it found in `.env.example`, and a success state. You add "include a honeypot field for bots", approve, and Claude starts. (For a one-line change, skip the plan — it's overhead you don't need.)

While it works, the framework is quietly doing its job:

- Claude tries to put the form in a random folder. The **feature-folder guard** stops it and points it to `src/features/contact-form/`.
- After each file, the code is formatted and linted, and anything worth fixing (a leftover `console.log`, a component calling the network directly) is handed straight back to Claude.
- Claude finishes, but one test now fails. **Verify-on-stop** catches it and Claude fixes it before telling you it's done.
- Claude needs your permission for something, and your laptop pings you.

The form looks right, but the test email never arrives. Claude tries a fix; still broken. Instead of piling on corrections, press **Esc Esc** to `/rewind` to the point before things went sideways, and re-prompt with what you learned. This time it works.

You type `/rjs:save` — a plain-English commit, secrets checked, pushed to GitHub. When it's ready for review, `/rjs:share` runs a fresh-eyes **reviewer** over the changes, then opens a pull request your collaborator can read like a normal document. GitHub runs the tests, scans for leaked keys, and — if you turned it on — Claude reviews it for security problems.

That's the loop: describe, build, let the framework catch the dumb stuff, ship.

---

## Commands

All framework skills start with `rjs:` so they never collide with Claude Code's built-ins.

| Command | What it does |
|---|---|
| `/rjs:init` | One-time project setup (and upgrade from v2) |
| `/rjs:vision` → `/rjs:design` → `/rjs:buildplan` | Kickoff wizards: what you're building and for whom, the visual design system, a phased build plan |
| `/rjs:feature <name>` · `/rjs:quickref <name>` | Start a new self-contained feature · document one |
| `/rjs:test` | Test-first: write the test, watch it fail, make it pass |
| `/rjs:adr` | Record a big technical decision and why it was made |
| `/rjs:audit` | Whole-project health check, explained in plain language |
| `/rjs:save` | Commit and push, with secrets kept out |
| `/rjs:share` | Fresh-eyes review, then a plain-language pull request |
| `/rjs:checkpoints` | See or restore the automatic end-of-session snapshots |
| `/rjs:compliance` | Privacy policy, terms, subprocessor list, incident plan (small-business tier) |
| `/rjs:welcome` | Orientation for someone new to the project |

Claude Code's own commands do a lot of the rest — the framework points you to them instead of duplicating them:

| Built-in | Use it for |
|---|---|
| `/verify` | Check the running app actually works, not just the tests |
| `/code-review`, `/security-review` | Deeper review of a branch before merging |
| `/rewind` (Esc Esc) | Undo Claude's last edits and conversation turns |
| `/resume`, `claude --continue` | Pick up an earlier conversation |
| `/goal` | "Keep going until this is true" (for example, all tests pass) |
| `/design` | Draft visual mockups on a canvas (after `/rjs:design` sets the rules) |
| `/context`, `/clear`, `/compact` | Keep the conversation focused |

---

## What runs automatically

| When | What | What you'll notice |
|---|---|---|
| Claude reads or edits a file | **Secret guard** blocks `.env`, keys and credential files (`.env.example` is fine) | Claude explains it can't open the file |
| Claude edits a lint / format / TypeScript config | **Config guard** asks you first | A permission prompt |
| Claude creates a file | **Feature-folder guard** keeps features in their own folders | Claude moves the file |
| Claude runs a git command | **Git guard** blocks skipping checks, force-pushing to main and committing secrets or debug code; asks before anything that throws work away | Claude fixes the problem, or you're asked |
| After each edit | **Format, lint and structure checks** | Usually nothing — problems go straight to Claude |
| Claude finishes a turn with code changes | **Verify-on-stop** runs type checks and the related tests; failures send Claude back to fix them | Occasionally Claude keeps working a bit longer |
| Claude is waiting on you | **Desktop notification** | A ping |
| Session ends | **Checkpoint** snapshots uncommitted work to a private git ref | Nothing — until you need `/rjs:checkpoints` |

Every check can be switched off per project in `.claude/architecture.json` → `"checks"`.

### Do I still need to "save sessions"?

No. Claude Code now does this itself:

- Every conversation is saved automatically — `/resume` brings it back.
- `/rewind` undoes Claude's edits within a session.
- **Auto memory** carries what Claude learned into future sessions on your machine.
- The framework adds the missing piece: an automatic snapshot of uncommitted work at the end of each session, including changes made by shell commands, which `/rewind` can't track.

Conversations are kept for 30 days by default; `/rjs:init` raises that to 90 for the project (`cleanupPeriodDays` in `.claude/settings.json`). Git is still your real history — `/rjs:save` often.

---

## What `/rjs:init` sets up

| File | Why |
|---|---|
| `CLAUDE.md` | A short project guide Claude reads every session. Short on purpose — long ones get ignored |
| `.claude/rules/` | Focused guidance that loads only when relevant (security, production readiness, your stack, lessons learned) |
| `.claude/settings.json` | Permission rules that stop Claude from reading secret files, even via shell commands, and registers the plugin so teammates are prompted to install it |
| `.claude/architecture.json` | Structure rules and the switches for each check |
| `.gitignore`, `.env.example` | Secret files stay out of git; every variable the app needs is listed |
| `.github/` (optional) | CI (lint, types, tests, build, dependency audit), secret scanning, Dependabot, a pull request template, and optional Claude security review |

It never overwrites a file you already have.

---

## Working well with Claude Code

- **Plan when it matters.** Plan mode is worth it for multi-file or unfamiliar work. If you could describe the change in one sentence, skip it.
- **Give Claude a way to check itself.** Tests, a build, or `/verify`. It's the biggest single quality lever.
- **Keep sessions focused.** `/clear` between unrelated tasks. If you've corrected Claude twice on the same thing, rewind or start fresh with a better prompt. `/context` shows how full the conversation is; ask Claude to set up a `/statusline` that shows it all the time.
- **Teach it once.** When Claude gets something wrong, add a line to `.claude/rules/lessons.md` (or just say "add that to the lessons").
- **Branch, review, merge.** Work on a branch, `/rjs:share` to open a pull request, and merge when CI is green. `/rjs:init` can make GitHub enforce this.
- **Permissions.** Claude Code starts in auto mode, which handles routine actions and asks about risky ones. The framework's guards apply in every mode.

---

## Requirements

- [Claude Code](https://code.claude.com/docs/en/setup) **2.1.295 or later** (`claude update`)
- `git`, and `jq` (preinstalled on recent macOS; otherwise [jqlang.org/download](https://jqlang.org/download/)). `python3` works as a fallback.
- Windows: install [Git for Windows](https://git-scm.com/download/win) so the hooks have `bash`.

### Turn on updates

Plugins from community marketplaces don't auto-update by default. Once per machine: `/plugin` → **Marketplaces** → `rjs-claude-framework` → enable auto-update. Or update on demand with `/plugin update rjs`.

---

## Upgrading from v2

v3 replaces the copied-in scripts with a plugin. In your project:

```
/plugin install rjs --marketplace ronjon760/rjs-claude-framework
/rjs:init
```

What changes:

- `.claude/hooks/`, the framework's `.claude/commands/`, `.claude/sessions/` and the version files move to `.claude/backups/v2-<date>/`. Delete that folder once you're happy.
- Framework hooks are removed from `.claude/settings.json`; everything else in it is kept, and secret-file deny rules are added.
- Commands are now `/rjs:save`, `/rjs:vision` and so on. `/update` is gone — the plugin system handles updates.
- `PROJECT_LESSONS.md` lessons move into `.claude/rules/lessons.md`, which actually loads every session (the old file only loaded if something pointed at it).
- Per-folder `CLAUDE.md` files from v2 still work; new projects get `.claude/rules/` files instead.

---

# Nerd out

### Why v3 looks so different

v2 was built in April 2026. Since then Claude Code gained plugins, merged commands into skills, added `/rewind`, auto memory, auto mode, `/verify`, `/security-review`, and fail-closed hooks — and the models got good enough that heavy instructions now backfire. A review against the docs and hands-on tests found that most v2 checks never reached Claude at all: a hook that exits successfully and prints to stderr is invisible to both Claude and you. The guards could also be bypassed (`git commit -m "x" --no-verify`, `git add -A && git commit` with a key in it), and they silently stopped running after Claude changed directory. The full write-up, with sources, is in [`docs/reviews/2026-10-v3-review.md`](docs/reviews/2026-10-v3-review.md).

v3's rule: **hooks enforce only what must never happen; skills teach on demand; CLAUDE.md stays short and calm.**

### How the hooks talk

Every hook replies in JSON, which Claude Code reads: `additionalContext` reaches Claude, `systemMessage` reaches you, `permissionDecision` / `decision: "block"` control the action. Guards set `onFailure: "block"`, so a crashed guard blocks instead of waving everything through. Scripts are referenced through `${CLAUDE_PLUGIN_ROOT}` and work from any folder, on macOS's stock bash 3.2.

### Layout

```
.claude-plugin/   plugin.json, marketplace.json
skills/           one folder per /rjs: skill (lean SKILL.md + reference files)
agents/           reviewer.md — read-only, fresh-context code reviewer
hooks/            hooks.json + scripts/ (lib.sh shared helpers)
scripts/          init-project.sh, detect-stack.sh, audit.sh
templates/        CLAUDE.md, rules/, architecture/, ci/, docs/, design-system/
tests/            hook and setup tests (bash tests/run.sh)
```

### Contributing

Run `bash tests/run.sh` and `claude plugin validate .` before opening a pull request. Bump `version` in `.claude-plugin/plugin.json` for every release — installed copies only update when it changes.

## License

MIT
