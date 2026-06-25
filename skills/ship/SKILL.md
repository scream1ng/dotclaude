---
name: ship
description: >
  Run the user's standard git release flow. Use when user says "/ship", "commit push",
  "ship it", "merge to main", "push to github", or describes the end-of-work git dance.
  $ARGUMENTS optionally holds the commit message; if empty, generate one from the diff.
  Default flow = commit current branch + push. Extended flow (when user says "merge to main"
  or "release") = also merge into main, push main, delete the feature branch local + remote.
---

# ship — git release flow

Automate the user's repeated git sequence. Two modes.

## Mode A — commit + push (default)

Triggers: "commit push", "/ship", "ship it".

1. `git status --short` and `git diff --stat` — show what will be committed.
2. Stage: `git add -A` (unless user named specific files).
3. Commit message: use `$ARGUMENTS` if given; else write a concise Conventional-Commits
   message from the diff. End with the Co-Authored-By line.
4. `git push` (set upstream with `-u origin <branch>` if no upstream yet).
5. Report: branch, commit hash, files changed.

## Mode B — release to main (extended)

Triggers: "merge to main", "release", "merge and remove branch".
Only run this when explicitly asked — it touches main.

1. Run Mode A first (commit + push the feature branch).
2. Capture current branch name as `$FEATURE`.
3. `git checkout main && git pull` — sync main.
4. `git merge --no-ff $FEATURE` (or fast-forward if user prefers). Stop and flag on conflict.
5. `git push origin main`.
6. Cleanup: `git branch -d $FEATURE` then `git push origin --delete $FEATURE`.
7. Report: merged into main, branch deleted local + remote.

## Rules

- NEVER force-push. NEVER skip hooks (`--no-verify`) unless user explicitly asks.
- If on `main`/`master` already in Mode A, just commit + push — no merge step.
- On merge conflict: stop, show conflicting files, do NOT auto-resolve.
- Confirm before deleting a branch that isn't fully merged.
- Show the actual commands' output (status, hash) — don't claim success blind.

## Caveman mode

If caveman active, report results terse: `pushed: <branch> <hash>, N files`. Commit
message body stays normal prose (commits are never caveman).
