---
name: to-plan
description: >
  Turn a plan/feature discussion, or an existing HTML prototype's embedded decisions,
  into a durable plan/<feature>-plan.html doc — visual-first, diagram over prose —
  that implement can build from in any session, not just the one where the discussion
  happened. Use when user says "/to-plan", "write this up as plan", "turn this into a
  plan", after a feature discussion or pointing at a plan/*.html prototype.
---

# to-plan — discussion/prototype → durable plan doc

Persist a feature's decisions to `plan/<feature>-plan.html` so `implement` can pick
it up in a different session or worktree, not only the one where the plan was discussed.
This is a **document**, not a UI mockup — `prototype` already owns "what it'll look
like"; this owns "what changes and why."

**Visual-first.** A reader should get most of the plan from diagrams/tables at a
glance, prose filling gaps rather than carrying the content. Before writing a
section as a paragraph, ask whether it's actually a diagram, table, or short list
wearing prose as a disguise — if so, make it one. Reserve paragraphs for the
Summary and anything a diagram genuinely can't carry (rationale, tradeoffs).

## Process

1. **Determine the source.**
   - If `plan/<feature>.html` from `prototype` exists — source is its embedded HTML
     comment block (screens, fields, nav placement, open questions) plus anything
     decided verbally since it was made.
   - Otherwise — source is this conversation's discussion. If nothing relevant is in
     context, ask one question for the feature; don't invent one.
2. **Synthesize with an Opus-tier agent.** Structuring a plan is a planning-judgment
   call, not mechanical delegation — spawn via the Agent tool with `model: "opus"`,
   handing it the source material and asking it to produce the sections below.
   Don't have it invent anything the source didn't decide — unresolved points go
   under "Open questions", not filled in.
3. **Pick the diagram mode** for the plan's central diagram (a plan can use both if
   it has both a flow shift and a data shift — one diagram per shape, not one
   diagram trying to carry both):
   - **boxes-and-arrows** — the change is a *flow/sequence* (steps A→B→C, a request
     path, a state machine's transitions). Simple inline SVG, boxes + arrows,
     current path vs. target path.
   - **scenario-delta** — the change is *entity/table-shaped*: the same fixed set of
     tables/objects appears in every state, only what's written to each differs.
     Before/after is the N=2 case of this — use it even for a single before/after
     if the thing being contrasted is "what each table looks like," not a sequence.
     See "Scenario-delta usage" below.
   Skip the diagram section only if the feature is net-new with no "before" and no
   multi-entity shape to contrast — a single new screen with no data model behind it,
   say.
4. **Render as a self-contained `plan/<feature-kebab-name>-plan.html`** (same feature
   basename as the prototype `.html` if one exists, suffixed `-plan` — never overwrite
   the prototype) — plain document styling (headings, tables, monospace for field
   names), not the app's real CSS or component styling; that look belongs to
   `prototype`, not here. Sections, in order, each visual unless noted:
   - Summary — the one paragraph exception, 2-3 sentences: what's changing and why
   - **Central diagram(s)** from step 3
   - Screens/states — a table (screen | what it shows | who can act), not a list of
     paragraphs per screen
   - Fields/data shape — a table (field | type/shape | source), not prose
   - Nav placement / entry points — inline on the diagram if it fits, else one line
   - Non-goals — short bullet list, if discussed
   - Open questions — short bullet list, left unresolved; implement should ask about
     these, not guess
5. **Never auto-delete.** Same policy as `prototype`'s files — the plan doc stays in
   `plan/` as history after implement builds from it, no cleanup step.
6. Tell the user the path and to open it directly in a browser. Don't publish as an
   Artifact — this lives in repo history.

## Scenario-delta usage

`assets/scenario-delta.css` in this skill directory has the full stylesheet
(color tokens, light/dark) — copy it verbatim into the plan doc's `<style>` block,
don't re-derive it. The encoding is **ordinal, one hue at four intensities**
(quietest → loudest), never a green/red status palette — a table being *written to*
isn't good or bad, just more or less touched. Each intensity also carries a glyph
(`+ ~ = ·`) and a word so it survives greyscale.

Markup pattern per state (repeat per scenario / per before-after side):

```html
<div class="sd-legend">
  <span class="sd-legend-lbl">ยิ่งกล่องเข้ม แปลว่ายิ่งเปลี่ยนเยอะ:</span>
  <span class="sd-op sd-op-insert">+ new row</span>
  <span class="sd-op sd-op-update">~ updated</span>
  <span class="sd-op sd-op-locked">= untouched</span>
  <span class="sd-op sd-op-none">· nothing</span>
</div>

<figure class="sd-fig">
  <div class="sd-fig-head"><span class="sd-fig-no">CASE 1</span><h3>short label</h3></div>
  <svg viewBox="0 0 900 300" role="img" aria-label="...">
    <!-- one <rect>+<text> box per entity, same position across every case;
         border color = --sd-l1..l4 by how much that entity changed;
         arrows between boxes use currentColor, accent arrows use var(--sd-acc) -->
  </svg>
  <figcaption><b>one-line takeaway</b> — why this case looks the way it does.</figcaption>
</figure>

<dl class="sd-recon">
  <div><dt>metric</dt><dd>value</dd></div>
  <div><dt>metric</dt><dd class="good">value ✓</dd></div>
</dl>
```

Keep entity **box positions identical across every case/state** — the reader compares
shape, not position. `sd-recon` at the end of a figure is optional: use it when there's
a number that should reconcile (money in vs out, before-total vs after-total) and the
diagram proves it ties.

## Rules

- No implementation detail (no code, no file paths to touch) — that's `implement`'s job.
- No app UI styling/components — that's `prototype`'s job; keep this a readable doc.
- If the source is ambiguous or incomplete, mark it as an open question rather than
  guessing.
- Don't pad a table/diagram section with a restating paragraph underneath it — if the
  diagram already says it, don't say it again in prose.
