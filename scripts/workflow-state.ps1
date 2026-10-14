# Reads and writes the workflow status ledger, .claude/work/status.md, of the
# project in the current directory (or -Root). The ledger format and its rules
# are defined in templates/work/status.md. This script is the only thing that
# hashes files and writes rows.
#
#   workflow-state.ps1 check  [-Item <id>]
#   workflow-state.ps1 record -Gate <gate> -Subject <subject> [-Verdict PASS|APPROVED]
#                             [-By reviewer|user] [-Inputs <path>,<path>] [-WithScope] [-Note <text>]
#
# Exit codes: 0 done, 2 error. `check` always exits 0 when it could read the
# ledger, whatever the states are.

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('check', 'record')]
    [string]$Command,
    [string]$Root = (Get-Location).Path,
    [string]$Item,
    [string]$Gate,
    [string]$Subject,
    [string]$Verdict,
    [string]$By,
    [string[]]$Inputs = @(),
    [switch]$WithScope,
    [string]$Note = '',
    # A comma list can reach a script started with -File as separate words: they are inputs too.
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$MoreInputs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Gates whose rows depend on one another, earliest first.
$ChainOrder = @('test-feature', 'review-code', 'update-docs', 'deploy-check')
$Gates = @('scope', 'review-spec', 'architecture', 'test-feature', 'review-code', 'update-docs', 'deploy-check', 'approval')

function Fail([string]$Message) {
    [Console]::Error.WriteLine("workflow-state: $Message")
    exit 2
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail 'git was not found, so nothing can be hashed and no row counts.'
}
if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Fail "Root is not a directory: $Root"
}
$Root = (Resolve-Path -LiteralPath $Root).Path
$LedgerPath = Join-Path $Root '.claude\work\status.md'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-ItemId([string]$Subj) {
    return ($Subj -split '[/@#]')[0]
}

function Normalize-RelPath([string]$P) {
    $n = $P.Trim().Replace('\', '/')
    while ($n.StartsWith('./')) { $n = $n.Substring(2) }
    if ($n -eq '' -or $n.StartsWith('/') -or $n -match '^[A-Za-z]:' -or ($n -split '/') -contains '..') {
        Fail "Not a path relative to the project root: $P"
    }
    if ($n.Contains('|') -or $n.Contains(';')) {
        Fail "A path may not contain '|' or ';': $P"
    }
    return $n
}

function Get-ContentHash([string]$Rel) {
    $full = Join-Path $Root $Rel
    if (-not (Test-Path -LiteralPath $full)) { return 'absent' }
    if (Test-Path -LiteralPath $full -PathType Container) { Fail "An input must be a file, not a directory: $Rel" }
    $out = & git -C $Root hash-object --no-filters -- $Rel
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($out)) { Fail "git could not hash: $Rel" }
    return ([string]$out).Trim()
}

# Hash of the project files, outside .claude, that Git sees (tracked or
# untracked and not ignored) and that no scope row of any work item lists. A new
# file that nobody has claimed could belong to anything, so it makes every PASS
# stale. Once a work item claims it in its scope row, it leaves this set, so the
# PASSes of the other work items are not disturbed. Returns $null when Root is
# not a Git work tree.
function Get-FileSetHash($Rows) {
    # Windows PowerShell 5.1 turns native stderr into an error under 'Stop'.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $raw = & git -C $Root ls-files -z -c -o --exclude-standard 2>$null }
    finally { $ErrorActionPreference = $previous }
    if ($LASTEXITCODE -ne 0) { return $null }
    $claimed = @{}
    foreach ($r in @($Rows | Where-Object { $_.Gate -eq 'scope' })) {
        foreach ($e in (Read-Inputs $r.InputsField).Entries) { $claimed[$e.Path] = $true }
    }
    $names = @(([string]($raw -join '')).Split([char]0) | Where-Object { $_ -ne '' -and -not $_.StartsWith('.claude/') -and -not $claimed.ContainsKey($_) })
    $names = [string[]]$names
    [array]::Sort($names, [System.StringComparer]::Ordinal)
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        [System.IO.File]::WriteAllText($tmp, (($names -join "`n") + "`n"), $Utf8)
        return ([string](& git hash-object --no-filters -- $tmp)).Trim()
    }
    finally { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
}

# Splits "path@hash;path@hash;+scope;+files@hash" into entries and the markers.
function Read-Inputs([string]$Field) {
    $entries = New-Object System.Collections.ArrayList
    $withScope = $false
    $filesHash = $null
    if ($Field -ne '-' -and $Field -ne '') {
        foreach ($part in $Field.Split(';')) {
            $p = $part.Trim()
            if ($p -eq '') { continue }
            if ($p -eq '+scope') { $withScope = $true; continue }
            if ($p.StartsWith('+files@')) { $filesHash = $p.Substring(7); continue }
            $at = $p.LastIndexOf('@')
            if ($at -lt 1) { Fail "Malformed input entry in the ledger: $p" }
            [void]$entries.Add([pscustomobject]@{ Path = $p.Substring(0, $at); Hash = $p.Substring($at + 1) })
        }
    }
    return [pscustomobject]@{ Entries = @($entries); WithScope = $withScope; FilesHash = $filesHash }
}

