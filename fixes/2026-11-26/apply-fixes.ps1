#Requires -Version 7
<#
.SYNOPSIS
    Re-apply the 2026-11-26 fixes (full screen, background toggle, Esc) to this tree.

.DESCRIPTION
    Compares, or copies back, the six files snapshotted under fixes/2026-11-26/files.
    -Check  reports every file as MATCH or DIFF and exits 1 when any file differs.
    -Apply  backs each target up next to itself as <name>.bak-<timestamp> and then copies.

.EXAMPLE
    pwsh fixes/2026-11-26/apply-fixes.ps1 -Check
    pwsh fixes/2026-11-26/apply-fixes.ps1 -Apply
#>
[CmdletBinding(DefaultParameterSetName = 'Check')]
param(
    [Parameter(ParameterSetName = 'Check')]
    [switch]$Check,

    [Parameter(ParameterSetName = 'Apply')]
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

$snapshotRoot = Join-Path $PSScriptRoot 'files'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

if (-not (Test-Path -LiteralPath $snapshotRoot)) {
    throw "Snapshot folder is missing: $snapshotRoot"
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$entries = Get-ChildItem -LiteralPath $snapshotRoot -Recurse -File | ForEach-Object {
    [pscustomobject]@{
        Relative = $_.FullName.Substring($snapshotRoot.Length + 1)
        Source   = $_.FullName
        Target   = Join-Path $repoRoot $_.FullName.Substring($snapshotRoot.Length + 1)
    }
}

$differing = 0
foreach ($entry in $entries) {
    if (-not (Test-Path -LiteralPath $entry.Target)) {
        Write-Host ("MISSING  {0}" -f $entry.Relative)
        $differing++
        continue
    }

    $sourceHash = (Get-FileHash -LiteralPath $entry.Source -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $entry.Target -Algorithm SHA256).Hash
    $same = $sourceHash -eq $targetHash
    if ($same) {
        Write-Host ("MATCH    {0}" -f $entry.Relative)
        continue
    }

    $differing++
    Write-Host ("DIFF     {0}" -f $entry.Relative)
    if ($Apply) {
        Copy-Item -LiteralPath $entry.Target -Destination ("{0}.bak-{1}" -f $entry.Target, $stamp)
        Copy-Item -LiteralPath $entry.Source -Destination $entry.Target -Force
        Write-Host ("         restored from snapshot (old copy: {0}.bak-{1})" -f (Split-Path $entry.Target -Leaf), $stamp)
    }
}

$mode = if ($Apply) { 'apply' } else { 'check' }
Write-Host ("{0}: {1} of {2} files differ from the 2026-11-26 snapshot." -f $mode, $differing, $entries.Count)

if ($Check -and $differing -gt 0) {
    Write-Host 'Run with -Apply to restore them, or merge the four changes by hand (see FIXES.md).'
    exit 1
}
exit 0
