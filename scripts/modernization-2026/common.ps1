[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$WorkspaceRoot = (Resolve-Path (Join-Path $RepoRoot '..')).Path
$LocalRoot = Join-Path $WorkspaceRoot '_local'
$ModernizationRoot = Join-Path $LocalRoot 'modernization-2026'
$RunsRoot = Join-Path $ModernizationRoot 'runs'
$ServerRoot = Join-Path $RepoRoot 'Lead-Serverfiles'
$ClientRoot = Join-Path $RepoRoot 'Lead-Client'

. (Join-Path $RepoRoot 'scripts\windows-local\common.ps1')

function New-ModernizationRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Command,
        [string]$RequestedRunId
    )

    Ensure-Directory -Path $RunsRoot
    $safeId = if ($RequestedRunId) { $RequestedRunId -replace '[^A-Za-z0-9._-]', '_' } else { Get-Date -Format 'yyyyMMdd-HHmmss-fff' }
    $runPath = Join-Path $RunsRoot $safeId
    Ensure-Directory -Path $runPath
    [ordered]@{
        id = $safeId
        command = $Command
        startedAt = (Get-Date).ToString('o')
        path = $runPath
    }
}

function Write-ModernizationJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Value,
        [Parameter(Mandatory)][string]$Path,
        [int]$Depth = 12
    )

    Write-JsonUtf8NoBom -Value $Value -Path $Path -Depth $Depth
}

function Get-LocalPortState {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int[]]$Ports)

    foreach ($port in $Ports | Sort-Object -Unique) {
        $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
        [ordered]@{
            port = $port
            listening = [bool]$listeners
            listeners = @($listeners | Select-Object LocalAddress, LocalPort, OwningProcess)
        }
    }
}

function Get-ExactProcessByPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -eq $Path } catch { $false }
    })
}

function Get-FileRecord {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [ordered]@{ path = $Path; exists = $false }
    }

    $item = Get-Item -LiteralPath $Path
    $hash = Get-FileHash -LiteralPath $Path -Algorithm SHA256
    [ordered]@{
        path = $Path
        exists = $true
        length = [int64]$item.Length
        lastWriteTime = $item.LastWriteTime.ToString('o')
        sha256 = $hash.Hash
    }
}

function Get-KnownRuntimeTargets {
    @(
        [ordered]@{ name = 'db'; path = (Join-Path $ServerRoot 'db\db_d.exe'); workingDirectory = (Join-Path $ServerRoot 'db'); ports = @(15000) },
        [ordered]@{ name = 'auth'; path = (Join-Path $ServerRoot 'auth\game_d.exe'); workingDirectory = (Join-Path $ServerRoot 'auth'); ports = @(11000, 12000) },
        [ordered]@{ name = 'game1'; path = (Join-Path $ServerRoot 'channel1\game1\game_d.exe'); workingDirectory = (Join-Path $ServerRoot 'channel1\game1'); ports = @(13001, 14001) }
    )
}
