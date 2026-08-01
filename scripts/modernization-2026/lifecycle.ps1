[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateSet('Start', 'Stop', 'Status', 'Smoke')][string]$Action,
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command ('lifecycle-' + $Action.ToLowerInvariant()) -RequestedRunId $RunId
$targets = @(Get-KnownRuntimeTargets)

function Get-TargetStatus {
    param([Parameter(Mandatory)]$Target)
    $matches = @(Get-ExactProcessByPath -Path $Target.path)
    [ordered]@{
        name = $Target.name
        path = $Target.path
        running = [bool]$matches
        processes = @($matches | Select-Object Id, ProcessName, StartTime)
        ports = @(Get-LocalPortState -Ports $Target.ports)
    }
}

if ($Action -eq 'Status') {
    $result = [ordered]@{ schema = 'metin2-modernization-lifecycle/v1'; action = 'status'; run = $run; targets = @($targets | ForEach-Object { Get-TargetStatus -Target $_ }) }
    Write-ModernizationJson -Value $result -Path (Join-Path ([string]$run.path) 'lifecycle.json') -Depth 12
    $result | ConvertTo-Json -Depth 12
    return
}

if ($Action -eq 'Start') {
    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target.path -PathType Leaf)) { throw "Runtime-Datei fehlt: $($target.path)" }
        $existing = @(Get-ExactProcessByPath -Path $target.path)
        if ($existing) { Write-Output ("SKIP {0}: bereits aktiv (PID {1})" -f $target.name, (($existing | Select-Object -ExpandProperty Id) -join ', ')); continue }
        $occupied = @(Get-LocalPortState -Ports $target.ports | Where-Object { $_.listening })
        if ($occupied) { throw ("START ABGEBROCHEN: erwarteter Port von {0} ist bereits belegt: {1}" -f $target.name, (($occupied.port) -join ', ')) }
        if ($PSCmdlet.ShouldProcess($target.path, 'Start hidden process in exact working directory')) {
            $process = Start-Process -FilePath $target.path -WorkingDirectory $target.workingDirectory -WindowStyle Hidden -PassThru
            Write-Output ("START {0}: PID {1}" -f $target.name, $process.Id)
        } else {
            Write-Output ("WHATIF {0}: würde mit exaktem Pfad und Arbeitsverzeichnis starten" -f $target.name)
        }
    }
    return
}

if ($Action -eq 'Stop') {
    foreach ($target in $targets) {
        $matches = @(Get-ExactProcessByPath -Path $target.path)
        foreach ($process in $matches) {
            if ($PSCmdlet.ShouldProcess(("{0} PID {1}" -f $target.name, $process.Id), 'Stop exact process path only')) {
                Stop-Process -Id $process.Id -Force
                Write-Output ("STOP {0}: PID {1}" -f $target.name, $process.Id)
            } else {
                Write-Output ("WHATIF {0}: würde PID {1} stoppen" -f $target.name, $process.Id)
            }
        }
    }
    return
}

if ($Action -eq 'Smoke') {
    $status = @($targets | ForEach-Object { Get-TargetStatus -Target $_ })
    $missing = @($status | Where-Object { -not $_.running -or (@($_.ports | Where-Object { -not $_.listening }).Count -gt 0) })
    $result = [ordered]@{ schema = 'metin2-modernization-smoke/v1'; action = 'smoke'; run = $run; targets = $status; passed = ($missing.Count -eq 0) }
    Write-ModernizationJson -Value $result -Path (Join-Path ([string]$run.path) 'smoke.json') -Depth 12
    $result | ConvertTo-Json -Depth 12
    if ($missing.Count -gt 0) { throw 'Loopback-Smoke fehlgeschlagen: mindestens ein erwarteter Prozess oder Port fehlt.' }
    return
}