function Read-Ledger {
    if (-not (Test-Path -LiteralPath $LedgerPath -PathType Leaf)) { return $null }
    $text = [System.IO.File]::ReadAllText($LedgerPath, $Utf8)
    $lines = $text -split "`r?`n"
    $headerEnd = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\|\s*---') { $headerEnd = $i; break }
    }
    if ($headerEnd -lt 0) { Fail "The ledger has no table: $LedgerPath" }
    $rows = New-Object System.Collections.ArrayList
    for ($i = $headerEnd + 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()
        if ($line -eq '') { continue }
        if (-not $line.StartsWith('|')) { Fail "Unexpected line in the ledger table: $line" }
        $cells = $line.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if (@($cells).Count -ne 7) { Fail "A ledger row must have 7 cells: $line" }
        $c = @($cells)
        [void]$rows.Add([pscustomobject]@{
            Gate = $c[0]; Subject = $c[1]; Verdict = $c[2]; By = $c[3]
            InputsField = $c[4]; Note = $c[5]; Date = $c[6]
            State = ''; Reason = ''
        })
    }
    return [pscustomobject]@{ Header = @($lines[0..$headerEnd]); Rows = $rows }
}

function Write-Ledger($Header, $Rows) {
    $out = New-Object System.Collections.ArrayList
    foreach ($h in $Header) { [void]$out.Add($h) }
    foreach ($r in $Rows) {
        [void]$out.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} |' -f $r.Gate, $r.Subject, $r.Verdict, $r.By, $r.InputsField, $r.Note, $r.Date))
    }
    $tmp = "$LedgerPath.tmp"
    [System.IO.File]::WriteAllText($tmp, (($out -join "`n") + "`n"), $Utf8)
    Move-Item -LiteralPath $tmp -Destination $LedgerPath -Force
}

function Get-OwnState($Row, $Rows) {
    if ($Row.Gate -eq 'scope') { $Row.State = 'SCOPE'; return }
    $in = Read-Inputs $Row.InputsField
    $reasons = New-Object System.Collections.ArrayList
    foreach ($e in $in.Entries) {
        if ((Get-ContentHash $e.Path) -ne $e.Hash) { [void]$reasons.Add("changed: $($e.Path)") }
    }
    if ($in.FilesHash) {
        $now = Get-FileSetHash $Rows
        if ($now -and $now -ne $in.FilesHash) { [void]$reasons.Add('an unclaimed project file was added or removed') }
    }
    if ($in.WithScope) {
        $scope = @($Rows | Where-Object { $_.Gate -eq 'scope' -and $_.Subject -eq (Get-ItemId $Row.Subject) })
        if ($scope.Count -eq 0) {
            [void]$reasons.Add('scope row missing')
        }
        else {
            $recorded = @($in.Entries | ForEach-Object { $_.Path })
            foreach ($s in (Read-Inputs $scope[0].InputsField).Entries) {
                if ($recorded -notcontains $s.Path) { [void]$reasons.Add("scope grew: $($s.Path)") }
            }
        }
    }
    if ($reasons.Count -gt 0) {
        $Row.State = 'STALE'
        $Row.Reason = (@($reasons) | Select-Object -First 3) -join '; '
        if ($reasons.Count -gt 3) { $Row.Reason += "; +$($reasons.Count - 3) more" }
    }
    else {
        $Row.State = 'FRESH'
    }
}

function Set-AllStates($Rows) {
    foreach ($r in $Rows) { Get-OwnState $r $Rows }
    foreach ($gate in $ChainOrder) {
        $idx = [array]::IndexOf($ChainOrder, $gate)
        foreach ($r in @($Rows | Where-Object { $_.Gate -eq $gate -and $_.State -eq 'FRESH' })) {
            $itemId = Get-ItemId $r.Subject
            foreach ($e in @($Rows | Where-Object { (Get-ItemId $_.Subject) -eq $itemId -and [array]::IndexOf($ChainOrder, $_.Gate) -ge 0 -and [array]::IndexOf($ChainOrder, $_.Gate) -lt $idx })) {
                if ($e.State -ne 'FRESH') {
                    $r.State = 'STALE'; $r.Reason = "earlier gate $($e.Gate) is not fresh"; break
                }
                if ([string]::CompareOrdinal($e.Date, $r.Date) -gt 0) {
                    $r.State = 'STALE'; $r.Reason = "earlier gate $($e.Gate) was recorded later"; break
                }
            }
        }
    }
}

if ($Command -eq 'check') {
    $ledger = Read-Ledger
    if ($null -eq $ledger) { Write-Output 'No ledger: nothing is established.'; exit 0 }
    Set-AllStates $ledger.Rows
    $shown = @($ledger.Rows | Where-Object { -not $Item -or (Get-ItemId $_.Subject) -eq $Item -or $_.Subject -eq $Item })
    if ($shown.Count -eq 0) { Write-Output 'No rows.'; exit 0 }
    foreach ($r in $shown) {
        $line = '{0,-6} {1,-13} {2,-34} {3,-8}' -f $r.State, $r.Gate, $r.Subject, $r.By
        if ($r.Reason) { $line += " $($r.Reason)" }
        Write-Output $line.TrimEnd()
    }
    exit 0
}

