---
name: plain-text
description: Turn one technical explanation, plan, or diff summary into a short plain-language write-up in prose. Use when user says "plain-text", "explain that simpler", "explain your plan a bit simpler", or "in plain English". For a single thing; use plain-table for a list of findings.
---

# plain-text

Re-explain the most recent technical explanation, plan, or change summary so a non-technical stakeholder gets it in one read.

## Steps

1. Take the most recent explanation/plan/diff summary in conversation (or whatever the user points at).
2. Write it in this shape — prose and short numbered lines, never a table:

   **What**: what the person sees or does today, or what the change is about. Max 2 sentences.
   **Why**: the real cause or reason, in everyday terms. Max 2 sentences.
   **What changes**: max 3 numbered items, one line each, each a user-visible outcome.
   Closing line: size/scope plus one short question ("no big redesign, ~2 files — want me to start?").
3. Second person and observable behaviour: "you're on the Order tab, tap X, the bottom bar lights up the wrong section" — not "the router resolves the segment to the wrong tab". Describe what the user sees and does, not what the system is.
4. No file paths, function names, or code snippets. Push jargon down to plain words (e.g. "re-encodes JPEG" → "recompresses photo", "touchmove" → "finger drag").
5. Never trade accuracy for smoothness. If a plain word would make it wrong, use the closest plain word that is still true. Do not add causes, fixes, or benefits the source did not state.
6. Scope facts in the closing line (file counts, "no new screen", timing) must come from the source. If the source doesn't state scope, drop that half of the line and just ask the question.
