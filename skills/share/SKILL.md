---
name: share
description: Share the user's work for review — run a fresh-eyes review of the branch, then open a plain-language pull request on GitHub.
argument-hint: optional title for the pull request
disable-model-invocation: true
---

# Share

Open a pull request (PR) so collaborators can review the work. A pull request is like raising your hand and saying "I made some changes — can you look at them before we add them to the main project?"

PR title from the user, if given: $ARGUMENTS

## 1. Get the branch ready

- If there are uncommitted changes, save them first using the same approach as `/rjs:save` (plain-language message, secrets left unstaged).
- If the user is on the default branch (`main`/`master`), a PR needs a separate branch. Offer to create one from the current work and move the commits there.
- Push the branch if it hasn't been pushed.
- If a PR already exists for this branch (`gh pr view`), share its link and stop.

## 2. Fresh-eyes review

Before opening the PR, delegate a review of the branch diff (against the default branch) to the `reviewer` subagent. It reads the changes in a fresh context, without the assumptions built up while writing them, and reports correctness, security, testing, and project-rule issues ranked by severity.

If the diff touches authentication or permissions, payments, user or customer data, secrets or credentials, or network/API boundaries, also suggest running Claude Code's built-in `/security-review` for a dedicated security pass.

Report the findings to the user in plain language — what each one means and why it matters — and let them decide whether to fix anything before sharing or open the PR as is. If there are no real findings, say so briefly and continue.

## 3. Open the PR

Use the user's title, or write a short descriptive one. Write the description in plain language, understandable by someone who doesn't code (explain any technical term in parentheses):

```markdown
## What this does (the simple version)
[1–2 sentence summary anyone can understand]

### What changed
[Bullet points explaining each change in plain language]

### Why we did it
[Why these changes matter]

### What this means for you
[What's different for users or developers going forward]
```

If the review found something the user chose not to fix yet, list it under a short "Known follow-ups" section so reviewers see it.

Create the PR with `gh pr create` and share the link. Follow the plain-language rule in `CLAUDE.md`, and Claude Code's attribution settings for any attribution line.
