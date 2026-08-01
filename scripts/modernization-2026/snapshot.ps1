[CmdletBinding()]
param(
    [ValidateSet('runtime', 'build', 'all')][string]$Scope = 'runtime',
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command ('snapshot-' + $Scope) -RequestedRunId $RunId
$paths = New-Object System.Collections.Generic.List[string]
function Add-ExistingPath([string]$Path) {
    if (-not $paths.Contains($Path)) { [void]$paths.Add($Path) }
}

foreach ($target in Get-KnownRuntimeTargets) { Add-ExistingPath $target.path }
foreach ($path in @(
    (Join-Path $ClientRoot 'metin2client_debug.exe'),
    (Join-Path $ClientRoot 'metin2client.exe'),
    (Join-Path $ClientRoot 'pack\root.eix'),
    (Join-Path $ClientRoot 'pack\root.epk'),
    (Join-Path $ClientRoot 'pack\patch1.eix'),
    (Join-Path $ClientRoot 'pack\patch1.epk'),
    (Join-Path $ClientRoot 'pack\Zone.eix'),
    (Join-Path $ClientRoot 'pack\Zone.epk')
) ) { Add-ExistingPath $path }

if ($Scope -in @('build', 'all')) {
    foreach ($path in @(
        (Join-Path $RepoRoot 'Lead-Server-Source\Lead-Server-Source.sln'),
        (Join-Path $RepoRoot 'Lead-Client-Source\Lead-Client-Source.sln'),
        (Join-Path $RepoRoot 'Lead-Server-Source\db\src\db.vcxproj'),
        (Join-Path $RepoRoot 'Lead-Server-Source\game\src\game.vcxproj'),
        (Join-Path $RepoRoot 'Lead-Client-Source\UserInterface\UserInterface.vcxproj'),
        (Join-Path $RepoRoot 'Lead-Extern\lib\cryptlib-Debug.zip')
    ) ) { Add-ExistingPath $path }
}

$records = @($paths | ForEach-Object { Get-FileRecord -Path $_ })
$packPath = Join-Path $ClientRoot 'pack'
$packCount = [ordered]@{
    eix = @(Get-ChildItem -LiteralPath $packPath -File -Filter '*.eix' -ErrorAction SilentlyContinue).Count
    epk = @(Get-ChildItem -LiteralPath $packPath -File -Filter '*.epk' -ErrorAction SilentlyContinue).Count
}
$snapshotId = 'local-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + $Scope
$result = [ordered]@{
    schema = 'metin2-modernization-snapshot/v1'
    snapshotId = $snapshotId
    generatedAt = (Get-Date).ToString('o')
    workflow = 'git-free; snapshot id plus manifest and SHA-256 are authoritative'
    scope = $Scope
    run = $run
    packCounts = $packCount
    files = $records
    result = if (@($records | Where-Object { -not $_.exists }).Count -eq 0) { 'complete' } else { 'missing-files' }
}
$jsonPath = Join-Path ([string]$run.path) 'snapshot.json'
$manifestPath = Join-Path ([string]$run.path) 'manifest.sha256.csv'
Write-ModernizationJson -Value $result -Path $jsonPath -Depth 14
$records | Select-Object path, exists, length, lastWriteTime, sha256 | Export-Csv -LiteralPath $manifestPath -NoTypeInformation -Encoding UTF8
$md = @(
    "# Local Snapshot $snapshotId",
    '',
    "Generated: $($result.generatedAt)",
    "Scope: $Scope",
    'Workflow: Git-free; no commit or branch identity is used.',
    '',
    '## Pack count',
    "- EIX: $($packCount.eix)",
    "- EPK: $($packCount.epk)",
    '',
    '## Files',
    '| Exists | Size | SHA-256 | Path |',
    '|---|---:|---|---|'
)
foreach ($record in $records) {
    $size = if ($record.exists) { $record.length } else { '-' }
    $hash = if ($record.exists) { $record.sha256 } else { '-' }
    $md += "| $($record.exists) | $size | $hash | $($record.path) |"
}
Write-Utf8NoBom -Path (Join-Path ([string]$run.path) 'snapshot.md') -Content ($md -join [Environment]::NewLine)
$result | ConvertTo-Json -Depth 14
