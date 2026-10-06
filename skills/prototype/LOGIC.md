# prototype — logic mode: plan → clickable state demo

For when the question is **"does this logic / state model hold up?"** — status
transitions, edge cases, what's legal when. Looks fine on paper, feels wrong once you
push real cases through it. Output is one self-contained HTML file anyone (including
a non-developer) can open and click.

If the question is "what should this look like", use the UI mode in [SKILL.md](SKILL.md).

## Process

1. **State the question** in one paragraph, visible at the top of the page (not just a
   comment) — which state model, which doubt. Pull it from the plan in context; if
   none, ask one question — don't invent one.
2. **Write the logic as a pure module** in its own `<script>` block — a reducer
   `(state, action) => state`, an explicit state machine (when "which actions are
   legal now" is the question), or a few pure functions over a plain data type. No
   DOM, no `document`, no handlers inside it; the page calls in, nothing calls out.
   This block is the part `/implement` can lift; the page around it is throwaway.
3. **Build the page** — plain HTML/CSS/JS, everything inline, opens via `file://`:
   - **Title + the question** from step 1.
   - **Current state** — labelled fields in domain language (not a raw JSON dump),
     re-rendered after every click, with what just changed highlighted.
   - **Free-play buttons** — one per action, always available. Illegal actions show
     why they were rejected rather than silently doing nothing.
   - **Guided scenarios** — one tab each: a plain-language setup and what to watch
     for, then the ordered buttons to press. Starting a scenario resets to a known
     initial state. Pick the awkward cases: happy path, a tricky edge case, an attempt
     at something that should be illegal.
   - Restrained styling: clean type, generous spacing, one accent colour, no animation.
4. **Embed decisions** as an HTML comment block at the top (states, actions, rules,
   anything left open), same as UI mode, so `/implement` and `/to-plan` can use it
   without this conversation.
5. **Save to `plan/<feature-kebab-name>-logic.html`**; overwrite on iteration, no `-v2`.
6. Tell the user the path. When they hit "wait, that shouldn't be possible", fix the
   module, add that case as a scenario, and update the comment block.

## Rules

- No tests, no DB, no fetch — in-memory state only.
- One question; no "what if we later need X" generalising.
- Labels in domain language, not the reducer's action names.
