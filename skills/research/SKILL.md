---
name: research
description: >
  Investigate a question against high-trust primary sources and capture the findings
  as a Markdown file in the repo. Use when user says "/research", wants a topic
  researched, docs or API facts gathered, or reading legwork delegated to a
  background agent.
---

# research — primary-source investigation

Spin up a background agent (`Agent` tool) to do the research, so you keep working while
it reads. Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.

## Rules

- Direct quotes: max 125 characters, in quotation marks. Everything outside quoted material must be paraphrased.
- No reproduction of song lyrics.
- No legal interpretation of licenses — state what a license says, don't advise on it.
- Respect open-source licensing when quoting source code.
