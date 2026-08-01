[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0)][ValidateSet('help', 'doctor', 'db-up', 'db-backup', 'build-server', 'build-client', 'start', 'status', 'stop', 'smoke', 'collect-logs', 'snapshot', 'analyze', 'dependencies', 'security-audit')][string]$Command = 'help',
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug',
    [ValidateSet('Build', 'Rebuild', 'Clean')][string]$Target = 'Build',
    [ValidateSet('runtime', 'build', 'all')][string]$Scope = 'runtime',
    [string]$RunId,
    [switch]$IncludeOriginals
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$localRoot = (Resolve-Path (Join-Path $scriptRoot '..\..\..\_local')).Path
$composeFile = Join-Path $localRoot 'compose.mariadb.local.yml'

function Invoke-ModernizationScript {
    param(
        [Parameter(Mandatory)][string]$ScriptName,
        [string[]]$Arguments = @(),
        [switch]$SupportsWhatIf
    )
    $scriptPath = Join-Path $scriptRoot $ScriptName
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) { throw "Modernization-Skript fehlt: $scriptPath" }
    $powershell = Join-Path $PSHOME 'powershell.exe'
    $effectiveArguments = @()
    for ($index = 0; $index -lt @($Arguments).Count; $index++) {
        $argument = $Arguments[$index]
        if ($null -eq $argument) { continue }
        if ([string]$argument -eq '-RunId' -and (($index + 1) -ge @($Arguments).Count -or [string]::IsNullOrWhiteSpace([string]$Arguments[$index + 1]))) {
            continue
        }
        $effectiveArguments += $argument
    }
    $childArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath) + $effectiveArguments
    if ($SupportsWhatIf -and $WhatIfPreference) { $childArgs += '-WhatIf' }
    if ($VerbosePreference -eq 'Continue') { $childArgs += '-Verbose' }
    & $powershell @childArgs
    if ($LASTEXITCODE -ne 0) { throw ("Kommando '{0}' fehlgeschlagen; Exitcode {1}." -f $ScriptName, $LASTEXITCODE) }
}

if ($Command -eq 'help') {
    @'
Metin2 Modernization 2026 - Git-freier Einstieg

Lesend / sicher:
  .\scripts\modernization-2026\m2.ps1 doctor
  .\scripts\modernization-2026\m2.ps1 status
  .\scripts\modernization-2026\m2.ps1 smoke
  .\scripts\modernization-2026\m2.ps1 snapshot -Scope runtime
  .\scripts\modernization-2026\m2.ps1 collect-logs
  .\scripts\modernization-2026\m2.ps1 analyze
  .\scripts\modernization-2026\m2.ps1 dependencies
  .\scripts\modernization-2026\m2.ps1 security-audit

Mit explizitem Effekt:
  .\scripts\modernization-2026\m2.ps1 db-up
  .\scripts\modernization-2026\m2.ps1 build-server -Configuration Debug
  .\scripts\modernization-2026\m2.ps1 build-client -Configuration Debug
  .\scripts\modernization-2026\m2.ps1 start
  .\scripts\modernization-2026\m2.ps1 stop

Plan prüfen: an jedes Kommando -WhatIf anhängen. Git, Downloads, Router- oder
Firewall-Änderungen werden von diesem Einstieg nicht ausgeführt.
'@
    return
}

switch ($Command) {
    'doctor' { Invoke-ModernizationScript -ScriptName 'doctor.ps1' -Arguments @('-RunId', $RunId); break }
    'status' { Invoke-ModernizationScript -ScriptName 'status.ps1' -Arguments @('-RunId', $RunId); break }
    'smoke' { Invoke-ModernizationScript -ScriptName 'lifecycle.ps1' -Arguments @('-Action', 'Smoke', '-RunId', $RunId) -SupportsWhatIf; break }
    'start' { Invoke-ModernizationScript -ScriptName 'lifecycle.ps1' -Arguments @('-Action', 'Start', '-RunId', $RunId) -SupportsWhatIf; break }
    'stop' { Invoke-ModernizationScript -ScriptName 'lifecycle.ps1' -Arguments @('-Action', 'Stop', '-RunId', $RunId) -SupportsWhatIf; break }
    'snapshot' { Invoke-ModernizationScript -ScriptName 'snapshot.ps1' -Arguments @('-Scope', $Scope, '-RunId', $RunId); break }
    'collect-logs' {
        $args = @('-RunId', $RunId)
        if ($IncludeOriginals) { $args += '-IncludeOriginals' }
        Invoke-ModernizationScript -ScriptName 'collect-diagnostics.ps1' -Arguments $args
        break
    }
    'analyze' { Invoke-ModernizationScript -ScriptName 'run-static-analysis.ps1' -Arguments @('-RunId', $RunId); break }
    'dependencies' { Invoke-ModernizationScript -ScriptName 'dependencies.ps1' -Arguments @('-RunId', $RunId); break }
    'security-audit' { Invoke-ModernizationScript -ScriptName 'security-audit.ps1' -Arguments @('-RunId', $RunId); break }
    'build-server' { Invoke-ModernizationScript -ScriptName 'build.ps1' -Arguments @('-TargetName', 'server', '-Configuration', $Configuration, '-Target', $Target, '-RunId', $RunId) -SupportsWhatIf; break }
    'build-client' { Invoke-ModernizationScript -ScriptName 'build.ps1' -Arguments @('-TargetName', 'client', '-Configuration', $Configuration, '-Target', $Target, '-RunId', $RunId) -SupportsWhatIf; break }
    'db-up' {
        if (-not (Test-Path -LiteralPath $composeFile -PathType Leaf)) { throw "Compose-Datei fehlt: $composeFile" }
        $docker = Get-Command docker -ErrorAction SilentlyContinue
        if (-not $docker) { throw 'docker ist nicht installiert oder nicht im PATH.' }
        if ($PSCmdlet.ShouldProcess($composeFile, 'Start local MariaDB compose service')) {
            & $docker.Source compose -f $composeFile up -d
            if ($LASTEXITCODE -ne 0) { throw "docker compose up fehlgeschlagen; Exitcode $LASTEXITCODE." }
        } else { Write-Output "WHATIF: würde nur die lokale Compose-Datei starten: $composeFile" }
        break
    }
    'db-backup' { throw 'db-backup bleibt bis zur dokumentierten Backup-/Restore-Prüfung gesperrt; kein unklarer Dump wird erzeugt.' }
    default { throw "Nicht unterstütztes Kommando: $Command" }
}
