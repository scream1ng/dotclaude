---
name: prototype
description: >
  Turn a plan/feature discussion into a picture-driven HTML mockup (3 radically
  different variants by default) or, for logic/state questions, a clickable state demo,
  saved under plan/. Use when user says "/prototype", "make a prototype", "mock this up",
  "show me what it'll look like", "give me a few layout options", or "does this
  logic/state machine/flow hold up" after a plan has been discussed. Low-text,
  visual-first output.
---

# prototype — plan → visual HTML mockup

Convert the plan already discussed in this conversation into a static, self-contained
HTML mockup. This is NOT working code — no real API calls, no real data. It exists so
the user can look at shapes/layout/flow before any implementation happens.

## Pick a mode

- **"What should this look like?"** → UI mockup, the Process below. Default.
- **"Does this logic / state model hold up?"** (status transitions, edge cases, what's
  legal when) → [LOGIC.md](LOGIC.md): a clickable state demo instead of a mockup.

If ambiguous: a screen/page in the plan → UI; a status flow or backend rule → logic.
State the assumption at the top of the file.

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
   - **The real stylesheet may lock `html`/`body` height, overflow, or scroll
     chaining for a fixed-shell app.** For a multi-frame mockup, restore one page
     scroller after the `<link>`: `html { height: auto !important; overflow-y: auto
     !important; overscroll-behavior: auto !important; } body { height: auto
     !important; overflow: visible !important; overscroll-behavior: auto
     !important; }`. Override `position` too if the app fixes either element.
     Check wheel or trackpad scrolling in the browser; Page Down alone can work
     even when pointer scrolling is blocked.
   - If the plan has a flow/architecture shape worth showing (data merge, nav path),
     draw it as a simple boxes-and-arrows diagram (inline SVG or CSS), not a paragraph.
   - Trivial interactivity (tab/frame switching via CSS `:target` or a few lines of JS)
     is fine if it makes the mockup easier to read. No fetch/state/real logic.
   - **Build 3 radically different variants** (cap 5) in the same file, each rendering
     all the plan's frames. Variants must disagree on *structure* — layout,
     information hierarchy, primary affordance — not colour or copy. If two drafts come
     out alike, redo one with explicit "don't use <that layout>" guidance. Share small
     pieces (real row renderers) freely; don't share the layout. Build only 1 if the
     plan already pinned the layout or the user asks for one.
   - **Variant switcher:** a fixed bottom-centre pill — `‹` · current label (e.g.
     `B — sidebar list`) · `›` — wrapping around, plus `←`/`→` keys (ignored while an
     input/textarea/contenteditable is focused). Store the variant in `location.hash`
     (`#variant=B`) so it's reload-stable and works on `file://`. Style it visibly
     unlike the app so it isn't mistaken for part of the design.
4. Embed the plan's decisions as an HTML comment block at the top of the file
   (screens, fields, nav placement, anything left open, and one line per variant
   describing its structure) so the file is self-sufficient for `/implement` in a
   later session, without needing this conversation. Include `Chosen variant: TBD`.
5. **Save to `plan/<feature-kebab-name>.html`** at repo root (create `plan/` if missing).
   One file per feature/prototype round — if iterating on the same feature, overwrite
   the same file rather than creating `-v2`.
6. Tell the user the path and to open it directly in a browser. Do not publish as an
   Artifact unless asked — this file is meant to live in the repo plan/ history.
7. **When the user picks** (often "header from B, list from C"), update the comment
   block's `Chosen variant:` line with the pick and any stolen pieces, so `/implement`
   builds that and not variant A by default.

## Rules

- No implementation code (no Flask routes, no real JS wiring, no DB). Pure mockup.
- If the plan left something open, mark it visually with a placeholder/note rather
  than inventing detail.
