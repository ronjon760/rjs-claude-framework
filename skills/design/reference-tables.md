# Design reference tables

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

> **Anti-generic note:** Inter and Geist are neutral utility faces — fine for dense
> dashboards, but **avoid them as the primary identity font** for marketing/brand
> surfaces. Pick a distinctive display face (Fraunces, Clash Display, Cabinet Grotesk,
> Bricolage Grotesque, Playfair) so the project doesn't read as generic AI output.
> Avoid defaulting to Roboto or Arial.

### Animation Approach by Style

| Style | Motion Philosophy | Key Patterns |
|-------|------------------|-------------|
| Warm Premium | Subtle, organic, scroll-triggered reveals | Slow fades (400ms), gentle lifts, spring easing |
| Glassmorphism | Smooth, floating, depth transitions | Blur transitions, parallax, layer reveals |
| Minimalism | Barely there, purposeful only | Fast fades (200ms), no bounce, opacity only |
| Brutalism | Instant, glitchy, unconventional | Snap transitions, no easing, abrupt |
| Dark Luxe | Cinematic, dramatic, slow | Long fades (600ms+), scale reveals, glow effects |
| Flat Design | Clean, predictable, functional | Standard ease-out, consistent timing |
| Bento Grid | Staggered, grid-aware, cascading | Staggered children (60ms gaps), scale-in cards |

> **Easing note:** Whatever the style, implement motion with the **custom easing
> curves** from the Motion section (`--ease-out`, `--ease-in-out`, `--ease-drawer`),
> not the weak built-in CSS easings. Keep UI animations under 300ms and stagger gaps
> short (30–80ms). Avoid `ease-in` for UI.

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
