---
name: migration-status
description: >
  Report outstanding/unapplied DB migrations and diff between environments (staging vs prod).
  Use when user says "/migration-status", "how many outstanding migrations", "migrations
  between staging and prod", "what migrations are pending", or "migration diff".
  $ARGUMENTS may name environments to compare (default: staging vs prod).
---

# migration-status — migration diff & pending count

Report which migrations are applied where, and what's outstanding between environments.

## Process

1. **Detect tooling** — check the project for the migration system:
   - `supabase/migrations/` + supabase CLI → use `supabase migration list`
   - `prisma/migrations/` → `npx prisma migrate status`
   - `drizzle/` → check drizzle journal
   - raw SQL dir → list files, compare against a tracking table
   If none found, ask which tool the project uses.

2. **List per environment** — for each env (staging, prod), get applied migrations.
   For supabase: `supabase migration list --linked` per linked project, or compare
   local `supabase/migrations/` files against the remote applied list.

3. **Diff** — compute: applied-on-staging-not-prod, local-not-applied-anywhere.

4. **Report** — table below. Give a clear count, not just a dump.

## Output format

**Migration status — staging vs prod**

| Migration | Local | Staging | Prod |
|-----------|-------|---------|------|
| 20260101_init | ✅ | ✅ | ✅ |
| 20260620_add_refund | ✅ | ✅ | ❌ pending |

End with a one-line summary: `N outstanding to prod, M outstanding to staging.`

## Rules

- READ-ONLY. Never run `migrate up`, `db push`, or apply anything. This skill only reports.
- If applying is wanted, state the exact command and let the user run it.
- Flag any migration that touches schema on prod as ⚠️ — pair with babr if risk detail wanted.
- Show real CLI output; don't infer counts you didn't verify.

## Caveman mode

If caveman active, compress the summary line: `3 outstanding→prod, 0→staging`. Table stays intact.
