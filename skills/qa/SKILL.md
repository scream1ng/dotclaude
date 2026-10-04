---
name: qa
description: >
  Drive a real browser through the changed flow, find bugs, fix them, and write a
  regression test for each fix. Use when user says "/qa", "test this in the browser",
  "qa this feature", or points at a staging/dev URL and says test it. $ARGUMENTS may
  hold a URL and/or a flow description; if omitted, infer the URL from a running dev
  server and the flow from the current diff.
---

# qa — real-browser bug hunt, fix, verify

Give the agent eyes. Actually click through the feature that just changed, not just
read the code. Find what breaks, fix it, prove the fix with a regression test.

## Process

1. **Load browser tools.** If `mcp__claude-in-chrome__*` tools are deferred, load the
   core set in one `ToolSearch` call: `tabs_context_mcp`, `navigate`, `computer`,
   `read_page`, `tabs_create_mcp`. Add `read_console_messages` and
   `read_network_requests` — this skill watches both throughout.
2. **Establish target.** Use `$ARGUMENTS` if it names a URL. Otherwise check for a
   running local dev server (from this session or a recently started one); if none,
   start it. Get current tabs via `tabs_context_mcp` first — reuse only if the user
   pointed at an existing tab, otherwise open a new one.
3. **Derive the flow to test.** Use `$ARGUMENTS` if it names a flow. Otherwise read the
   current diff (`git diff`/`git diff --stat` against main) and infer the user-facing
   flow(s) touched — new screens, new fields, changed states.
4. **Walk the golden path first.** Navigate, click, fill forms as a real user would.
   Screenshot key states. Watch console + network throughout — a silent 500 or a
   console error is a bug even if the UI looks fine.
5. **Then the edges**: empty/zero states, validation errors, double-submit, back/forward
   nav, slow network if the tool supports throttling, refresh mid-flow. Match whatever
   edge cases the diff's shape suggests (loops, pagination, async calls).
6. **On a bug found**: fix it in the code (atomic commit per fix, not one giant commit),
   re-run the exact repro in-browser to confirm it's gone, then write a regression test
   covering it using this repo's existing test framework/conventions. If no test
   framework exists, report the gap — don't invent a new one uninvited.
7. **Report**: flow(s) tested, bugs found → fixed (with the regression test each got),
   anything found but not fixed (and why), console/network issues seen, screenshots
   taken. If browser tools genuinely aren't available after one retry, say so plainly
   and fall back to a manual code-read pass — don't silently claim verification that
   didn't happen.

## Rules

- Never trigger JS `alert`/`confirm`/`prompt` — they hang the browser session. Skip
  elements that trigger them, or handle via console instead.
- Don't fix bugs unrelated to the tested flow — report and move on, per Karpathy
  surgical-changes rule.
- Each fix is its own commit. Don't bundle multiple bug fixes into one commit.
- This is QA, not `/ship` — don't push, merge, or open a PR. Stop after reporting.
