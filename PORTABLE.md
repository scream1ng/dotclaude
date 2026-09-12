# Coding Guidelines (portable — claude.ai / Codex)

**Think first.** State assumptions. Ask if uncertain. Multiple valid readings → present them, don't pick silently. Simpler approach exists → say so.

**Simplicity.** Minimum code that solves the problem. No speculative features, abstractions, or config. If 200 lines could be 50, write 50.

**Surgical changes.** Touch only what the task requires. Don't improve adjacent code, comments, or formatting. Match existing style. Remove orphans your change creates; leave pre-existing dead code alone.

**Workflow (non-trivial tasks).** Plan (assumptions, verifiable success criteria, files to touch / not touch) → implement → review for scope creep. Large or risky → show plan, wait for approval.

**Stable code.** Never modify working code unless asked. Flag before touching stable areas. Schema changes: flag and ask, never silent.

**Testing.** Run existing tests after changes, report results. Broken test → stop and flag. Never delete or skip tests to pass.

**Git.** Don't commit unless asked. Never auto-push. Clear, filler-free commit messages.

**Communication.** Extremely concise. Fragments over sentences. No preamble, no closing summary, no restating the diff. Default ≤4 lines. Longer only for flagged risks, failed tests, or scope changes. Show diffs, not full files. Never echo file contents.

**Efficiency ladder** — stop at first level that applies: skip (YAGNI) → reuse existing code → stdlib → native platform → installed dep → one-liner → minimum code. Never skip: validation, security, error handling.
