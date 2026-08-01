[CmdletBinding()]
param(
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command 'doctor' -RequestedRunId $RunId
$runPath = [string]$run.path
$requiredPaths = @(
    $RepoRoot,
    (Join-Path $RepoRoot 'Lead-Server-Source\Lead-Server-Source.sln'),
    (Join-Path $RepoRoot 'Lead-Client-Source\Lead-Client-Source.sln'),
    (Join-Path $ServerRoot 'db\db_d.exe'),
    (Join-Path $ServerRoot 'auth\game_d.exe'),
    (Join-Path $ServerRoot 'channel1\game1\game_d.exe'),
    (Join-Path $ClientRoot 'metin2client_debug.exe'),
    (Join-Path $LocalRoot 'compose.mariadb.local.yml')
)

$pathChecks = foreach ($path in $requiredPaths) {
    [ordered]@{ path = $path; exists = (Test-Path -LiteralPath $path) }
}
$msbuild = Get-MsBuildPath
$toolChecks = foreach ($name in @('docker', 'python', 'cmake')) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if (-not $command -and $name -eq 'cmake' -and $msbuild) {
        $vsRoot = (Resolve-Path (Join-Path (Split-Path $msbuild -Parent) '..\..\..')).Path
        $vsCmake = Join-Path $vsRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
        if (Test-Path -LiteralPath $vsCmake -PathType Leaf) { $command = [pscustomobject]@{ Source = $vsCmake } }
    }
    [ordered]@{ name = $name; available = [bool]$command; path = if ($command) { $command.Source } else { $null } }
}
$dumpbin = Get-DumpbinPath
$os = Get-CimInstance Win32_OperatingSystem
$ports = @(3306, 11000, 12000, 13001, 14001, 15000)
$missingPaths = @($pathChecks | Where-Object { -not $_.exists } | ForEach-Object { $_.path })
$missingTools = @($toolChecks | Where-Object { -not $_.available } | ForEach-Object { $_.name })

$result = [ordered]@{
    schema = 'metin2-modernization-doctor/v1'
    generatedAt = (Get-Date).ToString('o')
    run = $run
    workflow = [ordered]@{
        mode = 'git-free'
        sourceOfTruth = 'local snapshot id, file manifest, SHA-256, runtime logs'
        gitConsulted = $false
        downloadsPerformed = $false
        repositoryExecutablesRun = $false
    }
    repository = [ordered]@{ path = $RepoRoot; workspace = $WorkspaceRoot }
    operatingSystem = [ordered]@{
        caption = $os.Caption
        version = $os.Version
        build = $os.BuildNumber
        architecture = $os.OSArchitecture
        processArchitecture = $env:PROCESSOR_ARCHITECTURE
    }
    toolchain = [ordered]@{
        msbuild = $msbuild
        dumpbin = $dumpbin
        tools = $toolChecks
    }
    paths = $pathChecks
    ports = @(Get-LocalPortState -Ports $ports)
    missing = [ordered]@{ paths = $missingPaths; tools = $missingTools }
    result = if ($missingPaths.Count -eq 0) { 'baseline-paths-present' } else { 'attention-required' }
    completedAt = (Get-Date).ToString('o')
}

Write-ModernizationJson -Value $result -Path (Join-Path $runPath 'doctor.json') -Depth 14
Write-ModernizationJson -Value $result -Path (Join-Path $ModernizationRoot 'doctor-latest.json') -Depth 14
$result | ConvertTo-Json -Depth 14
