---
name: design-system
description: >
  Bootstrap or refresh DESIGN.md — the project's design tokens, spacing scale,
  typography, and component patterns — so every prototype after it stays visually
  consistent. Use when user says "/design-system", "set up a design system", "create
  design guidelines", or asks for design consistency across features. One-time/rare
  step, not per-feature.
disable-model-invocation: true
---

# design-system — bootstrap DESIGN.md

Write down the visual language once so `prototype`/`implement`/`design-review` all
have a single source of truth instead of each feature inventing its own spacing,
colors, and components.

## Process

1. **Check for `DESIGN.md`** at repo root. If it exists, read it and ask the user
   whether this run should refresh it (re-scan and reconcile drift) or leave it —
   don't silently overwrite.
2. **Existing UI present?** Scan actual CSS/Tailwind config/component library/theme
   files for real values already in use — don't invent tokens the codebase doesn't
   have. Extract: color palette (with usage — primary/danger/muted/etc.), spacing
   scale, font sizes/weights, border-radius values, shadow levels, existing reusable
   components (button variants, form fields, cards) and their states
   (hover/disabled/loading/error).
3. **Greenfield (no existing UI to scan)?** Don't invent a palette from nothing — ask
   a short set of forcing questions: reference sites/products whose look is close to
   the goal, one or two colors that must anchor the palette (brand, none, neutral),
   density preference (compact/spacious), and light/dark/both.
4. **Write `DESIGN.md`**: tokens (color/spacing/type/radius/shadow) as a table, each
   existing component pattern with its states, and a short "do / don't" list of
   concrete anti-patterns to avoid in this project (e.g. "no gradients on buttons",
   "cards always get the level-1 shadow, never level-2"). Keep it a reference doc, not
   prose — something `design-review` can check findings against and `prototype` can
   read before mocking up a new screen.
5. **Report**: whether this was a fresh write or a refresh, what was scanned vs asked,
   and where `DESIGN.md` landed.

## Rules

- Extracted tokens beat invented ones — always prefer what the codebase already does
  over a fresh opinion, even if the existing choice is imperfect. Note drift, don't
  silently "fix" it into something new.
- Keep `DESIGN.md` short enough to be a real reference — tables and a do/don't list,
  not a design essay.
