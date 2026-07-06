---
name: plan-it
description: >
  Summarize a change OR the last AI analysis as a numbered Before / After / Benefit / Risk table,
  in plain non-programmer language. Output inline in conversation — no files saved.
  Use when user says "/plan-it", "show plan-it", "before after benefit risk", or
  "summarize in table format".
  If $ARGUMENTS is provided, treat it as what to summarize.
  Otherwise, infer from recent conversation context: the last AI analysis/recommendation,
  the last diff, the last edit, or the last discussion.
---

# Plan It — Before / After / Benefit / Risk

Produce a numbered **Before / After / Benefit / Risk** table for `$ARGUMENTS`.
If `$ARGUMENTS` is empty, infer the subject from the most recent context — and note this skill
summarizes **either a code change OR the last AI analysis/recommendation**, whichever was last.

## Process

1. **Identify** the subject — read `$ARGUMENTS` or infer from context (last analysis, diff, edit, or discussion)
2. **Explore** if needed — read relevant files to understand before/after state (don't guess)
3. **Output** the table(s) inline — no files, no HTML, plain markdown

## Output format

Plain-language, numbered table. Write for a **non-programmer** — explain in everyday words, not jargon.

- First line: bold one-sentence header — what is being summarized.
- **Every table gets its own bold heading line directly above it** (e.g. `**Recommendations**`, `**Leave alone / deferred**`, `**Change type & production risk**`). Never print a bare table with no heading.
- Main table: every row numbered `#1`, `#2`, … in a leading `#` column.
- **Change type & production risk table: always included**, right after the main table — DB/prod risk is a standing concern, not opt-in.
- Optional second table: only if the analysis flagged items deliberately left alone / deferred.
- Last line: a one-line **Do-first order** (e.g. `#1 → #2 → #3 → rest as time allows`).

### Main table

Print the heading `**Recommendations**` directly above it.

**Recommendations**

| # | Area | Before (now) | After (proposed) | Benefit | Risk if ignored |
|---|------|-------------|------------------|---------|-----------------|
| **#1** | ... | ... | ... | ... | ... |

### Optional "leave alone" table (include only when relevant)

Print the heading `**Leave alone / deferred**` directly above it.

**Leave alone / deferred**

| # | Item | Verdict | Why |
|---|------|---------|-----|
| **#8** | ... | ✅ Keep / ⚠️ Aware | ... |

### Change type / prod risk table (always included)

Always produce this table right after the main table — DB/prod risk gets flagged by default,
not only when asked. Reuse the same `#` numbers as the main table.
Print the heading `**Change type & production risk**` directly above it.

**Change type & production risk**

| # | Area | Change type | Touches prod DB? | Risk to live prod when doing it |
|---|------|-------------|------------------|-------------------------------|
| **#1** | ... | Code / DB migration / Config / No change | ✅ Yes / ❌ No / ⚠️ data only | None / Low / Medium / **HIGH ⚠️** — one-line why |

Rules for this table:
- **Change type**: pick one — `Code only`, `DB migration`, `Code + DB`, `Config`, `New library/service`, `No change`.
- **Touches prod DB?**: `❌ No`, `✅ Yes — schema change`, or `⚠️ data only` (operates on data, no schema change).
- **Risk**: rate `None / Low / Medium / HIGH`, add ⚠️ for Medium+, one-line reason (lockout, revocation lag, data corruption, downtime…).
- Flag schema migrations and anything that can touch live data as the highest risk.
- End with a one-line **safe ship order** (e.g. `#1 → #6 → #2 → … ; defer #9`).

### Rules

- One row per **change area** (not per file). Number rows continuously across both tables.
- **Area**: short plain label (e.g. "Auto safety check", "Login security gate") — not code symbols.
- **Before**: what happens today, in everyday language.
- **After**: what changes — everyday language.
- **Benefit**: concrete outcome for the user or business (not vague "better UX").
- **Risk if ignored**: one specific consequence of not doing it. Append ` → mitigation` if one exists.
- Translate jargon: say "robot checks every change" not "CI pipeline", "small helper library" not "React Query".
- Keep each cell tight — 1–2 lines max.
- If no real risk exists, write "Low — no data or system change".
- Skip rows where nothing meaningful changed.
- No narrative paragraphs — bold header line, table(s), Do-first line only.

## Caveman mode

If caveman mode is active, keep table cells compressed — drop articles, short synonyms.
Table structure, numbering, and plain-language tone stay intact.
