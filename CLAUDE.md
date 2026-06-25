<!-- lean-ctx -->
<!-- lean-ctx-claude-v2 -->
## lean-ctx — Context Runtime

Always prefer lean-ctx MCP tools over native equivalents:
- `ctx_read` instead of `Read` / `cat` (cached, 10 modes, re-reads ~13 tokens)
- `ctx_shell` instead of `bash` / `Shell` (95+ compression patterns)
- `ctx_search` instead of `Grep` / `rg` (compact results)
- `ctx_tree` instead of `ls` / `find` (compact directory maps)
- Native Edit/StrReplace stay unchanged. If Edit requires Read and Read is unavailable, use `ctx_edit(path, old_string, new_string)` instead.
- Write, Delete, Glob — use normally.

Full rules: @rules/lean-ctx.md

Verify setup: run `/mcp` to check lean-ctx is connected, `/memory` to confirm this file loaded.
<!-- /lean-ctx -->

## Karpathy Coding Guidelines

### 1. Think Before Coding
- State assumptions explicitly. If uncertain, ask.
- Multiple interpretations → present them, don't pick silently.
- Simpler approach exists → say so. Push back when warranted.

### 2. Simplicity First
- Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked.
- No abstractions, flexibility, or configurability not requested.
- If 200 lines could be 50, rewrite it.

### 3. Surgical Changes
- Touch only what the task requires.
- Don't improve adjacent code, comments, or formatting.
- Match existing style.
- When your changes create orphans (unused imports/vars/functions) → remove them.
- Don't remove pre-existing dead code unless asked.

### 4. Goal-Driven Execution
- Define verifiable success criteria before starting.
- For multi-step tasks, state a brief plan with verify steps.
- Loop until criteria are met, not until it "looks right".

### 5. Workflow
For any non-trivial task:
1. **Plan** — State assumptions. List files to touch + files NOT to touch. No code yet.
2. **Implement** — Write code. Touch only listed files.
3. **Review** — Verify plan was followed. Check for scope creep.

For large or risky tasks, show plan and wait for approval before implementing.

### 6. Stable Code
- Never modify working code unless explicitly asked.
- If a task requires touching stable areas, flag it first — don't proceed silently.
- Database schema change → flag clearly and ask before implementing. Never alter schema silently.

### 7. Communication
- Be direct and brief.
- Show diffs, not full files, when possible.
- If a task is larger than expected, say so before starting — not halfway through.
- Never silently expand scope.

### 8. Git
- Don't commit unless asked. Never auto-push.
- When asked to commit, write a clear, concise message — no filler.

### 9. Testing
- Run existing tests after making changes. Report results.
- If changes break a test, stop and flag it — don't paper over it.
- Don't delete or skip failing tests to make things pass.