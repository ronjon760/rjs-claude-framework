---
description: Create or update the project's design system — generates design-system/MASTER.md
argument-hint: optional project description (e.g., "beauty spa website", "SaaS dashboard")
---

Create or update the project's design system by guiding the user through a natural-language-first questionnaire, then generating `design-system/MASTER.md` as the single source of truth for all visual decisions.

## Before You Start

1. Read `.claude/architecture.json` to determine the project stack (nextjs, node, python, static-html, etc.)
2. Check if `design-system/MASTER.md` already exists:
   - If YES: read it, show the current settings (style, palette, fonts), and ask what the user wants to change. Skip to the refinement phase.
   - If NO: proceed with the full wizard below.

## Phase 1: Natural Language Understanding

If the user provided a description argument (e.g., `/design beauty spa website`), use it. Otherwise ask:

> "Describe your project in a sentence or two — what is it, who is it for, and what vibe are you going for?"

From the description, infer these four dimensions:
- **Industry/vertical** — e.g., SaaS, beauty/wellness, fintech, healthcare, e-commerce, portfolio, education, restaurant/food, fitness, real estate, legal, agency/creative
- **Product type** — landing page, dashboard, web app, marketing site, mobile app, portfolio, blog
- **Aesthetic vibe** — warm premium, sleek minimal, playful bold, clinical professional, dark luxe, earthy organic, etc.
- **Target audience** — consumers, businesses, developers, luxury market, young professionals, etc.

## Phase 2: Design Inference

Based on the inferred industry and product type, select recommendations using the reference tables below. Then present your recommendations as a summary for the user to confirm or override.

Present it like this:

```
Based on your description, here's what I'm thinking:

**Style:** [style name]
**Palette direction:** [brief description with primary and accent colors]
**Fonts:** [heading font] (headings) + [body font] (body)
**Animation approach:** [brief description]
**Component source:** shadcn/ui primitives + 21st.dev polished variants

Does this feel right? You can:
- Say "yes" to proceed
- Override specific aspects (e.g., "change the palette to cooler tones")
- Say "show me alternatives" for different options
```

## Phase 3: Guided Refinement

If the user wants changes, present 3-4 targeted options for the specific aspect. For example, if they want palette alternatives:

> Here are palette options that work well for [industry]:
>
> 1. **[Name]** — #hex bg, #hex accent, #hex text
> 2. **[Name]** — #hex bg, #hex accent, #hex text
> 3. **[Name]** — #hex bg, #hex accent, #hex text

Continue until the user confirms. Most projects need 1-2 rounds.

## Phase 4: Generate MASTER.md

Create the `design-system/` directory and write `design-system/MASTER.md` following the structure below. Adapt the content based on the confirmed design choices and the project stack.

### MASTER.md Structure

```markdown
# [Project Name] — Design System

**Style:** [style name]
**Inspiration:** [reference site or aesthetic]
**Vibe:** [3-4 adjective description]

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
| Page transition | 300ms | ease-out | Route change |
| Card entrance | 400ms | ease-out | Scroll into view |
| Staggered list | 100ms gap | ease-out | Scroll / data load |
| Hover lift | 200ms | ease | Mouse enter |
| Button press | 150ms | ease | Mouse down |

### Rules
- All animations respect `prefers-reduced-motion`
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
[Stack-specific items as appropriate]
```

## Phase 5: Finalize

After generating MASTER.md:

1. Update `.claude/architecture.json` — set `design_system.enabled` to `true`
2. Tell the user:
   > Design system created at `design-system/MASTER.md`. Every session will now reference this for consistent UI decisions. Run `/design` again anytime to update it.
3. If `docs/VISION.md` exists but `docs/plans/` does not exist (or is empty):
   > Your vision and design are defined — ready to plan the build? Run `/buildplan` to generate your Phase 1 implementation plan.

---

## Reference Tables

Use these tables to make informed design recommendations. These are curated selections — use your judgment to combine and adapt based on the user's specific description.

### Industry → Style Mapping

