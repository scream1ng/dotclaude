---
name: to-plan
description: >
  Turn a plan/feature discussion, or an existing HTML prototype's embedded decisions,
  into a durable plan/<feature>-plan.html doc — with a before/after flow diagram
  where there's a before to contrast — that implement can build from in any session,
  not just the one where the discussion happened. Use when user says "/to-plan",
  "write this up as plan", "turn this into a plan", after a feature discussion or
  pointing at a plan/*.html prototype.
---

# to-plan — discussion/prototype → durable plan doc

Persist a feature's decisions to `plan/<feature>-plan.html` so `implement` can pick
it up in a different session or worktree, not only the one where the plan was discussed.
This is a **document**, not a UI mockup — `prototype` already owns "what it'll look
like"; this owns "what changes and why," with one diagram showing the flow shift.

## Process

1. **Determine the source.**
   - If `plan/<feature>.html` from `prototype` exists — source is its embedded HTML
     comment block (screens, fields, nav placement, open questions) plus anything
     decided verbally since it was made.
   - Otherwise — source is this conversation's discussion. If nothing relevant is in
     context, ask one question for the feature; don't invent one.
2. **Synthesize with an Opus-tier agent.** Structuring a plan is a planning-judgment
   call, not mechanical delegation — spawn via the Agent tool with `model: "opus"`,
   handing it the source material and asking it to produce the sections below,
   including a **before/after summary**: current flow/state in one short list, target
   flow/state in another, each step naming the concrete thing that changes. Don't have
   it invent anything the source didn't decide — unresolved points go under "Open
   questions", not filled in.
3. **Render as a self-contained `plan/<feature-kebab-name>-plan.html`** (same feature
   basename as the prototype `.html` if one exists, suffixed `-plan` — never overwrite
   the prototype) — plain document styling (headings, lists,
   monospace for field names), not the app's real CSS or component styling; that
   look belongs to `prototype`, not here. Sections, in order:
   - Summary (one paragraph: what's changing and why)
   - **Before/after diagram** — simple boxes-and-arrows inline SVG contrasting current
     flow/state vs. target flow/state, step by step. Skip it if the feature is net-new
     with no "before" to contrast against.
   - Screens/states and what each shows
   - Fields/data shape
   - Nav placement / entry points
   - Non-goals (explicitly out of scope, if discussed)
   - Open questions (left unresolved — implement should ask about these, not guess)
4. **Never auto-delete.** Same policy as `prototype`'s files — the plan doc stays in
   `plan/` as history after implement builds from it, no cleanup step.
5. Tell the user the path and to open it directly in a browser. Don't publish as an
   Artifact — this lives in repo history.

## Rules

- No implementation detail (no code, no file paths to touch) — that's `implement`'s job.
- No app UI styling/components — that's `prototype`'s job; keep this a readable doc.
- If the source is ambiguous or incomplete, mark it as an open question rather than
  guessing.
