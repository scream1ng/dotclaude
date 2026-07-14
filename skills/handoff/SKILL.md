---
name: handoff
description: Compact the current conversation into a handoff document for a fresh agent to continue the work. Use when the user says "handoff", "hand this off", or wants to continue work in a new session/machine.
disable-model-invocation: true
---

Generate a handoff document that lets a fresh agent continue this work with no prior context, saved to the OS temporary directory (not the current workspace).

Include:
- A summary of the current conversation: goal, decisions made, current state.
- A "Suggested skills" section recommending which skills the next agent should invoke.
- References to existing artifacts (specs, plans, ADRs, issues, commits, diffs) by path/URL — do not duplicate their content.

Redact sensitive data: API keys, passwords, personally identifiable information.

If the user provides arguments, treat them as the focus area for the next session and tailor the document accordingly.

Report the saved file path back to the user.
