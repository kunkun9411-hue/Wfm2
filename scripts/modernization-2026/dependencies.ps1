[CmdletBinding()]
param(
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command 'dependencies' -RequestedRunId $RunId
$artifactRoot = Join-Path $LocalRoot 'build-artifacts'
$hashPath = Join-Path $artifactRoot 'binary-sha256.csv'
$signaturePath = Join-Path $artifactRoot 'binary-signatures.csv'
$runtimeReport = Join-Path $artifactRoot 'runtime-dependents.txt'
if (-not (Test-Path -LiteralPath $hashPath -PathType Leaf)) { throw "Fehlt: $hashPath" }
$hashes = @(Import-Csv -LiteralPath $hashPath)
$signatures = @{}
if (Test-Path -LiteralPath $signaturePath -PathType Leaf) {
    foreach ($row in Import-Csv -LiteralPath $signaturePath) { $signatures[$row.FullName] = $row }
}
$inventoryPaths = New-Object System.Collections.Generic.List[string]
foreach ($row in $hashes) { if (-not $inventoryPaths.Contains($row.FullName)) { [void]$inventoryPaths.Add($row.FullName) } }
$runtimeDirectories = @(
    $ClientRoot,
    (Join-Path $ServerRoot 'db'),
    (Join-Path $ServerRoot 'auth'),
    (Join-Path $ServerRoot 'channel1\game1'),
    (Join-Path $ServerRoot 'channel1\game2'),
    (Join-Path $ServerRoot 'channel99'),
    (Join-Path $ServerRoot 'markserver'),
    (Join-Path $RepoRoot 'Lead-Extern\dll')
)
foreach ($root in $runtimeDirectories) {
    if (Test-Path -LiteralPath $root -PathType Container) {
        foreach ($item in Get-ChildItem -LiteralPath $root -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.dll', '.exe') }) {
            if (-not $inventoryPaths.Contains($item.FullName)) { [void]$inventoryPaths.Add($item.FullName) }
        }
    }
}
$records = @($inventoryPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | ForEach-Object { Get-FileRecord -Path $_ })
$components = foreach ($record in $records) {
    $name = Split-Path -Leaf $record.path
    $signature = if ($signatures.ContainsKey($record.path)) { $signatures[$record.path].Status } else { 'unknown' }
    [ordered]@{
        type = 'file'
        name = $name
        version = 'unknown'
        hashes = @([ordered]@{ alg = 'SHA-256'; content = $record.sha256 })
        scope = if ($record.path -match '\\Lead-Client\\|\\Lead-Serverfiles\\') { 'runtime' } else { 'build-tool-or-dependency' }
        author = 'unknown'
        licenses = @([ordered]@{ license = [ordered]@{ id = 'NOASSERTION'; name = 'not assessed' } })
        properties = @(
            [ordered]@{ name = 'metin2:path'; value = $record.path },
            [ordered]@{ name = 'metin2:signature-status'; value = $signature },
            [ordered]@{ name = 'metin2:architecture'; value = 'verify per PE header; not inferred from filename' },
            [ordered]@{ name = 'metin2:crt-model'; value = 'unknown unless build/runtime evidence says otherwise' }
        )
    }
}
$sbom = [ordered]@{
    bomFormat = 'CycloneDX'
    specVersion = '1.5'
    serialNumber = ('urn:uuid:' + [guid]::NewGuid().Guid)
    version = 1
    metadata = [ordered]@{ timestamp = (Get-Date).ToString('o'); tools = @([ordered]@{ vendor = 'Metin2 Modernization 2026'; name = 'dependencies.ps1'; version = '1' }) }
    components = @($components)
}
$sbomPath = Join-Path ([string]$run.path) 'bom.cdx.json'
Write-ModernizationJson -Value $sbom -Path $sbomPath -Depth 20
$snapshotManifests = @(Get-ChildItem -LiteralPath $RunsRoot -Recurse -File -Filter 'snapshot.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3)
$buildManifests = @(Get-ChildItem -LiteralPath $RunsRoot -Recurse -File -Filter 'build-manifest.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 10)
$provenance = [ordered]@{
    schema = 'metin2-modernization-provenance/v1'
    generatedAt = (Get-Date).ToString('o')
    workflow = 'git-free; snapshot and SHA-256 identities replace commit identity'
    snapshotManifests = @($snapshotManifests | ForEach-Object { [ordered]@{ path = $_.FullName; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } })
    buildManifests = @($buildManifests | ForEach-Object { [ordered]@{ path = $_.FullName; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash } })
    sbom = [ordered]@{ path = $sbomPath; sha256 = (Get-FileHash -LiteralPath $sbomPath -Algorithm SHA256).Hash }
    dependencyInventory = [ordered]@{ source = $hashPath; sourceSha256 = (Get-FileHash -LiteralPath $hashPath -Algorithm SHA256).Hash; currentRuntimeInventoryCount = @($records).Count }
}
$provenancePath = Join-Path ([string]$run.path) 'build-provenance.json'
Write-ModernizationJson -Value $provenance -Path $provenancePath -Depth 16
$lines = @(
    '# Dependencies and Build Provenance',
    '',
    "Generated: $((Get-Date).ToString('o'))",
    'Workflow: Git-free. A snapshot ID and SHA-256 manifest replace commit identity.',
    '',
    '## Assessment rules',
    '- Runtime and build files are separated by path scope.',
    '- Version, license, architecture and CRT are `unknown` unless evidence exists.',
    '- Unsigned third-party files are not silently treated as trusted.',
    '- Proprietary binaries and license files are not embedded here.',
    '',
    '## Inventory',
    '| File | Scope | SHA-256 | Signature | Version | License |',
    '|---|---|---|---|---|---|'
)
foreach ($component in $components) {
    $path = ($component.properties | Where-Object { $_.name -eq 'metin2:path' }).value
    $signature = ($component.properties | Where-Object { $_.name -eq 'metin2:signature-status' }).value
    $lines += "| $($component.name) | $($component.scope) | $($component.hashes[0].content) | $signature | unknown | NOASSERTION |"
}
$lines += @('', '## Runtime dependency report', "Source: $runtimeReport", '- Static loader output is retained locally; unresolved entries remain open.', '', "Machine-readable SBOM: $sbomPath", "Build provenance: $provenancePath")
$mdPath = Join-Path $RepoRoot 'docs\modernization-2026\DEPENDENCIES.md'
Write-Utf8NoBom -Path $mdPath -Content ($lines -join [Environment]::NewLine)
$result = [ordered]@{ schema = 'metin2-modernization-dependencies/v1'; generatedAt = (Get-Date).ToString('o'); run = $run; componentCount = @($components).Count; sbom = $sbomPath; provenance = $provenancePath; markdown = $mdPath; staticRuntimeReport = $runtimeReport; inventorySources = @($hashPath, 'current .dll/.exe files below Lead-Client, Lead-Serverfiles and Lead-Extern/dll'); unknowns = @('version', 'license', 'architecture per component', 'CRT per runtime-loaded file', 'full transitive source license graph') }
Write-ModernizationJson -Value $result -Path (Join-Path ([string]$run.path) 'dependencies.json') -Depth 14
$result | ConvertTo-Json -Depth 14
