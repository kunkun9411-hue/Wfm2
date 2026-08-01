[CmdletBinding()]
param(
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command 'analyze' -RequestedRunId $RunId
$artifactRoot = Join-Path $LocalRoot 'build-artifacts'
$logs = @(
    @(Get-ChildItem -LiteralPath $artifactRoot -File -Filter '*build*.log' -ErrorAction SilentlyContinue)
    @(Get-ChildItem -LiteralPath $RunsRoot -Recurse -File -Filter '*build*.log' -ErrorAction SilentlyContinue)
)
$warningRecords = foreach ($log in $logs) {
    $lines = @(Select-String -LiteralPath $log.FullName -Pattern 'warning\s+[A-Z0-9]+|warning [A-Z0-9]+' -AllMatches -ErrorAction SilentlyContinue)
    foreach ($line in $lines) {
        [ordered]@{ source = $log.FullName; line = $line.LineNumber; text = $line.Line.Trim() }
    }
}
$categories = [ordered]@{
    narrowing = @($warningRecords | Where-Object { $_.text -match 'C4244|narrow|Konvertierung' }).Count
    linkerPdb = @($warningRecords | Where-Object { $_.text -match 'LNK4099|PDB' }).Count
    other = @($warningRecords | Where-Object { $_.text -notmatch 'C4244|narrow|Konvertierung|LNK4099|PDB' }).Count
}
$clang = Get-Command clang-tidy -ErrorAction SilentlyContinue
$result = [ordered]@{
    schema = 'metin2-modernization-static-analysis/v1'
    generatedAt = (Get-Date).ToString('o')
    run = $run
    mode = 'baseline inventory only; no source modifications and no mass fixes'
    analyzers = [ordered]@{
        msvc = 'warning extraction from existing MSBuild logs'
        clangTidy = [ordered]@{ available = [bool]$clang; path = if ($clang) { $clang.Source } else { $null }; executed = $false }
    }
    policy = 'new warnings in changed files block future gates; current legacy warnings are not suppressed'
    warningTotals = [ordered]@{ total = @($warningRecords).Count; categories = $categories }
    warnings = @($warningRecords)
}
Write-ModernizationJson -Value $result -Path (Join-Path ([string]$run.path) 'analysis.json') -Depth 14
$result | ConvertTo-Json -Depth 14
