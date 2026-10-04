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
4. Check which branches already tackle issues:
   ```
   git fetch --all --quiet
   git branch -a --sort=-committerdate
   git log main..origin/<branch> --oneline   # per non-main/preview branch
   ```
   Match branches to issue numbers via commit messages (e.g. `(#34)`) or diff scope (`git diff main...origin/<branch> --stat`).
5. Wait for all agents, then output one table:

   | # | Issue | DB migration? | Difficulty | Branch tackling it |

   Use `—` when no branch touches the issue. Followed by three summary lines: **Touch DB:** list, **No DB, code-only:** list, **Untouched:** list of issues with no branch.

Flag anything in an issue body that looks like a typo/contradiction (e.g. conflicting date math) rather than silently coding around it.