| Industry | Primary Styles | Color Mood | Typography Mood |
|----------|---------------|------------|-----------------|
| SaaS / Tech | Glassmorphism, Flat Design, Bento Grid | Trust blue, clean white, accent contrast | Professional, clear hierarchy |
| Beauty / Wellness | Warm Premium, Soft UI, Organic | Warm neutrals, sage/pink/gold accent | Elegant, refined serif or soft sans |
| Fintech / Banking | Glassmorphism, Dark Luxe, Minimalism | Deep navy/slate, gold/green accent | Modern, technical, trustworthy |
| Healthcare / Medical | Minimalism, Flat Design, Clean | Trust blue, clean white, soft green | Professional, accessible, clear |
| E-commerce / Retail | Vibrant, Block-based, Photography-first | Brand primary, success green, warm accent | Engaging, clear hierarchy |
| Restaurant / Food | Warm Premium, Photography-first, Earthy | Earth tones, warm reds/oranges, cream | Inviting, classic serif or friendly sans |
| Portfolio / Creative | Minimalism, Motion-Driven, Brutalism | Neutral + single bold accent | Clean, expressive, distinctive |
| Education / Learning | Flat Design, Friendly, Vibrant | Warm primary, playful accent | Friendly, readable, approachable |
| Fitness / Sports | Bold, Dynamic, Dark Mode | Dark bg, energetic neon/orange accent | Strong, impactful, athletic |
| Real Estate | Warm Premium, Clean, Photography-first | Navy/slate, gold/emerald accent | Professional, trustworthy |
| Legal / Professional | Minimalism, Classic, Conservative | Navy, burgundy, cream, charcoal | Serif headings, classic, authoritative |
| Agency / Creative | Glassmorphism, Brutalism, Experimental | Bold contrasts, unexpected combos | Distinctive, avant-garde |

### Curated Color Palettes

| Name | Background | Surface | Text | Accent | Best For |
|------|-----------|---------|------|--------|----------|
| Warm Bone | `#FAF9F6` | `#FFFFFF` | `#1C1917` | `#059669` emerald | Premium, natural products |
| Cool Slate | `#F8FAFC` | `#FFFFFF` | `#0F172A` | `#2563EB` blue | SaaS, tech, dashboards |
| Midnight | `#0F172A` | `#1E293B` | `#F1F5F9` | `#3B82F6` blue | Fintech, dark luxe apps |
| Warm Sand | `#FFFBF5` | `#FFFFFF` | `#292524` | `#D97706` amber | Food, lifestyle, warmth |
| Rose Garden | `#FFF1F2` | `#FFFFFF` | `#1C1917` | `#E11D48` rose | Beauty, fashion, wellness |
| Forest | `#F0FDF4` | `#FFFFFF` | `#14532D` | `#16A34A` green | Health, organic, eco |
| Ocean | `#F0F9FF` | `#FFFFFF` | `#0C4A6E` | `#0284C7` sky | Travel, calm, professional |
| Charcoal Gold | `#18181B` | `#27272A` | `#FAFAFA` | `#EAB308` yellow | Luxury, premium, exclusive |
| Lavender Mist | `#FAF5FF` | `#FFFFFF` | `#3B0764` | `#7C3AED` violet | Creative, education, wellness |
| Earth Clay | `#FEF2F2` | `#FFFFFF` | `#44403C` | `#B45309` orange | Artisan, handmade, warm |
| Pure Minimal | `#FFFFFF` | `#FAFAFA` | `#171717` | `#171717` black | Portfolio, editorial, minimal |
| Sage Calm | `#F5F5F0` | `#FFFFFF` | `#374151` | `#6B8F71` sage | Wellness, spa, organic |

### Curated Font Pairings

