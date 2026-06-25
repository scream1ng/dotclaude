# dotclaude

My [Claude Code](https://claude.com/claude-code) global config — instructions, rules, and custom skills.

> **Private repo.** Contains my workflow preferences. Secrets and session data are
> excluded by `.gitignore` and were never copied here.

## What's included

| Path | What |
|------|------|
| `CLAUDE.md` | Global instructions: lean-ctx routing, Karpathy coding guidelines |
| `rules/lean-ctx.md` | lean-ctx tool-mapping rules (imported by `CLAUDE.md`) |
| `skills/babr/` | Before / After / Benefit / Risk summary skill |
| `skills/ship/` | Standard git release flow (commit/push, merge-to-main, branch cleanup) |
| `skills/migration-status/` | Report outstanding DB migrations, staging vs prod |
| `settings.example.json` | Sanitized `settings.json` (hooks, enabled plugins, marketplaces) |
| `install.ps1` | Copy these files into `~/.claude` (with backups) |

## What's NOT here (and why)

- **Secrets** — `.credentials.json`, `daemon/pipe.key`, `.claude.json` are auth/state. Never commit.
- **Private data** — `projects/`, `sessions/`, `history.jsonl`, `file-history/` hold transcripts and code refs.
- **Installed plugins** — `plugins/` is machine state, reproduced from `settings.example.json` + marketplaces below.

## Install

```powershell
.\install.ps1
```

Copy mode — re-run after editing repo files to re-sync. Overwritten files are backed up as `*.bak-<timestamp>`.

Then merge `settings.example.json` into `~/.claude/settings.json` by hand (review `enabledPlugins` / `mcpServers` first).

## External dependencies (install separately)

These are referenced by my config but live in their own projects:

- **lean-ctx** — MCP context runtime. Install via its skill (`/lean-ctx`) or its repo.
- **caveman** — compression/persona plugin. Marketplace: `https://github.com/juliusbrussee/caveman.git`
- **karpathy-skills** — `forrestchang/andrej-karpathy-skills`

Add a marketplace in Claude Code:

```
/plugin marketplace add <url-or-repo>
```

Then enable the plugins listed under `enabledPlugins` in `settings.example.json`.

## Before pushing

Scan for accidental secrets:

```powershell
gitleaks detect --source .
```
