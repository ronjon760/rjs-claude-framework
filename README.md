# RJ's Claude Framework

Build real, trustworthy software with [Claude Code](https://code.claude.com) — even if you don't code.

You describe what you want. Claude builds it. The framework makes sure it's done safely.

## Install

In Claude Code, inside your project:

```
/plugin install rjs --marketplace ronjon760/rjs-claude-framework
/rjs:init
```

That's it. `/rjs:init` asks a couple of questions and sets up your project.

## What it does for you

- **Keeps your secrets safe.** Claude can't read or commit passwords and API keys.
- **Checks its own work.** If Claude breaks a test, it fixes it before telling you it's done.
- **Stops risky moves.** No skipping safety checks, no overwriting the main project, no throwing away your work without asking.
- **Keeps the code organized,** so it doesn't turn into a mess as it grows.
- **Backs up your work** automatically at the end of every session.

## Commands

| Type | To |
|---|---|
| `/rjs:vision` | Plan what you're building and for whom |
| `/rjs:design` | Pick the look and feel |
| `/rjs:buildplan` | Turn the plan into steps |
| `/rjs:feature <name>` | Start a new feature |
| `/rjs:test` | Write tests first, then the code |
| `/rjs:save` | Save your work to GitHub |
| `/rjs:share` | Get a review and open a pull request |
| `/rjs:audit` | Health-check the whole project |

More: `/rjs:adr` (record a decision), `/rjs:checkpoints` (restore a backup), `/rjs:compliance` (privacy policy and terms), `/rjs:welcome` (tour for someone new).

## Tips

- **Big change? Ask for a plan first.** Small change? Just ask.
- **Went wrong?** Press **Esc Esc** to rewind, then try again with a clearer ask.
- **Pick up where you left off** with `/resume`.
- **Claude made a mistake you don't want repeated?** Say "add that to the lessons."

## Need

- Claude Code 2.1.295 or newer (`claude update`)
- `git` and `jq` ([get jq](https://jqlang.org/download/)) · Windows: [Git for Windows](https://git-scm.com/download/win)

Turn on auto-updates once: `/plugin` → Marketplaces → rjs-claude-framework → enable auto-update.

**Upgrading from v2?** Run the two install lines above in your project. Your old setup is backed up, not deleted.

**Want the details?** See [How it works](docs/how-it-works.md).

## License

MIT
