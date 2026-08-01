[CmdletBinding()]
param(
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$run = New-ModernizationRun -Command 'status' -RequestedRunId $RunId
$targets = @(Get-KnownRuntimeTargets)
$processes = foreach ($target in $targets) {
    $matches = @(Get-ExactProcessByPath -Path $target.path)
    [ordered]@{
        name = $target.name
        path = $target.path
        workingDirectory = $target.workingDirectory
        running = [bool]$matches
        processes = @($matches | Select-Object Id, ProcessName, StartTime)
        expectedPorts = $target.ports
    }
}
$result = [ordered]@{
    schema = 'metin2-modernization-status/v1'
    generatedAt = (Get-Date).ToString('o')
    run = $run
    processes = $processes
    ports = @(Get-LocalPortState -Ports @(3306, 11000, 12000, 13001, 14001, 15000))
    docker = [ordered]@{ commandAvailable = [bool](Get-Command docker -ErrorAction SilentlyContinue); containerState = 'not-queried' }
    note = 'Status ist lesend; MariaDB wird nicht durch dieses Kommando neu gestartet.'
}
Write-ModernizationJson -Value $result -Path (Join-Path ([string]$run.path) 'status.json') -Depth 12
$result | ConvertTo-Json -Depth 12
