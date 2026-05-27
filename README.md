# RJ's Claude Framework

A portable, one-command framework that makes any project enterprise-ready for AI-assisted development with Claude Code. Designed for teams where not everyone is technical.

---

## TL;DR

You describe what you want. Claude writes the code. The framework — 16 automatic checks running silently in the background — keeps the work clean, safe, and organized. You save with one command. Done.

- **What it is:** A layer that runs on top of Claude Code, the AI coding tool from Anthropic.
- **What it does:** Auto-formats, lints, type-checks, blocks secret leaks, enforces a clean folder structure, runs your tests, logs every change, and guides design decisions with a built-in design system wizard.
- **Who it's for:** Non-technical owners who want trustworthy AI-built software, and developers who want guardrails that don't get in the way.
- **Install:** open a terminal in your project and run

  ```bash
  bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
  ```

---

## A day in the life

It's Tuesday morning. You've had your coffee. You want to add a contact form to your site.

You open a terminal, type `claude`, and hit enter. The framework has already started today's session log, quietly pinged GitHub to see if there's a newer version of itself, and reminded Claude how your project's folders are organized — before you've finished sitting down.

Before you describe the work, you press **Shift + Tab** twice. That puts Claude into **plan mode** — a "let's talk it through first" stance where Claude reads your files, thinks about the work, and proposes a plan *before writing a single line of code*.

> **Why plan mode is a non-negotiable habit.** Anything bigger than a typo deserves a plan. Five minutes of plan-mode discussion catches the wrong-direction work that would have cost you thirty minutes — and a tangled-up conversation — to unwind later. It's where you get to say "yes, that's what I meant" or "no, do it this other way" before any cost is paid. After verification, this is the single biggest quality lever the Anthropic team recommends.

Now you type:

> Add a contact form to the home page that emails me when someone submits it.

Claude reads your project, then comes back with a plan: it'll create a `contact-form` feature folder, build the form component using your existing input styles, wire up an API route using Resend (the email service it spotted in your `.env.example`), and add a success state. It asks: *"Anything to add or change before I start?"*

You read the plan. Looks good — except you want a honeypot field for bots. You say so. Claude updates the plan and asks again. You approve. *Now* Claude actually gets to work.

It creates a new folder under `src/features/contact-form/` — because if it had tried to drop the form in some random place, the **FDD Guard** would have stopped it cold. You watch a few files appear. After each one, the framework auto-formats the code, runs the linter, and notes any leftover debug statements.

A few minutes later, your laptop pings: *"Claude has finished working."* You pop back in. The form looks great in the browser. But the test email never arrives.

You tell Claude. It tries a fix. Still nothing. It tries again. Still broken.

This is the moment to **stop**. Instead of typing yet another correction — which clutters the conversation and makes Claude *more* likely to compound the mistake — you press **Esc** twice. A menu of recent moves appears. Pick the spot before things went sideways. You're back. Re-prompt with what you just learned:

> The form works visually, but the email isn't sending. The issue is probably in the API route — check the email setup.

This time it works. You verify in your browser. You type `/save`. The framework writes a plain-English commit message, double-checks for leaked secrets, and pushes to GitHub.

When the feature is ready for review, you type `/share`. Up pops a pull request your collaborator can read like a normal English document.

That's the loop. You describe. Claude builds. The framework catches the dumb stuff. You ship.

Once a week or so, you'll run `/audit` — it scans the whole project for things drifting out of shape and explains what it finds like a friendly engineer. Fix what matters. Ignore what doesn't.

---

## A quick word on the 1M context window

Claude Opus 4.7 has a **one-million-token context window** — roughly 750,000 words. That's the *love* part: you can stay in a single session for hours, working through a complex feature without losing track of what's already been discussed.

The *hate* part: when context gets too full, Claude starts to slow down, forget earlier instructions, and make sloppier decisions. Performance degrades well *before* you actually "run out" of room. The 1M ceiling is a permission slip, not a target.

Two habits keep this from biting you:

