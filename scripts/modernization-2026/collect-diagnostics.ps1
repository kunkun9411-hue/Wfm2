[CmdletBinding()]
param(
    [string]$RunId,
    [switch]$IncludeOriginals
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command 'collect-logs' -RequestedRunId $RunId
$runPath = [string]$run.path
$redactedRoot = Join-Path $runPath 'redacted'
$originalRoot = Join-Path $runPath 'originals-local-only'
Ensure-Directory -Path $redactedRoot
if ($IncludeOriginals) { Ensure-Directory -Path $originalRoot }
$artifactRoot = Join-Path $LocalRoot 'build-artifacts'
$candidates = @(Get-ChildItem -LiteralPath $artifactRoot -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.log', '.json', '.csv', '.txt') })
$rules = @(
    '(?im)(password|passwd|secret|token|api[_-]?key|authorization|bearer)\s*[:=]\s*[^\s,;]+' ,
    '(?im)(user(name)?|account|login)\s*[:=]\s*[^\s,;]+'
)
$runtimeStatus = foreach ($target in Get-KnownRuntimeTargets) {
    $matches = @(Get-ExactProcessByPath -Path $target.path)
    [ordered]@{
        name = $target.name
        path = $target.path
        running = [bool]$matches
        processes = @($matches | Select-Object Id, ProcessName, StartTime)
        ports = @(Get-LocalPortState -Ports $target.ports)
    }
}
$files = foreach ($item in $candidates) {
    $relative = $item.Name
    $redactedPath = Join-Path $redactedRoot $relative
    $content = Get-Content -LiteralPath $item.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { $content = '' }
    foreach ($rule in $rules) { $content = [regex]::Replace($content, $rule, '$1=<REDACTED>') }
    Write-Utf8NoBom -Path $redactedPath -Content $content
    if ($IncludeOriginals) { Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $originalRoot $relative) -Force }
    [ordered]@{
        source = $item.FullName
        redacted = $redactedPath
        originalIncluded = $IncludeOriginals.IsPresent
        length = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
    }
}
$result = [ordered]@{
    schema = 'metin2-modernization-diagnostics/v1'
    generatedAt = (Get-Date).ToString('o')
    run = $run
    originalPolicy = if ($IncludeOriginals) { 'local-only; do not share without a second review' } else { 'not copied' }
    redactionRules = $rules
    runtimeStatus = @($runtimeStatus)
    mariaDbPort = @(Get-LocalPortState -Ports @(3306))
    files = @($files)
    sourceOfTruth = 'redacted copies are for handoff; source paths and hashes are metadata only'
}
Write-ModernizationJson -Value $result -Path (Join-Path $runPath 'run.json') -Depth 14
$result | ConvertTo-Json -Depth 14