# --- record ---

if ($Gates -notcontains $Gate) { Fail "-Gate must be one of: $($Gates -join ', ')" }
if ([string]::IsNullOrWhiteSpace($Subject) -or $Subject -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*(?:[/@#][A-Za-z0-9._:-]+)?$') {
    Fail '-Subject is missing or malformed.'
}
if ($Gate -eq 'scope' -and $Subject -match '[/@#]') { Fail 'A scope subject is a bare work item id.' }
if ($Gate -eq 'approval' -and $Subject -notmatch '#') { Fail 'An approval subject is <id>#<topic> or project#<topic>.' }

switch ($Gate) {
    'scope' { if (-not $Verdict) { $Verdict = '-' }; if (-not $By) { $By = '-' }
        if ($Verdict -ne '-' -or $By -ne '-') { Fail 'A scope row has no verdict and no author.' } }
    'approval' { if (-not $Verdict) { $Verdict = 'APPROVED' }; if (-not $By) { $By = 'user' }
        if ($Verdict -ne 'APPROVED' -or $By -ne 'user') { Fail 'An approval is APPROVED by user.' } }
    default { if (-not $Verdict) { $Verdict = 'PASS' }; if (-not $By) { $By = 'reviewer' }
        if ($Verdict -ne 'PASS') { Fail 'Only a PASS is recorded.' }
        if (@('reviewer', 'user') -notcontains $By) { Fail '-By must be reviewer or user.' } }
}

$paths = New-Object System.Collections.ArrayList
foreach ($raw in (@($Inputs) + @($MoreInputs))) {
    foreach ($p in $raw.Split(',')) {
        if ($p.Trim() -eq '') { continue }
        $n = Normalize-RelPath $p
        if ($paths -notcontains $n) { [void]$paths.Add($n) }
    }
}

$ledger = Read-Ledger
if ($null -eq $ledger) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root '.claude\work') -PathType Container)) {
        Fail 'There is no .claude\work folder. Run /init-project first.'
    }
    $template = Join-Path (Split-Path -Parent $PSScriptRoot) 'templates\work\status.md'
    if (-not (Test-Path -LiteralPath $template -PathType Leaf)) { Fail "The ledger template is missing: $template" }
    $tl = [System.IO.File]::ReadAllText($template, $Utf8) -split "`r?`n"
    $end = -1
    for ($i = 0; $i -lt $tl.Count; $i++) { if ($tl[$i] -match '^\|\s*---') { $end = $i; break } }
    if ($end -lt 0) { Fail 'The ledger template has no table.' }
    $ledger = [pscustomobject]@{ Header = @($tl[0..$end]); Rows = (New-Object System.Collections.ArrayList) }
}

if ($WithScope) {
    $scope = @($ledger.Rows | Where-Object { $_.Gate -eq 'scope' -and $_.Subject -eq (Get-ItemId $Subject) })
    if ($scope.Count -eq 0) { Fail "There is no scope row for work item '$(Get-ItemId $Subject)'. /build-feature records it." }
    foreach ($s in (Read-Inputs $scope[0].InputsField).Entries) {
        if ($paths -notcontains $s.Path) { [void]$paths.Add($s.Path) }
    }
}
if ($Gate -ne 'approval' -and $paths.Count -eq 0) { Fail 'A gate or scope row needs at least one input.' }

$parts = New-Object System.Collections.ArrayList
foreach ($p in $paths) { [void]$parts.Add("$p@$(Get-ContentHash $p)") }
if ($WithScope) {
    [void]$parts.Add('+scope')
    $fileSet = Get-FileSetHash $ledger.Rows
    if ($fileSet) { [void]$parts.Add("+files@$fileSet") }
}
$noteText = ($Note -replace '[\r\n]+', ' ' -replace '\|', '/').Trim()
if ($noteText -eq '') { $noteText = '-' }

$row = [pscustomobject]@{
    Gate = $Gate; Subject = $Subject; Verdict = $Verdict; By = $By
    InputsField = $(if ($parts.Count -eq 0) { '-' } else { $parts -join ';' })
    Note = $noteText; Date = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    State = ''; Reason = ''
}

$replaced = $false
for ($i = 0; $i -lt $ledger.Rows.Count; $i++) {
    if ($ledger.Rows[$i].Gate -eq $Gate -and $ledger.Rows[$i].Subject -eq $Subject) {
        $ledger.Rows[$i] = $row; $replaced = $true; break
    }
}
if (-not $replaced) { [void]$ledger.Rows.Add($row) }
Write-Ledger $ledger.Header $ledger.Rows
Write-Output ("recorded {0} {1} ({2} inputs){3}" -f $Gate, $Subject, $paths.Count, $(if ($replaced) { ', replaced the previous row' } else { '' }))
exit 0
