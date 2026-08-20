---
name: diagnose
description: >
  Discipline loop for hard bugs and performance regressions — feedback loop,
  minimize, hypothesize, instrument, fix, cleanup. Use when user says "/diagnose",
  "debug this", or reports something broken/throwing/failing/slow.
---

# diagnose — hard-bug discipline loop

Six phases for bugs that don't yield to reading the code. Skip a phase only with an
explicit justification.

## Redact

This skill has you show commands, outputs, and captured artifacts. **Redact every secret
first** — write `<REDACTED>` in its place, and build loops against env vars so credentials
stay in the environment. Captured artifacts carry auth headers: quote only the signal lines.
If the redacted output isn't enough to diagnose the bug, say so and ask the user.

## Phase 1: Build a feedback loop

**This is the skill** — everything else is mechanical. A tight pass/fail signal that goes
red on *this* bug will find the cause; without one, staring at code won't. Spend
disproportionate effort here.

Ways to construct one, in roughly this order:

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) driving the UI, asserting on DOM/console/network.
5. **Replay a captured trace** — save a real request/payload/event log, replay it through the code path in isolation.
6. **Throwaway harness** — minimal subset of the system (one service, mocked deps) hitting the bug path in one call.
7. **Property / fuzz loop** for "sometimes wrong output": 1000 random inputs, look for the failure mode.
8. **Bisection harness** — automate "boot at state X, check, repeat" so `git bisect run` can drive it.
9. **Differential loop** — same input through old vs new version (or two configs), diff outputs.
10. **HITL, last resort** — if a human must click, script the sequence so the loop stays structured.

**Tighten it.** Treat the loop as a product: faster (cache setup, narrow scope), sharper
signal (assert the symptom, not "didn't crash"), more deterministic (pin time, seed RNG,
isolate filesystem, freeze network).

**Non-deterministic bugs**: the goal is a higher reproduction rate, not a clean repro. Loop
the trigger 100×, parallelize, add stress, inject sleeps. 50%-flake is debuggable, 1% isn't.

**If you genuinely cannot build a loop**: stop and say so, list what you tried, and ask for
(a) access to an environment that reproduces it, (b) a redacted artifact (HAR, log dump,
core dump, timestamped recording), or (c) permission for temporary prod instrumentation. Do
**not** hypothesize without a loop.

Done when one command you've already run (show the invocation and its redacted output) is:

- [ ] **Red-capable**: drives the actual bug path and asserts the user's exact symptom — red now, green once fixed. Not "runs without erroring".
- [ ] **Deterministic**: same verdict every run (flaky bugs: pinned, high reproduction rate).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: runs unattended.

No red-capable command, no Phase 2.

## Phase 2: Reproduce + minimize

Run the loop, watch it go red. Confirm:

- [ ] It produces the failure mode the **user** described, not a nearby one. Wrong bug = wrong fix.
- [ ] Reproducible across runs (or, non-deterministic, at a high enough rate to debug against).
- [ ] The exact symptom is captured (error message, wrong output, slow timing) so later phases can verify the fix.

**Minimize**: shrink to the smallest scenario that still goes red. Cut inputs, callers,
config, data, and steps one at a time, re-running after each cut. Done when removing any
remaining element makes the loop go green — that minimal repro is the Phase 5 regression test.

## Phase 3: Hypothesize

Generate 3-5 ranked hypotheses before testing any of them; single-hypothesis generation
anchors on the first plausible idea. Each must be falsifiable — state the prediction:

> "If `<X>` is the cause, then `<changing Y>` makes the bug disappear / `<changing Z>` makes it worse."

No prediction means it's a vibe: discard or sharpen it.

**Show the ranked list to the user before testing** — they often re-rank it instantly ("we
just deployed a change to #3") or know what's already ruled out. Don't block; proceed with
your ranking if they're AFK.

## Phase 4: Instrument

Each probe maps to a specific Phase 3 prediction. Change one variable at a time.

1. **Debugger / REPL inspection** where the env supports it — one breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix, e.g. `[DEBUG-a4f2]`, so cleanup is a single grep.

**Perf branch**: for performance regressions logs are usually wrong — establish a baseline
measurement (timing harness, `performance.now()`, profiler, query plan), then bisect.
Measure first, fix second.

## Phase 5: Fix + regression test

Write the regression test **before the fix**, but only if a correct seam exists — one where
the test exercises the real bug pattern as it occurs at the call site. A too-shallow seam
(single-caller test for a multi-caller bug, unit test that can't replicate the trigger chain)
gives false confidence; if none exists, that's the finding — note and flag it.

1. Turn the minimized repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 loop against the original (un-minimized) scenario.

## Phase 6: Cleanup

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes (or absence of seam is documented)
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix)
- [ ] Throwaway prototypes deleted
- [ ] The hypothesis that turned out correct is stated in the commit / PR message, so the next debugger learns
