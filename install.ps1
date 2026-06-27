# install.ps1 - copy this repo's Claude config into ~/.claude
# Copy mode: re-run after editing repo files to sync. Backs up anything it overwrites.

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$dest = Join-Path $env:USERPROFILE ".claude"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

$files = @(
    "CLAUDE.md",
    "statusline.ps1",
    "rules\lean-ctx.md",
    "skills\babr\SKILL.md",
    "skills\ship\SKILL.md",
    "skills\migration-status\SKILL.md"
)

foreach ($rel in $files) {
    $src = Join-Path $repo $rel
    $dst = Join-Path $dest $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    if (Test-Path $dst) {
        Copy-Item $dst "$dst.bak-$stamp"
        Write-Host "backup: $dst.bak-$stamp"
    }
    Copy-Item $src $dst -Force
    Write-Host "copied: $rel"
}

Write-Host ""

# clip-watch - register the clipboard image watcher to auto-start at login.
# Runs from the repo (tools\clip-watch.ps1); a Startup-folder shortcut launches it hidden via the VBS wrapper.
$vbs = Join-Path $repo "tools\launch-clip-watch.vbs"
if (Test-Path $vbs) {
    $startup = [Environment]::GetFolderPath('Startup')
    $lnk = Join-Path $startup "clip-watch.lnk"
    $w = New-Object -ComObject WScript.Shell
    $sc = $w.CreateShortcut($lnk)
    $sc.TargetPath = "$env:WINDIR\System32\wscript.exe"
    $sc.Arguments = "`"$vbs`""
    $sc.WindowStyle = 7
    $sc.Description = "Clipboard image watcher for Claude Code"
    $sc.Save()
    Write-Host "startup: $lnk -> $vbs"
    Write-Host "  (launch now without reboot: wscript `"$vbs`")"
}

Write-Host ""
Write-Host "settings.example.json NOT copied automatically - merge by hand into ~/.claude/settings.json"
Write-Host "(it overwrites enabledPlugins/mcpServers; review before applying)."
Write-Host "Done."
