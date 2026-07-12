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
    "skills\ship\SKILL.md",
    "skills\migration-status\SKILL.md",
    "skills\issue\SKILL.md"
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

# snipshot - build the screenshot->path tray app and register it to auto-start at login.
$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$src = Join-Path $repo "tools\snipshot.cs"
$exe = Join-Path $repo "tools\snipshot.exe"
if ((Test-Path $csc) -and (Test-Path $src)) {
    & $csc /nologo /target:winexe /out:$exe /reference:System.Drawing.dll /reference:System.Windows.Forms.dll $src
    if (Test-Path $exe) {
        Write-Host "built: tools\snipshot.exe"
        $startup = [Environment]::GetFolderPath('Startup')
        $lnk = Join-Path $startup "snipshot.lnk"
        $w = New-Object -ComObject WScript.Shell
        $sc = $w.CreateShortcut($lnk)
        $sc.TargetPath = $exe
        $sc.Description = "SnipShot - Ctrl+Shift+S snip to path for Claude Code"
        $sc.Save()
        Write-Host "startup: $lnk -> $exe"
        if (-not (Get-Process snipshot -ErrorAction SilentlyContinue)) { Start-Process $exe; Write-Host "launched snipshot" }
    } else {
        Write-Host "WARNING: snipshot build failed" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "settings.example.json NOT copied automatically - merge by hand into ~/.claude/settings.json"
Write-Host "(it overwrites enabledPlugins/mcpServers; review before applying)."
Write-Host "Done."
