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
| `skills/babr/` | Before / After / Benefit / Risk summary skill |
| `skills/ship/` | Standard git release flow (commit/push, merge-to-main, branch cleanup) |
| `skills/migration-status/` | Report outstanding DB migrations, staging vs prod |
| `tools/clip-watch.ps1` | Background watcher: clipboard image → PNG in inbox → path on clipboard (paste screenshots into the terminal) |
| `settings.example.json` | Sanitized `settings.json` (hooks, enabled plugins, marketplaces) |
| `install.ps1` | Copy these files into `~/.claude` (with backups) + register the clip-watch startup shortcut |

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

1. Copies into `~/.claude`: `CLAUDE.md`, `statusline.ps1`, `rules/lean-ctx.md`, and the `skills/*` (babr, ship, migration-status).
2. Registers the **clip-watch** clipboard watcher to auto-start at login (a shortcut in the Startup folder → `tools/launch-clip-watch.vbs`, which runs the watcher hidden from this repo).

### What you still do by hand

1. **Start clip-watch now** (the shortcut only fires at the *next* login):

   ```powershell
   wscript "E:\Coding Project\dotclaude\tools\launch-clip-watch.vbs"
   ```

2. **Merge settings** — copy the blocks you want from `settings.example.json` into `~/.claude/settings.json` (review `enabledPlugins` / `mcpServers` / `statusLine` first; it is not copied automatically because it would overwrite live state).

3. **Install external plugins** — see [External dependencies](#external-dependencies-install-separately) below (lean-ctx, caveman, karpathy-skills are separate repos/marketplaces).

After step 1, the snip → `Ctrl+V` flow works (see [Clipboard image paste](#clipboard-image-paste-toolsclip-watchps1)). On a fresh machine the watcher then starts on its own every login.

> **Paths are machine-specific.** The autostart shortcut and the relaunch command above assume this repo lives at `E:\Coding Project\dotclaude`. If it lives elsewhere, re-run `install.ps1` from the new location (it rebuilds the shortcut from `$PSScriptRoot`) — the `.vbs` itself is self-locating, so only the shortcut needs refreshing.

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

## Clipboard image paste (`tools/clip-watch.ps1`)

Windows Terminal can't accept image bytes on `Ctrl+V` — and the clipboard only ever holds one image. This watcher bridges that gap so screenshots reach Claude Code:

1. Snip (`Win+Shift+S` / `Alt+PrtSc`) — image lands on the clipboard
2. The watcher (polling every 800ms) saves it as a PNG to `~\clip-shots\inbox\` and **replaces the clipboard with that file's path**
3. `Ctrl+V` in Claude Code drops the path — the harness resolves it to the image

Repeat per photo, one at a time. No script to run each snip, no typing paths.

- **Inbox** — `~\clip-shots\inbox\`, auto-trimmed: deletes PNGs older than 1 hour, keeps only the newest 10.
- **Autostart** — `install.ps1` puts a shortcut in the Startup folder that launches `launch-clip-watch.vbs` (hidden, no console flash), which runs the watcher from this repo.
- **Launch now without reboot:** `wscript "E:\Coding Project\dotclaude\tools\launch-clip-watch.vbs"`
- **Stop:** delete `clip-watch.lnk` from the Startup folder and `Stop-Process` the hidden `powershell` running it.

`clip2file.ps1` is the manual one-shot version (save clipboard image once, copy its path) if you don't want the watcher running.

## Before pushing

Scan for accidental secrets:

```powershell
gitleaks detect --source .
```
