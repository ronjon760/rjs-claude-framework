# MASTER.md — annotated structure

The full structure for `design-system/MASTER.md`, with guidance in brackets. The placeholder template is at `${CLAUDE_PLUGIN_ROOT}/templates/design-system/MASTER.md.template`. Adapt the content to the confirmed choices and the project's stack (see `stack-adaptations.md`).

````markdown
# [Project Name] — Design System

**Style:** [style name]
**Inspiration:** [reference site or aesthetic]
**Vibe:** [3-4 adjective description]

---

## Design Conviction

> The one committed creative direction for this project. Every UI decision serves
> it. The `frontend-design` skill executes *within* this conviction — it sharpens
> craft and distinctiveness but does not override the choices locked below.

**Commit to:** [one bold, specific creative direction — the idea everything serves]

**Avoid (anti-generic guardrails):**
- Generic defaults: no Inter / Roboto / Arial as primary fonts; no purple-on-white clichés.
- Timid, evenly-distributed palettes — commit to a dominant tone + one sharp accent.
- Predictable, perfectly-symmetrical layouts everywhere — earn one or two confident,
  unexpected compositional moments per page.
- Scattered micro-animations — prefer one well-orchestrated high-impact moment over many small ones.

**See also:** the framework's design-lanes guide (github.com/ronjon760/rjs-claude-framework/blob/main/templates/docs/design-lanes.md) for how `/rjs:design`, `frontend-design`, and
`ui-ux-pro-max` divide responsibility.

---

## Color Palette

### Core Colors

| Role | Hex | [Tailwind or CSS var] | Usage |
|------|-----|-----------------------|-------|
| Background | `#hex` | [mapping] | Page background |
| Surface | `#hex` | [mapping] | Cards, modals, inputs |
| Border | `#hex` | [mapping] | Card borders, dividers |
| Text | `#hex` | [mapping] | Headings, primary text |
| Text-muted | `#hex` | [mapping] | Secondary text, labels |
| Accent | `#hex` | [mapping] | CTAs, links, active states |
| Accent-hover | `#hex` | [mapping] | CTA hover |
| Accent-soft | `#hex` | [mapping] | Accent backgrounds |

[Include Tailwind config extension for JS/TS projects, or CSS custom properties for Python/HTML projects]

[Include gradient usage notes if relevant to the style]

---

## Typography

### Font Stack

| Role | Font | Weight | Size (desktop) | Size (mobile) |
|------|------|--------|----------------|---------------|
| Display | [heading font] | 700 | 48-64px | 32-40px |
| H1 | [heading font] | 600 | 36-48px | 28-32px |
| H2 | [heading font] | 600 | 28-32px | 22-26px |
| H3 | [heading font] | 500 | 20-24px | 18-20px |
| Body | [body font] | 400 | 16px | 16px |
| Body-sm | [body font] | 400 | 14px | 14px |
| Label | [body font] | 500 | 12-14px | 12px |

[Include framework-appropriate config: Tailwind fontFamily for JS/TS, CSS @font-face for HTML/Python]

### Google Fonts Import

[Google Fonts @import URL with the selected fonts and weights]

### Line Heights
- Headings: 1.2
- Body: 1.6
- Labels: 1.4

### Letter Spacing
- Display/H1: -0.02em
- Body: 0 (default)
- Labels/Caps: 0.05em

---

## Spacing & Layout

| Property | Value |
|----------|-------|
| Border radius (cards) | [value] |
| Border radius (buttons) | [value] |
| Border radius (inputs) | [value] |
| Card shadow | [value] |
| Card shadow (hover) | [value] |
| Section spacing | [value] |
| Card padding | [value] |
| Max content width | [value] |
| Responsive breakpoints | 375px, 768px, 1024px, 1440px |

---

## Motion / Animation

### Specs

| Animation | Duration | Easing | Trigger |
|-----------|----------|--------|---------|
| Page transition | 300ms | `--ease-out` | Route change |
| Card entrance | 400ms | `--ease-out` | Scroll into view |
| Staggered list | 60ms gap | `--ease-out` | Scroll / data load |
| Hover lift | 200ms | `--ease` (default) | Mouse enter |
| Button press | 150ms | `--ease-out` | Mouse down |

### Easing Curves

Built-in CSS easings are too weak. Use these custom curves as tokens.
**Avoid `ease-in` for UI** — it delays the first frame the user is watching.

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);      /* entrances, exits, presses */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);  /* on-screen movement / morphs */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);   /* sheets, drawers, panels */
```

[For Tailwind projects, also extend `transitionTimingFunction` with these curves.]

### Rules
- All animations respect `prefers-reduced-motion`
- Keep UI animations under 300ms (a 180ms dropdown feels more responsive than a 400ms one)
- No GPU-heavy effects (blur, 3D transforms in bulk)
- Use `transform` and `opacity` only for hardware acceleration
[For React/Next.js: - Import from `motion/react` (Motion v12 — NOT `framer-motion`)]
[For React/Next.js: - `"use client"` directive required for any component using Motion]
[For static HTML: - Use CSS `@keyframes` and `transition` properties]
[For Python web: - Use CSS transitions and animations, no JS animation libraries required]

[For React/Next.js projects, include code patterns:]

### Motion Patterns (Motion v12)

**Scroll reveal:**
```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  whileInView={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4 }}
  viewport={{ once: true }}
/>
```

**Staggered list:**
```tsx
const container = { visible: { transition: { staggerChildren: 0.1 } } }
const item = { hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0 } }
```

---

## Component Sources

- **shadcn/ui** — Base primitives (Button, Input, Card, Dialog, etc.)
- **21st.dev** — Search for polished variants matching the design system before building custom
- **Custom** — Only when no suitable primitive exists

### Discovery Pattern
Before building any new component:
1. Check shadcn/ui for a base primitive
2. Search 21st.dev for a polished variant matching the design system
3. Only build custom if neither source has what you need

### Component Patterns

| Component | Style | Source |
|-----------|-------|--------|
| Cards | [surface color], [radius], [shadow], [border behavior] | 21st.dev |
| Buttons (primary) | [accent fill], [text color], [radius] | 21st.dev |
| Buttons (secondary) | [surface fill], [accent border], [accent text] | 21st.dev |
| Inputs | [bg], [border], [radius], [focus ring] | 21st.dev |
| Icons | Lucide React (no emojis as icons) | lucide-react |

---

## Pre-Delivery Checklist

- [ ] No emojis used as icons (use SVG icon library)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Text contrast 4.5:1 minimum (WCAG AA)
- [ ] Focus states visible for keyboard navigation
- [ ] prefers-reduced-motion respected
- [ ] Responsive tested: 375px, 768px, 1024px, 1440px
- [ ] Accent color consistent across all interactive elements
- [ ] Selected fonts loaded correctly
- [ ] Output serves the Design Conviction (distinctive, not generic AI default)
- [ ] Custom easing curves used (no weak built-in `ease-in`/`ease-out` on key motion)
[Stack-specific items as appropriate]
````
