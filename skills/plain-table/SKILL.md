---
name: plain-table
description: Turn a technical findings list (code review, audit, bug list) into a plain-language before/after/benefit table. Use when user says "plain-table", "make it less technical", "put in table form", or "before/after/benefit table".
---

# plain-table

Convert a prior technical list (review findings, bugs, audit results) into a table non-technical stakeholders can read.

## Steps

1. Take the most recent findings list in conversation (or whatever the user points at).
2. Build one table:

   | # | Problem | Now | Fixed | Why it matters |

   - **Problem**: plain name for the issue, no code/file refs.
   - **Now**: what happens today, in user-facing terms.
   - **Fixed**: what changes, in user-facing terms.
   - **Why it matters**: concrete benefit to the user/business, one line.
3. No file paths, function names, or code snippets in the table. Push jargon down to plain words (e.g. "re-encodes JPEG" → "recompresses photo", "touchmove" → "finger drag").
4. Order rows same as source list (usually severity/impact order) unless user asks to re-sort.
5. After the table, one line asking which item to fix first.
