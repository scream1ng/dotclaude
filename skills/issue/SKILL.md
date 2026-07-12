---
name: issue
description: Fetch open GitHub issues, investigate codebase, report difficulty + DB-touch table. Use when user says "/issue", "check issues on github", "triage issues", or "which issues touch db".
---

# issue

Fetch open GitHub issues for the current repo, investigate each against the codebase, and report a summary table.

## Steps

1. Get repo + issues:
   ```
   gh repo view --json nameWithOwner -q .nameWithOwner
   gh issue list --state open --limit 100 --json number,title,labels,createdAt
   ```
2. Fetch full body for each issue: `gh issue view <n> --json title,body -q '.title + "\n" + .body'`
3. Group issues into 2-4 batches, spawn one Explore agent per batch (parallel, single message) to investigate against the codebase:
   - Relevant files/tables (check `supabase/migrations/`, relevant `app/(dashboard)/` pages, `lib/validation.ts`)
   - Whether a DB migration is needed (new column/table) or existing schema/JSONB covers it
   - Difficulty: small/medium/large with 1-sentence reasoning
4. Wait for all agents, then output one table:

   | # | Issue | DB migration? | Difficulty |

   Followed by two summary lines: **Touch DB:** list, **No DB, code-only:** list.

Flag anything in an issue body that looks like a typo/contradiction (e.g. conflicting date math) rather than silently coding around it.
