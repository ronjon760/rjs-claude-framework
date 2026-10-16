---
name: save
description: Save the user's work — commit all changes with a plain-language message and push to GitHub.
argument-hint: optional message describing what you did
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git branch:*), Bash(git remote:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git switch:*)
---

# Save

Commit the user's changes and push them, so their work is backed up.

User's note about the work, if given: $ARGUMENTS

## Steps

1. Run `git status`. If nothing changed, say "Nothing new to save — you're up to date." and stop.
2. **Keep secrets out.** Scan the `git status` output for `.env`, `.env.*` (other than `.env.example`), private keys (`*.pem`, `*.key`, `id_rsa*`), credential JSON files, or anything else that looks like a secret. Leave those unstaged and tell the user which files you skipped and why. If one isn't covered by `.gitignore`, suggest adding it.
3. Stage the remaining changed files by name rather than with a blanket `git add -A`, so a secret that slipped past `.gitignore` can't ride along.
4. Look at the diff to understand what was done, then write the commit message in plain language: what changed, in simple terms, and why it matters. Use the user's note as the basis if they gave one. Follow the plain-language rule in `CLAUDE.md`.
5. For attribution, follow Claude Code's own attribution settings — don't hand-write a co-author line with a model name.
6. Commit, then push the current branch (set the upstream with `git push -u origin <branch>` on its first push).
7. Confirm: "Saved! Your work is backed up on [branch name]."

## Working on the main branch

If the current branch is the default branch (`main` or `master`) and the project has a remote, save as asked — but mention once, briefly, that working on a separate branch and opening a pull request with `/rjs:share` lets someone (or a fresh-eyes review) check changes before they reach the main project. Offer to create a branch for the next piece of work. This is a suggestion, not a blocker.

If there's no remote yet, commit locally and explain that the work is saved on this computer but not backed up online until a GitHub repository is connected.
