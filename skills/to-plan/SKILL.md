---
name: to-plan
description: >
  Turn a plan/feature discussion, or an existing HTML prototype's embedded decisions,
  into a durable plan/<feature>.md doc that implement can build from in any session —
  not just the one where the discussion happened. Use when user says "/to-plan",
  "write this up as plan", "turn this into a plan", after a feature discussion or
  pointing at a plan/*.html prototype.
---

# to-plan — discussion/prototype → durable plan doc

Persist a feature's decisions to `plan/<feature>.md` so `implement` can pick it up in
a different session or worktree, not only the one where the plan was discussed.

## Process

1. **Determine the source.**
   - If `plan/<feature>.html` exists (made by `prototype`) — source is its embedded
     HTML comment block (screens, fields, nav placement, open questions) plus anything
     decided verbally since it was made.
   - Otherwise — source is this conversation's discussion. If nothing relevant is in
     context, ask one question for the feature; don't invent one.
2. **Synthesize with an Opus-tier agent.** Structuring a plan is a planning-judgment
   call, not mechanical delegation — spawn via the Agent tool with `model: "opus"`,
   handing it the source material (embedded comment block and/or conversation excerpt)
   and asking it to write the plan doc below. Don't have it invent anything the source
   didn't decide — unresolved points go under "Open questions", not filled in.
3. **Write `plan/<feature-kebab-name>.md`** (same basename as the `.html` if one
   exists), with:
   - Screens/states and what each shows
   - Fields/data shape
   - Nav placement / entry points
   - Non-goals (explicitly out of scope, if discussed)
   - Open questions (left unresolved — implement should ask about these, not guess)
4. **Never auto-delete.** Same policy as `prototype`'s `.html` files — plan.md stays
   in `plan/` as history after implement builds from it, no cleanup step.
5. Tell the user the path. Don't publish as an Artifact — this lives in repo history.

## Rules

- No implementation detail (no code, no file paths to touch) — that's `implement`'s job.
- If the source is ambiguous or incomplete, mark it as an open question rather than
  guessing.
