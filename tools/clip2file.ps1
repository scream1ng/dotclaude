#requires -version 5
# clip2file — save clipboard image to PNG, copy its path back to clipboard as text.
# Usage:  powershell -ExecutionPolicy Bypass -File clip2file.ps1 [outdir]
# After running, paste (Ctrl+V) into Claude Code to drop the file path.

param(
    [string]$OutDir = (Join-Path $env:USERPROFILE 'clip-shots')
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($null -eq $img) {
    Write-Host 'No image in clipboard. Snip first (Win+Shift+S), then run again.' -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$name = 'shot_{0}.png' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
$path = Join-Path $OutDir $name
$img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()

# put the path on the clipboard as text so Ctrl+V drops it into the terminal
Set-Clipboard -Value $path

Write-Host "Saved: $path" -ForegroundColor Green
Write-Host 'Path copied to clipboard. Ctrl+V in Claude Code.' -ForegroundColor Cyan
