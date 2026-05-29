# Design Lanes — how our design tools fit together

We have three design tools that *look* overlapping but do different jobs. This
doc defines their lanes so they reinforce each other instead of competing.

```
   DECIDE                     EXECUTE                    REFERENCE
   ──────                     ───────                    ─────────
   /design  ───writes──▶   MASTER.md   ◀──obeys───  frontend-design     ui-ux-pro-max
   (wizard)                (the contract:             (taste / anti-slop /  (deep catalog:
   run ONCE               single source              distinctiveness,       palettes, fonts,
   per project             of truth)                 runs on EVERY          styles — pulled
                                                     UI build)              on demand)
```

## The three lanes

### 1. DECIDE — `/design` (the framework wizard)
- A one-time interview that picks this project's style, palette, fonts, and motion.
- **Owns `design-system/MASTER.md`.** It is the only tool that *generates* it.
- Bakes a **Design Conviction** (one committed creative direction) into MASTER.md
  so the contract itself is bold, not safe-by-default.

### 2. EXECUTE — `frontend-design` (Anthropic official skill)
- The craftsman. Fires automatically on every UI build/styling task.
- Pushes for distinctive, production-grade, anti-"AI-slop" execution.
- **Works *within* the contract** — it sharpens spacing, hierarchy, motion polish,
  and distinctiveness; it does **not** override the palette/fonts MASTER.md locked.
- No runtime tug-of-war: MASTER.md is already written with Anthropic's conviction,
  so executing the contract *is* executing the bold direction.
- Installed automatically by the framework's `setup.sh`.

### 3. REFERENCE — `ui-ux-pro-max` (catalog skill, optional)
- A deep library (palettes, font pairings, styles) used **on demand only**.
- `/design` and `frontend-design` pull from it when the built-in tables aren't enough.
- **Never generates `MASTER.md`.** Reference, not a second source of truth.

## Rules of the road

1. **`MASTER.md` is the single source of truth.** One generator (`/design`), one file.
2. **`frontend-design` defers to `MASTER.md`** on palette, fonts, and locked tokens;
   it has free rein on execution quality and micro-detail.
3. **`ui-ux-pro-max` is a library, not a generator.** Cite it; don't let it write the contract.
4. **Conviction over convention.** `/design` commits to one bold direction rather than
   defaulting to safe/generic choices (no Inter/Roboto/Arial as defaults, no
   purple-on-white clichés, dominant color + sharp accent).

## Why this blend

Anthropic's `frontend-design` exists to stop AI from producing interfaces that all
look the same. Instead of letting it fight a safe, conventional `MASTER.md` at build
time, we move its conviction *upstream* into `/design`, so the whole pipeline pulls
one bold direction: decide boldly → record it → execute it faithfully.