| Heading | Body | Vibe | Best For |
|---------|------|------|----------|
| Outfit | Work Sans | Modern, clean, geometric | SaaS, tech, dashboards |
| Playfair Display | Source Sans Pro | Elegant, editorial | Luxury, fashion, restaurants |
| Inter | Inter | Neutral, system-like | Developer tools, utilities |
| Sora | DM Sans | Friendly, modern | Startups, apps, education |
| Fraunces | Outfit | Warm, distinctive | Artisan, premium, boutique |
| Space Grotesk | General Sans | Technical, sharp | Fintech, analytics, data |
| Bricolage Grotesque | Nunito | Playful, approachable | E-commerce, lifestyle |
| Cabinet Grotesk | Satoshi | Bold, contemporary | Creative agency, portfolio |
| Clash Display | Switzer | Dramatic, striking | Fashion, music, entertainment |
| Cormorant Garamond | Lato | Classic, trustworthy | Legal, real estate, fine dining |
| Plus Jakarta Sans | Plus Jakarta Sans | Rounded, friendly | SaaS, health, education |
| Geist | Geist | Technical, monospaced feel | Developer tools, dashboards |

### Animation Approach by Style

| Style | Motion Philosophy | Key Patterns |
|-------|------------------|-------------|
| Warm Premium | Subtle, organic, scroll-triggered reveals | Slow fades (400ms), gentle lifts, spring easing |
| Glassmorphism | Smooth, floating, depth transitions | Blur transitions, parallax, layer reveals |
| Minimalism | Barely there, purposeful only | Fast fades (200ms), no bounce, opacity only |
| Brutalism | Instant, glitchy, unconventional | Snap transitions, no easing, abrupt |
| Dark Luxe | Cinematic, dramatic, slow | Long fades (600ms+), scale reveals, glow effects |
| Flat Design | Clean, predictable, functional | Standard ease-out, consistent timing |
| Bento Grid | Staggered, grid-aware, cascading | Staggered children (100ms gaps), scale-in cards |

### Component Radius by Style

| Style | Card Radius | Button Radius | Input Radius |
|-------|-------------|---------------|--------------|
| Warm Premium | 12-16px | 8-10px | 8px |
| Glassmorphism | 16-24px | 12px | 12px |
| Minimalism | 4-8px | 4-6px | 4px |
| Brutalism | 0px | 0px | 0px |
| Soft UI | 16-24px | 12-16px | 12px |
| Flat Design | 8-12px | 6-8px | 6px |
| Dark Luxe | 8-12px | 8px | 8px |

---

## Stack-Specific Adaptations

### For React / Next.js / Vite (Tailwind) projects:
- Include Tailwind config extensions (colors, fontFamily) in MASTER.md
- Use Tailwind utility classes for all mappings
- Motion patterns use Motion v12 (`motion/react`)
- Component sources: shadcn/ui + 21st.dev
- Include `"use client"` note for animated components

### For Python web (Django / Flask / FastAPI) projects:
- Use CSS custom properties (`--color-accent`, `--font-heading`, etc.) instead of Tailwind
- Motion section uses CSS `transition` and `@keyframes` (no JS libraries)
- Component patterns are CSS class-based
- No Tailwind config — provide plain CSS values
- Component sources: custom CSS components

### For Static HTML projects:
- Use CSS custom properties for all values
- All styles live in `<style>` tags or a shared CSS file
- Motion uses CSS transitions and `@keyframes` only
- No build tools, no npm, no Tailwind (unless already in project)
- Component sources: custom HTML/CSS patterns

### For React Native projects:
- Use StyleSheet objects instead of CSS/Tailwind
- Colors as hex constants in a theme file
- Motion uses React Native Reanimated or built-in Animated API
- No web-specific patterns (no CSS, no Tailwind)
- Component sources: custom React Native components

---

## Important Notes

- Generate ONLY the design system — do not start building components or writing application code
- The MASTER.md should be complete and self-contained — Claude should be able to reference it without needing any other context to make consistent design decisions
- Keep the file focused and scannable — avoid excessive prose, use tables and code blocks
- All color choices must pass WCAG AA contrast ratio (4.5:1 for text)
- Font selections should come from Google Fonts for easy integration
- When updating an existing MASTER.md, preserve custom sections the user may have added