- **Type `/context` every so often.** It prints how full the conversation is. Once you're past about **60–70%**, finish what you're on, run `/save`, and start a fresh session for the next chunk. A clean session with a sharp prompt almost always beats a long session full of accumulated noise.
- **Set up a live context meter with `/statusline`.** Claude Code can render a persistent bar at the bottom of your terminal showing context usage and your current git branch — so you don't have to remember to check. Ask Claude: *"Set up a status line that shows context percentage and the current git branch."* It'll write the config for you, once, and then you can see it at a glance for the rest of forever.

The Anthropic team's rule of thumb: when you've corrected Claude on the same thing twice in a row, the context is probably the problem. `/clear` and start over with what you've learned. It's not lost time — it's compounding interest.

---

## Quick Start

There are two ways in. Pick the one that matches how you like to learn.

### Path 1 — One-liner install (fastest)

If you already trust the framework and just want it running:

```bash
cd your-project
bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh)
```

That's it. The script detects your stack, installs the hooks, generates a tailored `CLAUDE.md`, and turns on FDD by default. Open Claude Code and start describing what you want.

### Path 2 — Read first, install second (recommended for first-timers)

If you'd rather understand what you're installing before you install it, do the tour:

1. **Download the framework** to your computer. Either clone it (`git clone https://github.com/ronjon760/rjs-claude-framework ~/Desktop/RJs-Claude-Framework`) or download the zip from GitHub and unzip it on your Desktop.
2. **Open your project folder** in Claude Code (`cd your-project && claude`).
3. **Paste this prompt:**

   > I'd like to review and bring in RJ's Claude Framework — it's a folder on my Desktop at `~/Desktop/RJs-Claude-Framework`. Please educate me on how this works and how it'll help me build more efficiently. Walk me through the hooks, the slash commands, and Feature-Driven Development. When I'm ready, help me run setup.sh in this project.

4. **Talk through it.** Claude will read the framework's files, explain each piece in plain language, and answer any questions. When you're satisfied, ask it to run setup.sh.

Path 2 takes about 15 minutes longer than Path 1, but you'll come out understanding *why* every hook and command exists — which means you'll know how to push back when something feels off later.

### Update an existing installation

From within Claude Code (recommended):

```
/update
```

Or from the terminal:

```bash
bash <(curl -s https://raw.githubusercontent.com/ronjon760/rjs-claude-framework/main/setup.sh) --update
```

Updates hook scripts, commands, and settings without overwriting your `CLAUDE.md`, `PROJECT_LESSONS.md`, or `architecture.json`. A timestamped backup is created automatically in `.claude/backups/`.

### Version tracking

Every project tracks its framework version in `.claude/.framework-version`. The Version Check hook pings GitHub once per day and notifies you when a newer version is available. See `CHANGELOG.md` for version history.

---

# Nerd Out

> *For the curious, the technical, and the future debugger. Skip if you just want to build.*

---

## Why this exists

AI-assisted coding is fast and powerful — but on its own, it's also unsupervised. An AI can put files in the wrong folder, commit secrets by accident, leave debug code behind, or quietly break a feature you can't see. For someone who can't read the code themselves, that's a trust problem.

This framework solves that. It installs a layer of automatic safety checks (called **hooks**) that run silently every time Claude Code is used, plus a clear set of folder rules so the codebase stays organized as it grows. The owner doesn't have to inspect every change — the framework catches the common mistakes before they reach your repository.

**The promise:**

- You describe what you want in plain language.
- Claude writes the code.
- The framework auto-formats it, checks for errors, blocks dangerous edits, runs your tests, and logs every change.
- You get a notification when it's done, review the result, and save your work with one command.

If you're a non-technical owner, you get peace of mind. If you're a developer joining the project, you get guardrails that keep the codebase clean without slowing you down.

---

## A plain-English glossary

A few words show up throughout this section. Definitions first, so the rest reads cleanly:

