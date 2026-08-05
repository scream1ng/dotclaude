---
name: prototype
description: >
  Turn a plan/feature discussion into a picture-driven HTML mockup, saved under plan/.
  Use when user says "/prototype", "make a prototype", "mock this up", "show me what
  it'll look like" after a plan has been discussed. Low-text, visual-first output.
---

# prototype — plan → visual HTML mockup

Convert the plan already discussed in this conversation into a static, self-contained
HTML mockup. This is NOT working code — no real API calls, no real data. It exists so
the user can look at shapes/layout/flow before any implementation happens.

## Process

1. **Pull the plan from context.** Don't re-ask what was already decided — use the
   screens, fields, nav placement, and data shown in the just-discussed plan. If no plan
   is in context, ask one question for the feature — don't invent one.
2. **Find the project's real design source before writing any CSS.** Look for an
   existing global stylesheet (e.g. `static/css/theme.css`) and existing row/nav/list
   render functions in its JS (e.g. `mbrowHtml`, `moreRowHtml`, icon-path tables,
   rail/nav renderers). If the project has no shared component library — conventions
   enforced by copying an existing screen rather than a build step — read one real
   reference screen end-to-end before writing the mockup. `DESIGN_SYSTEM.md`/`CLAUDE.md`
   (if present) name brand tokens and which screen is canonical — use them to find the
   right files, don't stop at reading the token tables.
3. **Build ONE self-contained HTML file** — `<link>` the project's real stylesheet by
   relative path (must still open via plain `file://`, no server, no build step) and
   copy the project's real row/nav render functions **verbatim** into an inline
   `<script>`, driving them off small sample-data arrays shaped like real API
   responses. Do NOT hand-roll approximate CSS/markup from a token table — reusing the
   actual CSS + actual render functions is what makes the mockup look like the real
   app instead of a plausible-looking guess.
   - Picture-driven, minimal text: sample content in the exact shape real data will
     have (row = icon + title + sub + date, not "Row 1 Row 2 Row 3").
   - If the plan spans multiple screens/states (e.g. mobile list + desktop, empty state,
     populated state), render each as its own labeled frame/section stacked on the page —
     don't write prose describing them.
   - **If real screens gate mobile vs desktop markup on a runtime-toggled class**
     (e.g. `html.compact` flipped by a resize listener the static mockup won't run),
     framing several real screens side-by-side needs that class forced explicitly per
     frame — set it globally to match whichever mode is more common across frames, then
     add a scoped CSS override (`.proto-frame.desktop .dt-only{display:block!important}`
     etc.) that flips the minority frames back. Check for this class before assuming a
     frame "isn't rendering" — a blank mobile or desktop frame is usually this, not a
     missing element.
   - **The real stylesheet likely locks `html`/`body` height and overflow for the
     app's own fixed-shell layout** (single-screen SPA behavior) — this breaks
     page scroll on a mockup page stacking multiple frames. After the `<link>`,
     add an override: `html, body { height: auto !important; overflow: auto !important;
     position: static !important; }`. Do this by default whenever linking a real
     app stylesheet into a multi-frame mockup, don't wait for the user to report
     it's unscrollable.
   - If the plan has a flow/architecture shape worth showing (data merge, nav path),
     draw it as a simple boxes-and-arrows diagram (inline SVG or CSS), not a paragraph.
   - Trivial interactivity (tab/frame switching via CSS `:target` or a few lines of JS)
     is fine if it makes the mockup easier to read. No fetch/state/real logic.
4. Embed the plan's decisions as an HTML comment block at the top of the file
   (screens, fields, nav placement, anything left open) so the file is self-sufficient
   for `/implement` in a later session, without needing this conversation.
5. **Save to `plan/<feature-kebab-name>.html`** at repo root (create `plan/` if missing).
   One file per feature/prototype round — if iterating on the same feature, overwrite
   the same file rather than creating `-v2`.
6. Tell the user the path and to open it directly in a browser. Do not publish as an
   Artifact unless asked — this file is meant to live in the repo plan/ history.

## Rules

- No implementation code (no Flask routes, no real JS wiring, no DB). Pure mockup.
- If the plan left something open, mark it visually with a placeholder/note rather
  than inventing detail.
