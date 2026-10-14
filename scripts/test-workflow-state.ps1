# Deterministic regression checks for workflow-state.ps1. No model, no network,
# no framework installation: it builds throwaway projects under the system temp
# folder, runs the script in child PowerShell processes and removes them again.
#
#   powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\test-workflow-state.ps1
#
# Exit code 0 when every check passes, 1 otherwise.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script = Join-Path $PSScriptRoot 'workflow-state.ps1'
$base = Join-Path ([System.IO.Path]::GetTempPath()) ("workflow-state-test-" + [guid]::NewGuid().ToString('N'))
$failures = 0

function Run([string]$Project, [string[]]$Arguments) {
    Push-Location $Project
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script @Arguments 2>&1 | ForEach-Object { "$_" }
        return [pscustomobject]@{ Code = $LASTEXITCODE; Text = ($out -join "`n") }
    }
    finally { $ErrorActionPreference = $previous; Pop-Location }
}

function Expect([string]$Name, [bool]$Condition, [string]$Detail = '') {
    if ($Condition) { Write-Host "ok    $Name" }
    else { Write-Host "FAIL  $Name  $Detail"; $script:failures++ }
}

function State([string]$Project, [string]$Gate, [string]$Subject) {
    $r = Run $Project @('check')
    foreach ($line in ($r.Text -split "`n")) {
        if ($line -match "^(FRESH|STALE|SCOPE)\s+$([regex]::Escape($Gate))\s+$([regex]::Escape($Subject))(\s|$)") { return $Matches[1] }
    }
    return 'MISSING'
}

function NewProject([string]$Name, [bool]$Git) {
    $p = Join-Path $base $Name
    New-Item -ItemType Directory -Force (Join-Path $p '.claude\work'), (Join-Path $p 'src') | Out-Null
    if ($Git) { & git -C $p init -q }
    Set-Content (Join-Path $p 'src\a.py') 'a1'
    Set-Content (Join-Path $p 'src\b.py') 'b1'
    Set-Content (Join-Path $p 'spec.md') 'spec1'
    return $p
}

