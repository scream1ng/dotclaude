# dotclaude

My [Claude Code](https://claude.com/claude-code) global config — instructions, rules, and custom skills.

> **Private repo.** Contains my workflow preferences. Secrets and session data are
> excluded by `.gitignore` and were never copied here.

## What's included

| Path | What |
|------|------|
| `CLAUDE.md` | Global instructions: lean-ctx routing, Karpathy coding guidelines |
| `statusline.ps1` | Custom status line: project, git branch/dirty/worktree, real 5h + 7-day usage bars |
| `rules/lean-ctx.md` | lean-ctx tool-mapping rules (imported by `CLAUDE.md`) |
| `skills/ship/` | Standard git release flow (commit/push, merge-to-main, branch cleanup) |
| `skills/migration-status/` | Report outstanding DB migrations, staging vs prod |
| `skills/issue/` | Fetch open GitHub issues, investigate codebase, report difficulty + DB-touch table |
| `skills/handoff/` | Compact the current conversation into a handoff doc for a fresh agent to continue |
| `skills/grilling/` | Relentless one-at-a-time interview to stress-test a plan/decision before acting |
| `skills/grill-me/` | Alias skill — runs `/grilling` |
| `skills/implement/` | Pick up an HTML prototype from `plan/` and build the real feature end-to-end |
| `skills/prototype/` | Turn a plan/feature discussion into a picture-driven HTML mockup, saved under `plan/` |
| `skills/plain-table/` | Turn a technical findings list into a plain-language before/after/benefit table |
| `skills/plain-text/` | Turn one technical explanation/plan/diff summary into short plain-language prose |
| `skills/qa/` | Drive a real browser through the changed flow, find bugs, fix them, write a regression test per fix |
| `skills/design-system/` | Bootstrap/refresh `DESIGN.md` — tokens, spacing, components — one-time source of truth for design consistency |
| `skills/design-review/` | Audit a screen (mockup or live URL) against `DESIGN.md`, flag inconsistencies and AI-slop patterns, findings only |
| `tools/snipshot.cs` | Tray app: global hotkey (`Ctrl+Shift+S`) snips a region → saves PNG → copies its path (paste screenshots into Claude Code) |
| `settings.example.json` | Sanitized `settings.json` (hooks, enabled plugins, marketplaces) |
| `install.ps1` | Copy these files into `~/.claude` (with backups) |

## Workflow

The skills chain into one sprint flow — each stage's output feeds the next:

```
grilling → prototype → implement → design-review → /code-review → qa → ship
```

- **grilling** — stress-test the idea before writing code (premises, edge cases, scope)
- **prototype** — low-text HTML mockup of the agreed shape, saved to `plan/`
- **implement** — build the real feature from the mockup, hunt bugs, run tests
- **design-review** — audit the real, running screen against `DESIGN.md` — catches states (hover/loading/error/responsive) a static mockup can't show
- **/code-review** — built-in staff-eng pass over the diff, catches what CI won't
- **qa** — real browser click-through of the changed flow, fixes bugs found, writes a regression test per fix
- **ship** — commit, push, merge to main, cleanup

`design-system` isn't in the chain — it's a one-time (or occasional refresh) step that
writes `DESIGN.md`, which `prototype` and `design-review` then read from. Run it once
per project before the first `prototype`, or after a deliberate visual overhaul.

Small example:

```
You: I want a "mark all read" button on the notifications list.
You: grilling        → clarifies: soft-delete or read-flag? scoped to visible page or all?
You: /prototype       → plan/mark-all-read.html
You: /implement       → builds it, adds disabled-state while pending, runs test suite
You: /design-review localhost:3000/notifications
                      → button color drifts from DESIGN.md token, you fix
You: /code-review     → flags missing auth check on the bulk endpoint, you fix
You: /qa localhost:3000/notifications
                      → clicks it, finds double-click fires two requests, fixes + adds test
You: /ship            → feat/mark-all-read → main, branch cleaned up
```

## What's NOT here (and why)

- **Secrets** — `.credentials.json`, `daemon/pipe.key`, `.claude.json` are auth/state. Never commit.
- **Private data** — `projects/`, `sessions/`, `history.jsonl`, `file-history/` hold transcripts and code refs.
- **Installed plugins** — `plugins/` is machine state, reproduced from `settings.example.json` + marketplaces below.

## Install

```powershell
.\install.ps1
```

Copy mode — re-run after editing repo files to re-sync. Overwritten files are backed up as `*.bak-<timestamp>`.

### What `install.ps1` does automatically

1. Copies into `~/.claude`: `CLAUDE.md`, `statusline.ps1`, `rules/lean-ctx.md`, and the `skills/*` (ship, migration-status, issue, handoff, grilling, grill-me, implement, prototype, plain-table, plain-text, qa, design-system, design-review).
2. Builds `tools/snipshot.exe` (in-box C# compiler — no SDK needed), registers it to auto-start at login (Startup-folder shortcut), and launches it. See [Clipboard image paste](#clipboard-image-paste-toolssnipshotcs).

### What you still do by hand

1. **Merge settings** — copy the blocks you want from `settings.example.json` into `~/.claude/settings.json` (review `enabledPlugins` / `mcpServers` / `statusLine` first; it is not copied automatically because it would overwrite live state).

2. **Install external plugins** — see [External dependencies](#external-dependencies-install-separately) below (lean-ctx, caveman, karpathy-skills are separate repos/marketplaces).

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

## Status line

`statusline.ps1` renders, left to right:

```
Coding Project | main* ↑2 | [worktree] | 5h ▓▓▓▓░░░░░░ 43% 2h14m · 7d ▓▓▓▓▓░░░░░ 52% 11h | [CAVEMAN]
```

- **project** — current folder name (cyan)
- **branch** — git branch (yellow), `*` = uncommitted, `↑↓` = ahead/behind upstream, `[worktree]` when in a linked worktree
- **5h / 7d usage** — real plan limits from `GET https://api.anthropic.com/api/oauth/usage` (the same data `/usage` shows). Bar is white < 60%, yellow ≥ 60, red ≥ 85. Reset countdown trails each. Cached 60s in `$TEMP/cc_usage.json` so it is not a network call every render.

Enable by merging the `statusLine` block from `settings.example.json` into `~/.claude/settings.json`. The command path is absolute — fix the user folder if it differs.

Notes:
- Reads the OAuth token from `~/.claude/.credentials.json` (kept fresh by Claude Code). If it ever expires, the usage segments silently drop; the rest of the bar still renders.
- The usage endpoint is undocumented and may change; the script fails soft if it does.
- To disable: delete the `statusLine` block from `settings.json`.

## Clipboard image paste (`tools/snipshot.cs`)

Claude Code on Windows **can't** accept a pasted clipboard image — `Ctrl+V` of image bytes is ignored ([claude-code#26679](https://github.com/anthropics/claude-code/issues/26679)). Only a file **path** or a drag-dropped file works. **SnipShot** is a tiny tray app that bridges the gap with a global hotkey:

1. Press **`Ctrl+Shift+S`** — the Windows snip overlay opens; drag a region
2. SnipShot saves the image as a PNG to `~\clip-shots\` and **copies that file's path to the clipboard** (tray balloon confirms)
3. `Ctrl+V` in Claude Code drops the path — the harness resolves it to the image

`Win+Shift+S` is left untouched, so it still puts a plain **image** on the clipboard for pasting into a browser. Two keys, two behaviours, no clipboard conflict.

- **Build:** a single `~9 KB` `.exe` compiled from `snipshot.cs` by the in-box `csc.exe` — **no .NET SDK or runtime to install** (.NET Framework 4 ships with Windows). `install.ps1` builds and registers it automatically.
- **Hotkey:** a real Win32 `RegisterHotKey` (not key polling) — reliable, no AltGr clash.
- **Tray menu:** *Snip now* · *Open folder* · *Exit*. Double-click the tray icon also snips. The `~\clip-shots\` folder auto-trims to the newest 20 PNGs.
- **Autostart:** a Startup-folder shortcut (`snipshot.lnk`) launches it every login. The shortcut hardcodes the exe path — if you move the repo, re-run `install.ps1` to rebuild it.

Build by hand (if not using `install.ps1`):

```powershell
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe `
  /out:tools\snipshot.exe /reference:System.Drawing.dll /reference:System.Windows.Forms.dll `
  tools\snipshot.cs
```

## Before pushing

Scan for accidental secrets:

```powershell
gitleaks detect --source .
```
