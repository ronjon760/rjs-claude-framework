---
name: checkpoints
description: List or restore the automatic snapshots RJ's Claude Framework takes of uncommitted work at the end of every session. Use when the person lost work, wants to see an earlier state, or asks "can I get back what I had yesterday?"
argument-hint: optional — a file or a time like "yesterday"
allowed-tools: Bash(git for-each-ref:*), Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(git status:*)
---

# Checkpoints

When a session ends with uncommitted changes, the plugin snapshots them into a private git ref, `refs/rjs-checkpoints/<date-time>`. Snapshots include new files (secret files are left out), never change the branch or working folder, and are never pushed. The newest 30 are kept.

These complement Claude Code's own tools: `/rewind` (Esc Esc) undoes edits within a session, and `/resume` reopens an earlier conversation. Use checkpoints when work was lost between sessions or by a shell command `/rewind` can't track.

Request: $ARGUMENTS

## List

```
git for-each-ref --sort=-refname refs/rjs-checkpoints --format='%(refname:short)  %(subject)'
```

Show them as a friendly list (date, time, branch). For a specific one, `git show --stat <ref>` shows which files it holds and `git diff HEAD <ref> -- <file>` shows how a file differed.

## Restore

Restoring overwrites files in the working folder, so first show exactly which files will change and get a clear yes.

- One file: `git checkout <ref> -- <path>`
- Everything in the snapshot: `git checkout <ref> -- .` (only after the person confirms; uncommitted changes to those files are replaced)

The git guard will ask before the "everything" form runs — that's expected. Afterwards, summarize what came back in plain language and suggest `/rjs:save`.

If there are no checkpoints, say so and mention `/rewind` and `/resume` as the other places work can be recovered from.