| Term                                  | What it means in plain English                                                                                                                |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hook**                              | An automatic check that runs in the background when Claude does something. Like spell-check — invisible until it finds a problem.             |
| **Linter**                            | A tool that reads your code and points out mistakes (unused variables, sloppy patterns, common bugs).                                         |
| **Formatter**                         | A tool that re-indents and re-styles code so every file looks consistent. Cosmetic only — never changes what the code does.                   |
| **Type checker**                      | A tool that catches a specific kind of bug: passing the wrong kind of data into a function (e.g., a number where text was expected).          |
| **Slash command**                     | A shortcut you type in Claude Code starting with `/` (like `/save`). Triggers a multi-step task the framework has pre-defined.                |
| **Feature-Driven Development (FDD)**  | A folder rule: every distinct feature lives in its own self-contained folder, so changing one feature can't accidentally break another.       |
| **Session log**                       | An auto-written diary of what happened during a Claude session — every file change, every checkpoint. Stored in `.claude/sessions/`.          |

---

## The 16 hooks, explained

Hooks are grouped by **when they run**. Together, they form a pipeline: from the moment a session starts to the moment Claude finishes a response, the framework is checking the work.

### When a session starts

| Hook              | What it does                                                                  | Why it matters                                                                                                                |
| ----------------- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Session Init**  | Creates a fresh log file in `.claude/sessions/` and reminds Claude of FDD rules. | You get a written record of every session, and Claude starts each session aware of the project's structure rules.            |
| **Plan Reminder**  | Prints a "think before coding" reminder and suggests `/design` if no design system exists. | Encourages the habit of planning before building — the single biggest quality lever for AI-assisted work. |
| **Version Check** | Pings GitHub once per day to see if a newer framework version is available.   | Keeps your project on the latest improvements without you having to remember to check.                                        |

### Before Claude reads or edits a file

