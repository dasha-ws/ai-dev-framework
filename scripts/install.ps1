# Installs ai-dev-framework from this checked-out repository into the current
# user's Claude Code installation:
#
#   skills:    %USERPROFILE%\.claude\skills\<skill-name>\
#   agents:    %USERPROFILE%\.claude\agents\<agent-name>.md
#   templates: %USERPROFILE%\.claude\ai-dev-framework\templates\
#
# It installs framework artifacts only. It does not initialise a target project.
# The repository root is resolved from this script's own location, so the
# installer can be started from any working directory.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:WritesStarted = $false

# Runtime templates that the framework skills require. Preflight only: the copy
# itself installs the whole templates tree.
$RequiredTemplates = @(
    'CLAUDE.md',
    'product-spec.md',
    'project-context\SKILL.md',
    'project-context\context\product.md',
    'project-context\context\architecture.md',
    'project-context\context\development.md',
    'project-context\context\infrastructure.md',
    'project-context\context\ux-guide.md',
    'work\feature-spec.md',
    'work\tech-spec.md'
)

function Assert-NonEmptyFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
    if ((Get-Item -LiteralPath $Path).Length -eq 0) {
        throw "Required file is empty: $Path"
    }
}

# A directory this installer only passes through: it may be missing, and it may
# be a link, but it must not be a file.
function Assert-DirectoryOrAbsent {
    param([string]$Path)
    if ((Test-Path -LiteralPath $Path) -and -not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Expected a directory but found a file: $Path"
    }
}

# A directory this installer owns and replaces: it may be missing, but if it
# exists it must be a real directory, not a file and not a link.
function Assert-ReplaceableDirectory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $item = Get-Item -LiteralPath $Path -Force
    if (-not $item.PSIsContainer) {
        throw "Expected a directory but found a file: $Path"
    }
    $reparse = [System.IO.FileAttributes]::ReparsePoint
    if (($item.Attributes -band $reparse) -eq $reparse) {
        throw "Refusing to replace a junction or symbolic link: $Path"
    }
}

function Assert-FileTarget {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path -PathType Container) {
        throw "Expected a file but found a directory: $Path"
    }
}

# Makes $Destination an exact copy of $Source: whatever was in $Destination is
# removed first, so stale files do not survive an update.
function Sync-Directory {
    param([string]$Source, [string]$Destination)
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse
}

try {
    # --- Preflight: nothing is written until every check below has passed ---

    if ([string]::IsNullOrEmpty($PSScriptRoot)) {
        throw 'Cannot resolve the location of this script.'
    }
    $repoRoot = Split-Path -Parent $PSScriptRoot

    $userProfile = $env:USERPROFILE
    if ([string]::IsNullOrWhiteSpace($userProfile)) {
        throw 'USERPROFILE is not set.'
    }
    if (-not (Test-Path -LiteralPath $userProfile -PathType Container)) {
        throw "USERPROFILE does not point to an existing directory: $userProfile"
    }

    $skillsSource = Join-Path $repoRoot 'skills'
    $agentsSource = Join-Path $repoRoot 'agents'
    $templatesSource = Join-Path $repoRoot 'templates'
    foreach ($source in @($skillsSource, $agentsSource, $templatesSource)) {
        if (-not (Test-Path -LiteralPath $source -PathType Container)) {
            throw "Source directory is missing: $source"
        }
    }

    # Every top-level directory under skills\ is a framework skill and must hold a SKILL.md.
    $skills = @(Get-ChildItem -LiteralPath $skillsSource -Directory | Sort-Object Name)
    if ($skills.Count -eq 0) {
        throw "No framework skills found in: $skillsSource"
    }
    foreach ($skill in $skills) {
        Assert-NonEmptyFile (Join-Path $skill.FullName 'SKILL.md')
    }

    # Every Markdown file directly under agents\ is a framework agent.
    $agents = @(Get-ChildItem -LiteralPath $agentsSource -File |
        Where-Object { $_.Extension -eq '.md' } |
        Sort-Object Name)
    if ($agents.Count -eq 0) {
        throw "No framework agents found in: $agentsSource"
    }
    foreach ($agent in $agents) {
        Assert-NonEmptyFile $agent.FullName
    }

    foreach ($template in $RequiredTemplates) {
        Assert-NonEmptyFile (Join-Path $templatesSource $template)
    }

    $claudeRoot = Join-Path $userProfile '.claude'
    $skillsDestination = Join-Path $claudeRoot 'skills'
    $agentsDestination = Join-Path $claudeRoot 'agents'
    $frameworkRoot = Join-Path $claudeRoot 'ai-dev-framework'
    $templatesDestination = Join-Path $frameworkRoot 'templates'

    foreach ($path in @($claudeRoot, $skillsDestination, $agentsDestination, $frameworkRoot)) {
        Assert-DirectoryOrAbsent $path
    }
    Assert-ReplaceableDirectory $templatesDestination
    foreach ($skill in $skills) {
        Assert-ReplaceableDirectory (Join-Path $skillsDestination $skill.Name)
    }
    foreach ($agent in $agents) {
        Assert-FileTarget (Join-Path $agentsDestination $agent.Name)
    }

    # --- Install ---

    $script:WritesStarted = $true

    foreach ($path in @($skillsDestination, $agentsDestination, $frameworkRoot)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }

    foreach ($skill in $skills) {
        Sync-Directory $skill.FullName (Join-Path $skillsDestination $skill.Name)
    }

    foreach ($agent in $agents) {
        Copy-Item -LiteralPath $agent.FullName -Destination (Join-Path $agentsDestination $agent.Name) -Force
    }

    Sync-Directory $templatesSource $templatesDestination

    # Confirm the runtime artifacts really arrived before reporting success.
    foreach ($skill in $skills) {
        Assert-NonEmptyFile (Join-Path (Join-Path $skillsDestination $skill.Name) 'SKILL.md')
    }
    foreach ($agent in $agents) {
        Assert-NonEmptyFile (Join-Path $agentsDestination $agent.Name)
    }
    foreach ($template in $RequiredTemplates) {
        Assert-NonEmptyFile (Join-Path $templatesDestination $template)
    }

    Write-Host 'ai-dev-framework installed.'
    Write-Host ("  skills:    {0} -> {1}" -f $skills.Count, $skillsDestination)
    Write-Host ("  agents:    {0} -> {1}" -f $agents.Count, $agentsDestination)
    Write-Host ("  templates: {0}" -f $templatesDestination)
}
catch {
    $Host.UI.WriteErrorLine("ai-dev-framework installation failed: $($_.Exception.Message)")
    if ($script:WritesStarted) {
        $Host.UI.WriteErrorLine('The installation did not complete and may be partially updated. Fix the problem and run the installer again.')
    }
    else {
        $Host.UI.WriteErrorLine('No changes were made.')
    }
    exit 1
}
