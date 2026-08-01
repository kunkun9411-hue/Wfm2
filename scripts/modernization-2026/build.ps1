[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateSet('server', 'client')][string]$TargetName,
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug',
    [ValidateSet('Build', 'Rebuild', 'Clean')][string]$Target = 'Build',
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command ("build-{0}-{1}-{2}" -f $TargetName, $Configuration, $Target.ToLowerInvariant()) -RequestedRunId $RunId
$solution = if ($TargetName -eq 'server') { Join-Path $RepoRoot 'Lead-Server-Source\Lead-Server-Source.sln' } else { Join-Path $RepoRoot 'Lead-Client-Source\Lead-Client-Source.sln' }
$msbuild = Get-MsBuildPath
if (-not $msbuild) { throw 'MSBuild konnte nicht gefunden werden. Doctor muss zuerst eine gültige VS-x64-Toolchain melden.' }
if (-not (Test-Path -LiteralPath $solution -PathType Leaf)) { throw "Solution fehlt: $solution" }
$solutionText = Get-Content -LiteralPath $solution -Raw
$requestedConfiguration = "{0}|x64" -f $Configuration
if ($solutionText -notmatch [regex]::Escape($requestedConfiguration)) {
    throw ("Konfiguration {0} ist in {1} nicht vorhanden. Verfügbare Solution-Konfigurationen zuerst prüfen; kein zufälliger Linkerfehler wird gestartet." -f $requestedConfiguration, $solution)
}
$logPath = Join-Path ([string]$run.path) 'build-console.log'
$msbuildLogPath = Join-Path ([string]$run.path) 'build-msbuild.log'
$binlogPath = Join-Path ([string]$run.path) 'build.binlog'
$outputPaths = if ($TargetName -eq 'server') {
    @(
        (Join-Path $ServerRoot 'db\db_d.exe'),
        (Join-Path $ServerRoot 'auth\game_d.exe'),
        (Join-Path $ServerRoot 'channel1\game1\game_d.exe'),
        (Join-Path $ServerRoot 'channel1\game2\game_d.exe'),
        (Join-Path $ServerRoot 'channel99\game_d.exe')
    )
} else { @(Join-Path $ClientRoot $(if ($Configuration -eq 'Debug') { 'metin2client_debug.exe' } else { 'metin2client.exe' })) }

$arguments = @(
    $solution,
    "/t:$Target",
    "/p:Configuration=$Configuration",
    '/p:Platform=x64',
    '/m',
    '/nologo',
    '/v:minimal',
    "/bl:$binlogPath",
    "/flp1:LogFile=$msbuildLogPath;Verbosity=normal;Encoding=UTF-8"
)
$started = Get-Date
$exitCode = 0
$executed = $false
if ($PSCmdlet.ShouldProcess($solution, ("MSBuild $TargetName $Configuration $Target"))) {
    $executed = $true
    & $msbuild @arguments 2>&1 | Tee-Object -LiteralPath $logPath
    $exitCode = $LASTEXITCODE
} else {
    Write-Output ("WHATIF: würde {0} mit {1}" -f $solution, ($arguments -join ' '))
}
$completed = Get-Date
$artifacts = if ($WhatIfPreference) {
    @($outputPaths | ForEach-Object { [ordered]@{ path = $_; planned = $true } })
} else {
    @($outputPaths | ForEach-Object { Get-FileRecord -Path $_ })
}
$manifest = [ordered]@{
    schema = 'metin2-modernization-build/v1'
    generatedAt = $completed.ToString('o')
    run = $run
    target = $TargetName
    configuration = $Configuration
    msbuild = $msbuild
    toolset = 'MSVC v145 / x64'
    platform = 'x64'
    targetAction = $Target
    executed = $executed
    exitCode = $exitCode
    sourceIdentity = 'git-free; see linked snapshot id and manifests instead of commit SHA'
    solution = $solution
    durationSeconds = [math]::Round(($completed - $started).TotalSeconds, 2)
    log = $logPath
    msbuildLog = $msbuildLogPath
    binlog = $binlogPath
    artifacts = $artifacts
}
if ($WhatIfPreference) {
    $manifest | ConvertTo-Json -Depth 14
    return
}
Write-ModernizationJson -Value $manifest -Path (Join-Path ([string]$run.path) 'build-manifest.json') -Depth 14
if ($executed -and $exitCode -ne 0) { throw "MSBuild fehlgeschlagen; Log: $logPath" }
$manifest | ConvertTo-Json -Depth 14