| Hook                  | What it does                                                                                          | Why it matters                                                                                                                  |
| --------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Security Guard**    | Hard-blocks reads or writes to `.env`, `.pem`, `.key`, and other secret files.                        | Prevents Claude from reading or sharing your API keys, passwords, and credentials — even if asked.                              |
| **Config Protection** | Warns when Claude is about to edit a linter, formatter, or compiler config (`.eslintrc`, `tsconfig.json`, etc.). | Quality tools exist for a reason. This nudges Claude to fix the broken code instead of silencing the tool that flagged it.      |
| **FDD Guard**         | Hard-blocks writes that violate Feature-Driven Development rules (see [FDD section](#feature-driven-development-in-plain-language)). | Keeps each feature in its own folder so the codebase stays organized as it grows. No more "where did this file go?"          |

### Before Claude runs a `git commit`

| Hook                | What it does                                                                                                                  | Why it matters                                                                                                                |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Commit Quality**  | Inspects what's about to be committed and blocks the commit if it contains debug code, hardcoded secrets, or `--no-verify`.   | Stops the most common "oops" commits before they touch your repo. You can't accidentally publish an API key or a `console.log`. |

### After Claude edits or writes a file

| Hook                   | What it does                                                                                  | Why it matters                                                                                                              |
| ---------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Auto-Format**        | Runs Prettier (JS/TS) or Ruff/Black (Python) so every file is styled consistently.            | Code looks the same everywhere in the project. No bikeshedding over indentation.                                            |
| **Auto-Lint**          | Runs ESLint (JS/TS) or Ruff (Python) and prints any issues to the session.                    | Common mistakes (unused variables, missing dependencies, unsafe patterns) get flagged the moment they appear.               |
| **Console Warning**    | Notices `console.log`, `console.debug`, or `print()` calls in non-test files and warns.       | Debug statements left in production code leak data and clutter logs. The warning catches them before they ship.             |
| **Session Tracker**    | Appends every file change to the current session log with a timestamp.                        | A complete, time-stamped record of what changed during the session — useful for review, audits, and debugging later.        |
| **Architecture Check** | Validates file location, naming, file size (default ≤400 lines), and import boundaries.       | The codebase doesn't drift into a mess as features pile up. Files stay small and predictable.                               |

### After Claude finishes a response

| Hook                   | What it does                                                                                          | Why it matters                                                                                                            |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Type Check**         | Runs `tsc` (TypeScript) or `mypy` (Python) across the project and reports any type errors.            | Catches a whole class of bugs (wrong data types) before you even open the app to test it.                                 |
| **Test Runner**        | Runs your test suite (Vitest, Jest, pytest, etc.) and reports failures.                               | Regression check — if Claude broke something that used to work, you find out immediately, not three days later.           |
| **Milestone Reminder** | After 5+ file changes without a `/save`, suggests checkpointing.                                      | Prevents losing work, and keeps changes small enough to review.                                                           |
| **Desktop Notify**     | Sends a system notification when Claude finishes.                                                     | You can step away while Claude works and get pinged the moment it's your turn again.                                      |

> **Note on blocking vs. warning.** Some hooks **block** an action (Security Guard, FDD Guard, Commit Quality) — Claude cannot proceed until the issue is fixed. Others only **warn** (Auto-Lint, Console Warning, Type Check, Test Runner) — they print the issue but don't stop the work. The split is deliberate: dangerous mistakes get blocked; quality issues get surfaced so a human can decide.

---

## The 11 slash commands, explained

Commands are short instructions you type in Claude Code (starting with `/`) that trigger a pre-defined multi-step task. They're the things you'll do over and over — bundled so you don't have to spell them out each time.

| Command                  | What it does                                                                                                  | When to use it                                                          | How often            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------- |
| **`/vision`**            | Walks you through defining your project's purpose, audience, tech stack, and phased roadmap. Writes `docs/VISION.md` so every session knows *what* you're building and *why*. | Starting a brand new project. The very first thing you run. | Once per project |
| **`/design`**            | Walks you through creating a design system — style, colors, fonts, animations, component patterns — and writes `design-system/MASTER.md` so every session builds with the same visual language. | After `/vision`, or when you notice visual inconsistency. | Once per project, update as needed |
| **`/buildplan`**         | Reads your vision and design system, walks through user journeys, and generates phased build plans in `docs/plans/`. Phase 1 gets deep implementation detail; later phases get lighter outlines. | After `/vision` and `/design`. Creates the blueprint Claude builds from. | Once per project, refine as you go |
| **`/welcome`**           | Reads the project files and gives you a friendly, plain-language tour: what this project is, how it's organized, what's automated, what to do first. | Your first time on a project, or onboarding a new collaborator.         | Once per person      |
| **`/feature <name>`**    | Scaffolds a new feature folder following FDD rules: `components/`, `hooks/`, `types.ts`, `index.ts`, `QUICK_REF.md`, all wired together. | Whenever you start work on a brand-new feature.                          | A few times a week   |
| **`/quickref <name>`**   | Reads an existing feature's code and writes (or refreshes) its `QUICK_REF.md` — the short doc that explains what the feature does, how it's wired, and what's still missing. | After finishing a feature, or when a feature's docs are out of date.   | Ongoing              |
| **`/test`**              | Helps you write a test **first**, runs it (it should fail), then writes the code to make it pass. Standard test-driven development, automated. | Before adding any non-trivial feature or fix.                            | Daily                |
| **`/audit`**             | Runs a comprehensive code-quality scan: file sizes, type safety, import boundaries, hardcoded secrets, missing error states, FDD violations. Explains the results in plain language. | After big changes, or whenever you want a health check of the codebase. | Weekly               |
| **`/save`**              | Stages your changes (excluding secret files), writes a plain-language commit message, commits, and pushes to GitHub. | Every time you finish a meaningful chunk of work. The Milestone Reminder will nudge you. | Multiple times a day |
| **`/share`**             | Pushes your branch (if needed) and creates a pull request on GitHub with a plain-language description for reviewers. | When a feature is ready for review and merge.                            | Per feature          |
| **`/update`**            | Checks GitHub for a newer framework version, shows you the changelog, and installs the update if you confirm. | When the Version Check hook tells you an update is available, or once a month. | Monthly              |

> **A simple rule of thumb.** Start every project with **`/vision → /design → /buildplan`** — it takes 20 minutes and saves days of wasted work. Use **`/save`** often — it's cheap, it's safe, it's a backup. Use **`/share`** when you want feedback. Use **`/audit`** when you want reassurance that the project is still healthy. Use **`/feature`** any time you start something new — never create feature folders by hand.

---

## Feature-Driven Development in plain language

**Why it exists.** As a project grows, code tends to spread out: a button here, a helper there, a hook somewhere else. Eventually nobody can find anything, and changing one piece breaks three others. FDD prevents that by giving every feature its own self-contained folder. Want to know how the contact form works? Open `src/features/contact-form/` — everything's there. Want to remove it? Delete the folder.

**The structure.** Every feature lives at `src/features/<name>/` with this shape:

```
src/features/contact-form/
├── components/      # The UI pieces (forms, buttons, modals)
├── hooks/           # The data-fetching and state logic
├── types.ts         # TypeScript types this feature uses
├── index.ts         # The "front door" — what other features can import
└── QUICK_REF.md     # A one-page doc: why it exists, how it works, known gaps
```

**The rules (enforced by the FDD Guard hook).**

1. New components **cannot** go in `src/components/` — that folder is reserved for shared design-system primitives (e.g., shadcn/ui).
2. New components **cannot** go in `src/app/` — that folder is reserved for Next.js routing files.
3. Adding files to a feature folder requires that feature to have a `QUICK_REF.md` first. (The `/feature` command creates one for you.)
4. Features import from each other only through their `index.ts` "front door" — never reach into another feature's internals.

**Opting out.** If FDD doesn't fit your project, run `bash setup.sh --no-fdd` at install time, or set `fdd.enabled` to `false` in `.claude/architecture.json`. The hook becomes a no-op.

**Tools that go with it.** Use `/feature <name>` to scaffold, and `/quickref <name>` to keep the docs in sync with the code.

---

## When Claude goes off track (or something gets blocked)

Two things happen sometimes: Claude takes a wrong turn, or a hook stops an action. Here's how to handle each.

### Claude is going in circles — use `/rewind`

If Claude has tried to fix the same thing twice and it's still wrong, **stop**. Don't type another correction. Each correction leaves the broken attempt in the conversation, and Claude starts treating its own broken code as context — which makes things worse, not better.

Instead, press **Esc** twice (or type `/rewind`). You'll see a menu of recent moves. Jump back to before things went sideways. Then re-prompt with what you learned. You'll get a better answer in less time, and your conversation stays clean.

This is the Claude Code team's #1 tip for course correction. Use it freely — checkpoints are cheap.

A useful rule of thumb: **after two failed corrections, rewind.** A clean session with a sharper prompt almost always beats a long session full of dead ends.

### A hook blocked an action — read the message

The hook prints a message explaining what it caught. Most of the time the fix is obvious once you read it.

**FDD Guard blocked a file write.** The message will say something like *"Components must live in `src/features/<name>/components/`."* This means Claude tried to put a feature file in a shared folder. Ask Claude: *"Use the FDD structure — put it under a feature folder."* If you're starting a new feature, run `/feature <name>` first and try again.

**Security Guard blocked a file read.** The message will name the file (`.env`, `.pem`, etc.) and say it's not allowed. This is by design — Claude should never see your secrets. If you're documenting environment variables, edit `.env.example` instead.

**Config Protection issued a warning.** This isn't a block — just a note that Claude is about to change a linter or formatter config. Almost always, the right move is to fix the broken code rather than weaken the rule. Push back: *"Don't change the config. Fix the underlying issue."*

**Commit Quality refused a commit.** The message lists what's wrong: a `console.log` left in, a string that looks like an API key, or a `--no-verify` attempt. Remove the offending lines and try `/save` again.

**Type Check or Test Runner reported failures.** These don't block — they print issues at the end of the response. Read what failed, then ask Claude to fix it. (`"The type check is complaining about X — can you fix it?"` works.)

When in doubt, the rule is: **don't bypass the hook, fix the underlying issue.** That's what they're there for.

---

## Supported stacks

| Stack                             | Formatter     | Linter | Type Checker |
| --------------------------------- | ------------- | ------ | ------------ |
| TypeScript (Next.js, React, Node) | Prettier      | ESLint | tsc          |
| JavaScript                        | Prettier      | ESLint | —            |
| Python                            | Ruff or Black | Ruff   | mypy         |
| HTML/CSS (static sites)           | —             | —      | —            |
| Mixed JS/TS + Python              | Both          | Both   | Both         |

The setup script detects which of these apply and only installs the relevant tools.

---

## What gets generated

| File                           | Purpose                                                                |
| ------------------------------ | ---------------------------------------------------------------------- |
| `CLAUDE.md`                    | Project guide that Claude reads at the start of every session.         |
| `PROJECT_LESSONS.md`           | Tracks corrections so Claude doesn't repeat past mistakes.             |
| `.env.example`                 | Documents required environment variables (real `.env` stays private).  |
| `.claude/settings.json`        | Hook configuration.                                                    |
| `.claude/architecture.json`    | FDD and architecture rules (file size limits, allowed import paths).   |
| `.claude/.framework-version`   | Installed framework version, used by `/update`.                        |
| `.claude/hooks/*.sh`           | The 16 hook scripts.                                                   |
| `.claude/commands/*.md`        | The 11 slash command definitions.                                      |
| `.claude/sessions/*.md`        | Auto-generated session logs (one per session).                         |
| `.claude/backups/`             | Pre-update backups, created automatically by `/update` (gitignored).   |

---

## Session logs and Project Lessons

> **Why is the `.claude` folder hidden?** It starts with a dot, the Unix convention for "configuration folder, please tuck this away." It keeps the framework's plumbing — hooks, commands, settings, session logs — out of your way so you mostly see your own work. The folder isn't secret, just tidied off the visible workspace. Claude Code expects this exact location, so the dot prefix isn't optional.
>
> **To see what's in it:**
> - **Finder (macOS):** press **Cmd + Shift + . (period)** to toggle hidden files.
> - **VS Code or any code editor:** hidden files are shown by default in the file tree.
> - **Terminal:** `ls .claude/sessions/` lists every session log; `cat .claude/sessions/<file>.md` reads one.

**Session logs** live in `.claude/sessions/`. Every session creates one, and every file change Claude makes gets timestamped:

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

These are useful for collaboration (anyone can see what changed when), for debugging (when did this break?), and for review (what did Claude actually do during that long session?).

**`PROJECT_LESSONS.md`** is for corrections. Whenever Claude does something you have to fix or push back on, add a short entry:

```markdown
### Don't use inline styles for the pricing cards

**Date:** 2026-04-11
**What happened:** Claude used inline styles instead of Tailwind classes
**Correction:** Always use Tailwind utility classes for styling, never inline styles
```

Claude reads this file at the start of every session, so the same correction never has to be made twice. Add an entry whenever a mistake is worth preventing — small mistakes are fine to skip; recurring or expensive mistakes are worth recording.

---

## File structure

```
your-project/
├── CLAUDE.md                          # Auto-generated project guide
├── PROJECT_LESSONS.md                 # Corrections tracker
├── .env.example                       # Environment variable docs
└── .claude/
    ├── settings.json                  # Hook configuration
    ├── architecture.json              # FDD and architecture rules
    ├── .framework-version             # Installed framework version
    ├── commands/
    │   ├── vision.md                  # /vision (project vision wizard)
    │   ├── design.md                  # /design (design system wizard)
    │   ├── buildplan.md               # /buildplan (build plan wizard)
    │   ├── welcome.md                 # /welcome
    │   ├── feature.md                 # /feature
    │   ├── quickref.md                # /quickref
    │   ├── test.md                    # /test
    │   ├── audit.md                   # /audit
    │   ├── save.md                    # /save
    │   ├── share.md                   # /share
    │   └── update.md                  # /update
    ├── hooks/
    │   ├── session-init.sh            # Session start: create log
    │   ├── session-plan-reminder.sh   # Session start: plan before coding
    │   ├── version-check.sh           # Session start: check for updates
    │   ├── pre-security-guard.sh      # Block .env / .pem reads & writes
    │   ├── pre-config-protect.sh      # Warn on config file edits
    │   ├── pre-fdd-guard.sh           # Block FDD violations
    │   ├── pre-commit-quality.sh      # Block bad commits
    │   ├── post-format.sh             # Auto-format
    │   ├── post-lint.sh               # Auto-lint
    │   ├── post-console-warn.sh       # Warn on debug statements
    │   ├── post-session-track.sh      # Log file changes
    │   ├── post-architecture-check.sh # Validate file location & size
    │   ├── stop-typecheck.sh          # Run type checker
    │   ├── stop-test.sh               # Run tests
    │   ├── stop-milestone.sh          # Suggest /save after 5+ changes
    │   ├── stop-notify.sh             # Desktop notification
    │   └── audit.sh                   # The script /audit invokes
    ├── backups/                       # Pre-update backups (gitignored)
    └── sessions/
        └── *.md                       # Session logs (auto-generated)
```

---

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- git
- Node.js 18+ (for JS/TS projects)
- Python 3.8+ (for Python projects)

---

## Things worth exploring next

The framework gives you a solid base. Once you've lived with it for a few projects, here are directions worth knowing about — pieces you can layer on top as the work grows. None of these are required.

### The Project Kickoff Wizards (`/vision → /design → /buildplan`)

The framework includes three chained wizards that take a project from idea to implementation-ready blueprint. Each one generates a persistent document that Claude references in every session — so context is never lost between sessions.

**`/vision`** — Start here. Describe your project idea in plain language. The wizard asks five first-principles questions (who is it for, what must it do well, what's the MVP, what's the roadmap) and recommends a tech stack. Generates `docs/VISION.md`.

**`/design`** — Define the visual identity. Describe your aesthetic ("warm premium", "sleek minimal") or just your industry, and the wizard infers the right style, colors, fonts, animations, and component patterns. Uses knowledge from [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill), [Motion AI Kit](https://motion.dev/docs/ai-kit), [shadcn/ui](https://ui.shadcn.com/), and [21st.dev](https://21st.dev/). Generates `design-system/MASTER.md`.

**`/buildplan`** — Create the implementation blueprint. Reads your vision and design system, walks you through user journeys screen by screen, and generates phased build plans. Phase 1 (MVP) gets deep detail: screen specs with design tokens applied, data model, API routes, FDD features, and edge cases. Later phases get lighter outlines. Generates `docs/plans/phase-*.md`.

Once all three exist, any new Claude session can pick up exactly where the last one left off. Open a fresh session and say: *"Read the vision, design system, and build plan. Build the next milestone."*

### Custom subagents

Claude Code supports specialized assistants in `.claude/agents/` — pre-defined personas with their own tools and prompts that Claude delegates to for isolated tasks. Useful ones to add later: a **security-reviewer** for PR checks, an **explorer** for read-only codebase research that doesn't pollute your main session, and a **refactorer** for cleanup runs. The framework doesn't ship these yet — they're worth adding as you spot tasks you do repeatedly.

### Skills with frontmatter

This framework's slash commands work well, but Anthropic's newer pattern is **skills** (`.claude/skills/<name>/SKILL.md` with YAML frontmatter). Skills can auto-invoke when relevant, declare which tools they need, and load conditionally — meaning Claude suggests the right one without you having to remember its name. A natural future step is migrating the framework's commands into skills.

### MCP servers for live context

Beyond local files, Claude Code can connect to **MCP servers** that pull in live context: GitHub (for issues and PRs), Sentry (for production errors), Postgres (for schema introspection), Notion or Linear (for tickets). Add them via `claude mcp add` once, and Claude can reference them in any conversation. Especially handy for *"fix the bug from this Sentry alert"* or *"build the feature this Linear ticket describes."*

### Git worktrees for parallel work

The Claude Code team's single biggest productivity tip: run several Claude sessions at once, each in its own **`git worktree`**. Use `claude --worktree feature-a` to spin up an isolated workspace; changes from one session don't collide with another. Particularly powerful for big refactors, where you can run a writer, a reviewer, and an explorer all at the same time.

---

## License

MIT