try {
    New-Item -ItemType Directory -Force $base | Out-Null

    # --- one work item with a scope and two dependent gates ---
    $p = NewProject 'main' $true
    $null = Run $p @('record', '-Gate', 'scope', '-Subject', 'item', '-Inputs', 'src/a.py,src/b.py', '-Note', 'kind=feature')
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md')
    Start-Sleep -Seconds 1
    $null = Run $p @('record', '-Gate', 'review-code', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md')
    Expect 'fresh right after recording' ((State $p 'test-feature' 'item') -eq 'FRESH' -and (State $p 'review-code' 'item') -eq 'FRESH')

    Set-Content (Join-Path $p 'src\a.py') 'a2'
    Expect 'edit of a scope file makes the PASS stale' ((State $p 'test-feature' 'item') -eq 'STALE')
    Set-Content (Join-Path $p 'src\a.py') 'a1'
    Expect 'restoring the content makes it fresh again' ((State $p 'test-feature' 'item') -eq 'FRESH')

    Set-Content (Join-Path $p 'spec.md') 'spec2'
    Expect 'edit of a non-scope input makes the PASS stale' ((State $p 'review-code' 'item') -eq 'STALE')
    Set-Content (Join-Path $p 'spec.md') 'spec1'

    # --- the regression: a relevant new file that no scope row lists ---
    Set-Content (Join-Path $p 'src\c.py') 'c1'
    Expect 'a new project file outside the scope makes the PASS stale' ((State $p 'test-feature' 'item') -eq 'STALE') ((Run $p @('check')).Text)
    Expect 'the reason names the unclaimed file' ((Run $p @('check')).Text -match 'unclaimed project file')
    Remove-Item (Join-Path $p 'src\c.py')
    Expect 'removing that file makes the PASS fresh again' ((State $p 'test-feature' 'item') -eq 'FRESH')

    Set-Content (Join-Path $p 'src\a.py') 'a1'
    Set-Content (Join-Path $p '.gitignore') "build/`n"
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md,.gitignore')
    New-Item -ItemType Directory -Force (Join-Path $p 'build') | Out-Null
    Set-Content (Join-Path $p 'build\out.txt') 'x'
    Expect 'a new ignored file does not make the PASS stale' ((State $p 'test-feature' 'item') -eq 'FRESH')
    Set-Content (Join-Path $p '.claude\work\other.md') 'x'
    Expect 'a new file under .claude does not make the PASS stale' ((State $p 'test-feature' 'item') -eq 'FRESH')

    Remove-Item (Join-Path $p 'src\b.py')
    Expect 'deleting a scope file makes the PASS stale' ((State $p 'test-feature' 'item') -eq 'STALE')
    Set-Content (Join-Path $p 'src\b.py') 'b1'

    # --- scope rewritten with a new file ---
    Set-Content (Join-Path $p 'src\c.py') 'c1'
    $null = Run $p @('record', '-Gate', 'scope', '-Subject', 'item', '-Inputs', 'src/a.py,src/b.py,src/c.py', '-Note', 'kind=feature')
    Expect 'a scope that now lists a new file makes the old PASS stale' ((State $p 'test-feature' 'item') -eq 'STALE')
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md,.gitignore')
    Expect 'recording again against the new scope makes it fresh' ((State $p 'test-feature' 'item') -eq 'FRESH')

    # --- two independent work items: a file claimed by the other one does not disturb this one ---
    Set-Content (Join-Path $p 'src\other1.py') 'o1'
    Expect 'before the other item claims its file, the unclaimed file stales every PASS' ((State $p 'test-feature' 'item') -eq 'STALE')
    $null = Run $p @('record', '-Gate', 'scope', '-Subject', 'other', '-Inputs', 'src/other1.py', '-Note', 'kind=feature')
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md,.gitignore')
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'other', '-WithScope')
    Expect 'both items are fresh once the file is claimed' ((State $p 'test-feature' 'item') -eq 'FRESH' -and (State $p 'test-feature' 'other') -eq 'FRESH')
    Set-Content (Join-Path $p 'src\other1.py') 'o2'
    Expect 'a change of the other item leaves this one fresh' ((State $p 'test-feature' 'item') -eq 'FRESH' -and (State $p 'test-feature' 'other') -eq 'STALE')
    Set-Content (Join-Path $p 'src\other1.py') 'o1'
    $null = Run $p @('record', '-Gate', 'scope', '-Subject', 'other', '-Inputs', 'src/other1.py,src/other2.py', '-Note', 'kind=feature')
    Set-Content (Join-Path $p 'src\other2.py') 'o2'
    Expect 'a new file claimed by the other item leaves this one fresh' ((State $p 'test-feature' 'item') -eq 'FRESH' -and (State $p 'test-feature' 'other') -eq 'STALE')
    Set-Content (Join-Path $p 'src\unrelated.py') 'u'
    Expect 'a new unclaimed file still stales this one' ((State $p 'test-feature' 'item') -eq 'STALE')
    Remove-Item (Join-Path $p 'src\unrelated.py')
    Expect 'and removing it restores it' ((State $p 'test-feature' 'item') -eq 'FRESH')

    # --- an earlier gate recorded later invalidates the later gate ---
    Start-Sleep -Seconds 1
    $null = Run $p @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope', '-Inputs', 'spec.md,.gitignore')
    Expect 'a later gate recorded before its predecessor is stale' ((State $p 'review-code' 'item') -eq 'STALE')

    # --- two microchanges keep separate states ---
    $q = NewProject 'micro' $true
    $null = Run $q @('record', '-Gate', 'scope', '-Subject', 'micro-one', '-Inputs', 'src/a.py', '-Note', 'kind=microchange')
    $null = Run $q @('record', '-Gate', 'scope', '-Subject', 'micro-two', '-Inputs', 'src/b.py', '-Note', 'kind=microchange')
    $null = Run $q @('record', '-Gate', 'test-feature', '-Subject', 'micro-one', '-WithScope')
    $null = Run $q @('record', '-Gate', 'test-feature', '-Subject', 'micro-two', '-WithScope')
    Set-Content (Join-Path $q 'src\a.py') 'a2'
    Expect 'a change of one microchange leaves the other fresh' ((State $q 'test-feature' 'micro-one') -eq 'STALE' -and (State $q 'test-feature' 'micro-two') -eq 'FRESH')

    # --- invalid calls are refused ---
    Expect 'a PASS cannot be recorded against a missing scope' ((Run $q @('record', '-Gate', 'review-code', '-Subject', 'ghost', '-WithScope')).Code -eq 2)
    Expect 'a gate row needs inputs' ((Run $q @('record', '-Gate', 'review-code', '-Subject', 'micro-one')).Code -eq 2)
    Expect 'only a PASS is recorded' ((Run $q @('record', '-Gate', 'review-code', '-Subject', 'micro-one', '-Verdict', 'FAIL', '-Inputs', 'src/a.py')).Code -eq 2)
    Expect 'a path outside the project is refused' ((Run $q @('record', '-Gate', 'review-code', '-Subject', 'micro-one', '-Inputs', '../x')).Code -eq 2)

    # --- an approval is bound to its artifact, an independent one is not ---
    $null = Run $q @('record', '-Gate', 'approval', '-Subject', 'micro-one#launch', '-Inputs', 'spec.md', '-Note', 'user said yes')
    $null = Run $q @('record', '-Gate', 'approval', '-Subject', 'micro-one#account', '-Note', 'external account exists')
    Set-Content (Join-Path $q 'spec.md') 'spec2'
    Expect 'an approval bound to a file goes stale with it' ((State $q 'approval' 'micro-one#launch') -eq 'STALE')
    Expect 'an independent approval stays fresh' ((State $q 'approval' 'micro-one#account') -eq 'FRESH')

    # --- a project that is not a Git work tree still hashes its inputs ---
    $n = NewProject 'nogit' $false
    $null = Run $n @('record', '-Gate', 'scope', '-Subject', 'item', '-Inputs', 'src/a.py', '-Note', 'kind=microchange')
    $null = Run $n @('record', '-Gate', 'test-feature', '-Subject', 'item', '-WithScope')
    Expect 'without Git the PASS is fresh until a scope file changes' ((State $n 'test-feature' 'item') -eq 'FRESH')
    Set-Content (Join-Path $n 'src\a.py') 'a2'
    Expect 'without Git a scope file change still makes it stale' ((State $n 'test-feature' 'item') -eq 'STALE')
}
finally {
    if (Test-Path -LiteralPath $base) { Remove-Item -LiteralPath $base -Recurse -Force -ErrorAction SilentlyContinue }
}

if ($failures -gt 0) { Write-Host "$failures check(s) failed."; exit 1 }
Write-Host 'All checks passed.'
exit 0
