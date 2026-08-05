---
name: implement
description: >
  Pick up an HTML prototype or plan.md from plan/ and build the real feature
  end-to-end: build it, apply UI/UX judgment beyond the literal mockup, hunt for bugs
  in what was built, then run an end-to-end test before reporting done. Use when user
  says "/implement", "build this prototype", "implement the mockup", or points at a
  plan/*.html or plan/*.md file and says build it. $ARGUMENTS may name the file; if
  omitted, use the most recently modified file in plan/.
---

# implement — prototype → real, working, verified feature

Build the actual, working version of a feature previously mocked up as a static HTML
file in `plan/`. The prototype is the spec for shape — its screens, fields, row shapes,
and states are what gets built, not a fresh reinterpretation — but this skill doesn't
stop at "matches the picture." It also improves UI/UX where the static mockup couldn't
show real behavior, hunts for bugs in the result, and proves it works end-to-end.

## Process

1. **Locate the plan.** Use `$ARGUMENTS` if given. Otherwise: if `plan/` has exactly
   one `.html` file, use it; if more than one, list them and ask which — don't guess
   by mtime. Read it fully — treat every screen/frame/state it shows as a requirement.
   If `plan/` has no `.html` but has a `.md` (made by `to-plan` straight from a
   discussion, no prototype step), use that instead — same one-file-or-ask rule.
2. **Re-derive the plan from the mockup itself** — read its embedded HTML comment block
   (screens, fields, nav placement, open questions) as the source of truth for shape.
   If it's missing that block, fall back to a sibling `plan/<feature>.md` (made by
   `to-plan`) if one exists; otherwise fall back to this conversation's history if the
   prototype was made in this same session; otherwise ask.
3. **Don't re-present what the prototype already settled.** If step 2 found a complete
   embedded spec, the plan is already agreed — proceed straight to building. Only surface
   something before coding if it's genuinely new (e.g. exact DB column names the mockup
   couldn't have known) or the change touches stable/shared code the prototype didn't
   cover (schema, `fill_sop.py`, an existing module's own blueprint) — and even then, say
   it in one line while continuing, don't stop and wait unless it's actually risky.
4. **Implement surgically**, per this repo's CLAUDE.md conventions — find the closest
   analogous module/blueprint/screen and match its shape rather than inventing new
   conventions.
5. **Improve UI/UX beyond the static picture.** A mockup can't show loading states,
   error states, empty states with real copy, focus order, disabled/pending button
   states, keyboard/touch behavior, or transitions — apply this project's existing
   conventions for those (loading spinners, toasts, disabled styles, motion specs, etc.)
   even where the prototype is silent. Don't invent new interaction patterns; reuse
   whatever the codebase already does elsewhere for the same situation. Flag any UX gap
   you found but didn't fix (scope/time reasons) rather than shipping it silently.
6. **Hunt for bugs in what was just built** — a short adversarial pass over the new
   code: empty/zero/null inputs, the boundary of any loop or pagination limit, what
   happens on a failed network call, double-submit/double-click, and anything the
   prototype's states didn't cover. **Convention-check technique:** grep 2-3 existing
   analogous call sites (siblings of what you just wrote — other rows/screens/endpoints
   doing the same job) and diff their shape against yours; a missing property, default,
   or guard they all share and yours lacks is a real bug, not style nitpicking. Fix what's
   cheap to fix; for anything nontrivial, report it rather than leaving it silently broken.
7. **End-to-end test before declaring done.** Run existing automated tests if present.
   For anything UI-reachable, actually drive it — start the dev server and exercise the
   real golden path plus the edge cases from step 6. If browser automation isn't
   confirmed available yet, check/retry once before assuming it's unavailable — a first
   "not connected" can be transient; don't silently fall back to narration on the first
   try. Only after a genuine retry fails, fall back to a manual walkthrough you narrate,
   and say explicitly that live UI verification couldn't be done. Don't stop at "the code
   looks right" or "the screen matches the prototype visually" — a green type-check or
   test suite verifies correctness, not that the feature works. Leave the dev server
   running afterward for the user to try it themselves — don't kill it.
8. **Report** — brief diff summary, what was touched, the UX gaps found/fixed, the bugs
   found/fixed, how it was end-to-end tested (and what, if anything, couldn't be
   exercised), and one line flagging any deliberate deviation from the prototype (and
   why).

## Rules

- The prototype is a visual reference, not a pixel contract — app screens should match
  it closely, but see CLAUDE.md's note that generated `.docx` output never needs to.
- Don't re-litigate decisions already settled in the plan/prototype unless something in
  it is now clearly wrong or infeasible — flag it, don't silently change it.
