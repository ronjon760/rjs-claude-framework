---
name: init
description: Set up (or upgrade) this project for RJ's Claude Framework — writes CLAUDE.md, .claude/rules/, secret-file permission rules, architecture config, and optional CI, and migrates old v2 installs. Run once per project, and again after a framework update.
argument-hint: optional — "ci" to include GitHub Actions without asking
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh *), Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-stack.sh *)
---

# Set up this project

The plugin already provides the hooks, skills and reviewer agent. What a plugin can't ship is the per-project part — `CLAUDE.md`, `.claude/rules/`, permission rules and CI files — so this skill writes those. It never overwrites a file that already exists, so it's safe to run again.

User's note: $ARGUMENTS

## 1. Look before asking

Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-stack.sh" .` and glance at the README and package/dependency files so you know the stack. Note whether this is an old v2 install (`.claude/hooks/pre-security-guard.sh` or `.claude/.framework-version` exists).

## 2. Confirm the choices in one short message

Propose sensible defaults and let the person adjust:

- **Feature folders** (each feature self-contained with its own QUICK_REF.md) — on by default for app stacks; suggest off for tiny projects or libraries.
- **GitHub Actions CI** — lint, type check, tests, build, dependency audit on every pull request, plus a secret scan and Dependabot. Recommend yes whenever the project is (or will be) on GitHub.
- **Claude security review on pull requests** — optional. It needs an Anthropic API key stored as a GitHub secret and uses API credit, so only suggest it when the project handles logins, payments, or personal data.

If the user's note says "ci", skip asking about CI.

## 3. Run the setup

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh" [--no-fdd] [--with-ci] [--with-security-review]
```

The script migrates a v2 install automatically: old hooks, commands and session logs move to `.claude/backups/`, and old framework hooks are removed from `.claude/settings.json` while the person's own settings stay.

## 4. Finish what a script can't

- **CLAUDE.md**: replace the `TODO` line with one sentence on what the project is and who it's for. Add only gotchas Claude would genuinely get wrong; keep it short (well under 200 lines). If the project already had a CLAUDE.md, leave it alone except to suggest removing outdated v2 sections (session logs in `.claude/sessions/`, `/vision`-style command names without `rjs:`).
- **Old lessons**: if `PROJECT_LESSONS.md` exists, copy its lessons into `.claude/rules/lessons.md` as one-line bullets (create it from `${CLAUDE_PLUGIN_ROOT}/templates/rules/lessons.md`), then suggest deleting the old file. Rules files load automatically; the old file never did.
- **Test runner**: if there's none, offer to set one up (Vitest for JS/TS, pytest for Python) so verify-on-stop and CI have something to run.
- **UI projects**: suggest Anthropic's `frontend-design` plugin — `/plugin install frontend-design@claude-plugins-official`.
- **jq**: if the script warned that jq is missing, explain that the safety checks need it and give the install link.

## 5. Protect the main branch (ask first)

If the project is on GitHub and `gh` is available, offer to require pull requests and passing CI before anything merges into `main`. This changes repository settings, so do it only after a clear yes, and explain it in one sentence: "This makes GitHub refuse changes to main unless they come through a reviewed pull request with green checks."

## 6. Wrap up in plain language

Tell the person what was set up and what it means for them — for example: "Claude now can't read your secret files, checks its own work before handing back, and every pull request gets tested automatically." List anything they need to do themselves (add a GitHub secret, install jq). Suggest `/rjs:save` to commit the new files, then `/rjs:vision` if there's no `docs/VISION.md` yet.
