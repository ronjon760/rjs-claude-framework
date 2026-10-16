# Stack-specific adaptations

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
