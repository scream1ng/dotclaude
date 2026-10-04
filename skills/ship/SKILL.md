---
name: ship
description: >
  Run the user's standard git release flow: commit, push, merge to main, clean up.
  Use when user says "/ship", "commit push", "ship it", "merge to main", "release",
  "push to github", or describes the end-of-work git dance. $ARGUMENTS optionally
  holds the commit message; if empty, generate one from the diff. Every trigger
  runs the full flow — there is no partial "commit only" mode.
---

# ship — git release flow

Automate the user's repeated git sequence. One flow, always runs to completion:
branch (if needed) → commit → push → merge to main → push main → clean up.

## Flow

1. `git status --short` and `git diff --stat` — show what will be committed.
2. If the current branch is `main`/`master`: `git pull` first to make sure the branch-off
   point is current. Stop and flag on conflict — do not auto-resolve. Then create a new
   branch before committing. Name it `<type>/<slug>` (type: `fix`/`feat`/`chore`; slug
   derived from the diff/commit subject, kebab-case, matching this repo's existing branch
   style) and `git checkout -b <name>`. Skip this step if already on a non-main branch.
3. Stage: `git add -A` (unless user named specific files).
4. **README check**: if the diff touches something a README documents (new flag, skill, command,
   config, step in a documented flow) and the README wasn't updated to match, flag it in the
   report — do NOT edit the README yourself.
5. Commit message: use `$ARGUMENTS` if given; else write a concise Conventional-Commits
   message from the diff. End with the Co-Authored-By line. If the tree is clean (branch
   already has its commits), skip the commit and continue.
6. **Issue-linked work**: find issue `#N`:
   - Strong (close without asking): `Closes/Fixes #N` in the commit message, `issue-N` in
     the branch name, or the user named the issue in this session.
   - Weak (ask once, close only on yes): bare `#N` in a commit subject, or issue inferred
     from the work.
   If confirmed and still open (`gh issue view N --json state`):
   - Post a summary comment BEFORE pushing to main:
     `gh issue comment N --body <what shipped + how to use it + any prod setup done>`.
     The comment must land before the issue auto-closes.
   - Close it: put `Closes #N` in the merge commit message (step 9). After pushing main,
     verify with `gh issue view N --json state`; if still open, `gh issue close N`.
7. `git push -u origin <branch>` — push the feature branch.
8. **Locate the main checkout** — never merge to main from inside a feature worktree:
   - Compare `git rev-parse --git-common-dir` vs `--git-dir`. If they differ, you're in a
     linked worktree.
   - Find the main checkout path: first `worktree <path>` line from `git worktree list --porcelain`.
     Call it `<main_path>` (if not in a worktree, `<main_path>` is just the current directory).
   - All remaining merge/push/cleanup steps run against `<main_path>` via `git -C <main_path> ...`
     — do NOT `git checkout main` in the feature worktree itself, that just repurposes it.
   - `main` below means the repo's default branch (`main` or `master`):
     `git symbolic-ref --short refs/remotes/origin/HEAD`, strip `origin/`.
9. Sync and merge at `<main_path>`: `git -C <main_path> checkout main && git -C <main_path> pull`,
   then `git -C <main_path> merge --no-ff <branch> -m "Merge branch '<branch>'"` (add
   `-m "Closes #N"` when step 6 confirmed an issue). Stop and flag on conflict — do not auto-resolve.
10. Push main, with retry for concurrent agents merging around the same time:
   - `git -C <main_path> push origin main`.
   - If rejected (non-fast-forward): `git -C <main_path> fetch origin && git -C <main_path> merge origin/main`,
     then retry the push. Up to 3 attempts.
   - Real conflict during that re-merge, or still rejected after 3 attempts → stop, flag, do not
     auto-resolve — likely a genuine concurrent-merge collision, not a transient race.
11. Cleanup:
   - If this was a linked worktree: `git worktree remove <path-of-this-worktree>` (run via
     `git -C <main_path>`). This deletes the directory you're currently sitting in — flag it
     plainly in the report, don't run further commands assuming the old path still exists.
   - `git -C <main_path> branch -d <branch>` (safe now — branch isn't checked out anywhere).
   - `git -C <main_path> push origin --delete <branch>`.
12. Report: branch created (if any), commit hash, merged into main, issue commented + closed (if any),
    README flagged (if any), push retries if any occurred, branch + worktree deleted (local + remote).

## Rules

- NEVER force-push. NEVER skip hooks (`--no-verify`) unless user explicitly asks.
- On merge conflict: stop, show conflicting files, do NOT auto-resolve.
- Show the actual commands' output (status, hash) — don't claim success blind.
- Never run `git checkout main` inside a feature worktree — always route merge/push/cleanup
  through `<main_path>` per step 8. This matters most when several agents each work in their
  own worktree at the same time — the main checkout is the single integration point.
- Push-to-main rejections get one retry cycle (fetch + merge + push), not endless retries.
