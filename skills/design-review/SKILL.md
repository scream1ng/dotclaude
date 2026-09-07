---
name: design-review
description: >
  Audit a prototype or live screen against DESIGN.md (or general heuristics if none
  exists) — spacing, hierarchy, contrast/accessibility, consistency, and AI-slop
  patterns (generic gradients, cliché icons, overused shadows). Reports issue + fix
  per finding, doesn't edit code. Use when user says "/design-review", "review this
  design", or "audit this prototype/screen" — a mockup in `plan/`, a running dev URL,
  or anything in between; not tied to a specific point in any workflow. $ARGUMENTS
  names the file/URL to review; if omitted, use the most recently modified file in
  `plan/`.
---

# design-review — design audit, findings only

Catch design problems before they're built, not after. Reads, doesn't edit.

## Process

1. **Locate the target.** Use `$ARGUMENTS` if given. Otherwise the most recently
   modified file in `plan/`; if it's a live screen instead, use the browser tools
   (load `mcp__claude-in-chrome__*` via ToolSearch if deferred) to view it.
2. **Load ground truth.** Read `DESIGN.md` at repo root if it exists — every finding
   below should reference it directly ("spacing here is 6px, DESIGN.md's scale has no
   6px step, nearest is 8px"). If `DESIGN.md` doesn't exist, note that and fall back to
   general heuristics (contrast ratios, spacing rhythm, hierarchy, restraint).
3. **Check each dimension**, one finding per real issue (skip dimensions with nothing
   wrong — don't manufacture filler findings):
   - **Consistency** — tokens/components used match `DESIGN.md`, not one-off values
   - **Hierarchy** — primary action is visually primary, not competing with 3 other
     elements at equal weight
   - **Spacing rhythm** — consistent scale, not arbitrary pixel values
   - **Contrast/accessibility** — text/background contrast, tap target size, focus
     states visible
   - **AI-slop patterns** — generic purple gradients, cliché stock icons, decorative
     shadows/blur with no function, emoji used as UI icons, centered-everything layouts
     with no asymmetry or intent
4. **Report** as a findings list: element/screen → problem → concrete fix (not vague
   "improve spacing" — say "8px → 16px to match DESIGN.md's card padding token"). If
   nothing's wrong, say so plainly instead of padding the list.

## Rules

- Findings only — this skill does not edit files. If asked to also fix, that's
  `implement`'s job (or a follow-up prompt), not this skill silently expanding scope.
- No `DESIGN.md` yet and this is a recurring gap → suggest running `/design-system`
  once, don't re-derive tokens from scratch every review.
