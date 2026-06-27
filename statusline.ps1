$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# Claude Code pipes session JSON on stdin
$raw = [Console]::In.ReadToEnd()
$ctx = $raw | ConvertFrom-Json

$dir = $ctx.workspace.current_dir
if (-not $dir) { $dir = $ctx.cwd }
if (-not $dir) { $dir = (Get-Location).Path }
$project = Split-Path $dir -Leaf

# --- git info ---
$branch = ''; $dirty = ''; $track = ''; $worktree = $false
Push-Location $dir
$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
if ($branch) {
    if (git status --porcelain 2>$null) { $dirty = '*' }
    $up = git rev-parse --abbrev-ref '@{u}' 2>$null
    if ($up) {
        $counts = git rev-list --left-right --count "$up...HEAD" 2>$null
        if ($counts) {
            $lr = $counts -split '\s+'; $behind=[int]$lr[0]; $ahead=[int]$lr[1]
            $t=@(); if($ahead -gt 0){$t+="$([char]0x2191)$ahead"}; if($behind -gt 0){$t+="$([char]0x2193)$behind"}
            if ($t) { $track = ($t -join ' ') }
        }
    }
    $gd = git rev-parse --git-dir 2>$null; $cd = git rev-parse --git-common-dir 2>$null
    if ($gd -and $cd -and ($gd -ne $cd)) { $worktree = $true }
}
Pop-Location

# --- usage (cached 60s) ---
$cache = Join-Path $env:TEMP 'cc_usage.json'
$fresh = $false
if (Test-Path $cache) {
    if (((Get-Date) - (Get-Item $cache).LastWriteTime).TotalSeconds -lt 60) { $fresh = $true }
}
if (-not $fresh) {
    try {
        $o = (Get-Content "$env:USERPROFILE\.claude\.credentials.json" -Raw | ConvertFrom-Json).claudeAiOauth
        $h = @{ Authorization = "Bearer $($o.accessToken)"; 'anthropic-beta' = 'oauth-2025-04-20' }
        $r = Invoke-RestMethod -Uri 'https://api.anthropic.com/api/oauth/usage' -Headers $h -Method GET -TimeoutSec 4
        ($r | ConvertTo-Json -Depth 8) | Out-File $cache -Encoding ascii
    } catch { }
}
$u = $null
if (Test-Path $cache) { $u = Get-Content $cache -Raw | ConvertFrom-Json }

# --- helpers ---
$e = [char]27; $r0 = "$e[0m"
$gFull = [char]0x2593  # block
$gEmpty = [char]0x2591  # light shade
function Bar($pct) {
    $cells = 10
    $fill = [math]::Round($pct / 10.0); if ($fill -gt $cells) { $fill = $cells }
    $bar = ([string]$gFull * $fill) + ([string]$gEmpty * ($cells - $fill))
    if ($pct -ge 85) { $c = "$e[31m" } elseif ($pct -ge 60) { $c = "$e[33m" } else { $c = "$e[97m" }
    "$c$bar$r0 $e[97m$pct%$r0"
}
function Left($iso) {
    $d = ([datetimeoffset]$iso) - [datetimeoffset]::Now
    if ($d.TotalSeconds -le 0) { return '0m' }
    if ($d.TotalHours -ge 3) { return "$([math]::Floor($d.TotalHours))h" }
    if ($d.TotalHours -ge 1) {
        $hh=[math]::Floor($d.TotalHours); $mm=$d.Minutes
        if ($mm -gt 0) { return "${hh}h${mm}m" } else { return "${hh}h" }
    }
    return "$([math]::Ceiling($d.TotalMinutes))m"
}

# --- colors ---
$w="$e[97m"; $cProj="$e[36m"; $cBranch="$e[33m"; $cDirty="$e[31m"; $cTrack="$e[32m"; $cWork="$e[34m"; $cReset=$w; $cCave="$e[35m"

$parts = @("$cProj$project$r0")
if ($branch) {
    $b = "$cBranch$branch$r0"
    if ($dirty) { $b += "$cDirty$dirty$r0" }
    if ($track) { $b += " $cTrack$track$r0" }
    $parts += $b
}
if ($worktree) { $parts += "${cWork}[worktree]$r0" }

if ($u) {
    $seg = @()
    if ($u.five_hour) { $seg += ("${w}5h$r0 " + (Bar([int]$u.five_hour.utilization)) + " ${cReset}$(Left $u.five_hour.resets_at)$r0") }
    if ($u.seven_day) { $seg += ("${w}7d$r0 " + (Bar([int]$u.seven_day.utilization)) + " ${cReset}$(Left $u.seven_day.resets_at)$r0") }
    if ($seg) { $parts += ($seg -join " $e[90m$([char]0x00B7)$r0 ") }
}

$parts += "${cCave}[CAVEMAN]$r0"
$parts -join " $e[90m|$r0 "
