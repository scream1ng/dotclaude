#requires -version 5
# clip-watch — background clipboard watcher.
# Polls clipboard; when a NEW image appears, saves it to the inbox folder.
# Run once; leave it running. Snip anytime (Win+Shift+S / Alt+PrtSc).

param(
    [string]$Inbox = (Join-Path $env:USERPROFILE 'clip-shots\inbox'),
    [int]$PollMs = 800
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $Inbox)) { New-Item -ItemType Directory -Path $Inbox -Force | Out-Null }

$lastHash = ''
$md5 = [System.Security.Cryptography.MD5]::Create()

while ($true) {
    try {
        $img = [System.Windows.Forms.Clipboard]::GetImage()
        if ($null -ne $img) {
            $ms = New-Object System.IO.MemoryStream
            $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $bytes = $ms.ToArray()
            $hash = [BitConverter]::ToString($md5.ComputeHash($bytes))
            if ($hash -ne $lastHash) {
                $lastHash = $hash
                $name = 'shot_{0}.png' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
                $path = Join-Path $Inbox $name
                [System.IO.File]::WriteAllBytes($path, $bytes)
                # replace clipboard with the file path so Ctrl+V drops it into the terminal
                [System.Windows.Forms.Clipboard]::SetText($path)
                $lastHash = ''  # path text clears the image; reset so next identical snip still saves
            }
            $ms.Dispose()
            $img.Dispose()
        }
    } catch { }

    # cleanup: drop files older than 1 hour, then keep only the newest 10
    try {
        $cutoff = (Get-Date).AddHours(-1)
        $files = Get-ChildItem $Inbox -Filter *.png | Sort-Object LastWriteTime -Descending
        foreach ($f in $files) { if ($f.LastWriteTime -lt $cutoff) { Remove-Item $f.FullName -Force -EA SilentlyContinue } }
        $files = Get-ChildItem $Inbox -Filter *.png | Sort-Object LastWriteTime -Descending
        if ($files.Count -gt 10) { $files | Select-Object -Skip 10 | ForEach-Object { Remove-Item $_.FullName -Force -EA SilentlyContinue } }
    } catch { }

    Start-Sleep -Milliseconds $PollMs
}
