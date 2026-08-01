[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
$ps = Join-Path $PSHOME 'powershell.exe'
$entrypoint = Join-Path $scriptRoot 'm2.ps1'
$results = New-Object System.Collections.ArrayList

function Invoke-EntryTest {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string[]]$Arguments = @(),
        [Parameter(Mandatory)][bool]$ExpectedSuccess
    )
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $ps -NoProfile -ExecutionPolicy Bypass -File $entrypoint @Arguments *> $null
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    $success = ($exitCode -eq 0)
    [void]$results.Add([pscustomobject]@{ name = $Name; expectedSuccess = $ExpectedSuccess; actualSuccess = $success; exitCode = $exitCode })
}

$parseFailures = @(foreach ($file in Get-ChildItem -LiteralPath $scriptRoot -Filter '*.ps1' -File) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) { $file.Name }
})
[void]$results.Add([pscustomobject]@{ name = 'PowerShell parse'; expectedSuccess = $true; actualSuccess = ($parseFailures.Count -eq 0); exitCode = if ($parseFailures.Count -eq 0) { 0 } else { 1 }; details = @($parseFailures) })
Invoke-EntryTest -Name 'help' -Arguments @('help') -ExpectedSuccess $true
Invoke-EntryTest -Name 'status' -Arguments @('status', '-RunId', 'command-surface-status') -ExpectedSuccess $true
Invoke-EntryTest -Name 'start-whatif' -Arguments @('start', '-WhatIf', '-RunId', 'command-surface-start-plan') -ExpectedSuccess $true
Invoke-EntryTest -Name 'locked-db-backup' -Arguments @('db-backup') -ExpectedSuccess $false
Invoke-EntryTest -Name 'invalid-command' -Arguments @('not-a-command') -ExpectedSuccess $false

$failures = @($results | Where-Object { $_.expectedSuccess -ne $_.actualSuccess })
$result = [ordered]@{
    schema = 'metin2-modernization-command-tests/v1'
    generatedAt = (Get-Date).ToString('o')
    entrypoint = $entrypoint
    workflow = 'Git-free; test runner uses only PowerShell process invocation'
    results = @($results)
    passed = ($failures.Count -eq 0)
}
$outputRoot = Join-Path (Join-Path (Resolve-Path (Join-Path $repoRoot '..')).Path '_local') 'modernization-2026\runs\command-surface-tests'
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $outputRoot 'tests.json') -Encoding UTF8
$result | ConvertTo-Json -Depth 12
if ($failures.Count -gt 0) { exit 1 }
