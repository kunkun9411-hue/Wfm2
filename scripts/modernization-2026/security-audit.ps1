[CmdletBinding()]
param(
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$runName = if ($RunId) { $RunId } else { 'gate030-security-' + (Get-Date -Format 'yyyyMMdd-HHmmss') }
$runPath = Join-Path $RunsRoot ($runName -replace '[^A-Za-z0-9._-]', '_')
Ensure-Directory -Path $runPath

$sourceRoots = @(
    (Join-Path $RepoRoot 'Lead-Client-Source'),
    (Join-Path $RepoRoot 'Lead-Server-Source'),
    (Join-Path $RepoRoot 'Lead-Shared-Source')
)
$configFiles = @(Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force | Where-Object {
    $_.Name -in @('CONFIG', 'conf.txt', 'compose.yml', 'compose.mariadb.local.yml', 'setup.py') -and
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\(pack|locale|logs?)\\'
})
$sourceFiles = @(Get-ChildItem -LiteralPath $sourceRoots -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object {
    $_.Extension.ToLowerInvariant() -in @('.c', '.cc', '.cpp', '.h', '.hpp', '.py', '.lua')
})

$categories = [ordered]@{
    secrets = '(?i)(password|passwd|pwd|secret|token|api[_-]?key|private[_-]?key)'
    outboundOrProcess = '(?i)(WinExec|ShellExecute|ShellExecuteEx|CreateProcess|URLDownloadToFile|WinHttp|WinInet|WebView2|inet_addr|https?://)'
    sqlSurface = '(?i)(DirectQuery|ReturnQuery|mysql_query|snprintf|sprintf|EscapeString)'
    authDeleteAdmin = '(?i)(PLAYER_DELETE|DeleteLogonAccount|gmlist|GM_|GetGMLevel|authority|privilege|social_id)'
    inputAndLimits = '(?i)(FN_IS_VALID|rate.?limit|cooldown|MAX_|LIMIT|packet.size|strlen\(|strncpy|strlcpy)'
}

function Get-RedactedLine {
    param([string]$Line, [bool]$SecretBearing)
    if ($SecretBearing) { return '<redacted: secret-bearing configuration or source line>' }
    return (($Line -replace '(?i)(https?://)[^\s"''<>]+', '$1<redacted-endpoint>') -replace '(?i)(147\.46\.127\.42)', '<redacted-ip>')
}

function Find-CategoryMatches {
    param(
        [Parameter(Mandatory)]$Files,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Pattern,
        [int]$MaxMatches = 80
    )

    $records = @()
    foreach ($file in $Files) {
        $lineNumber = 0
        foreach ($line in (Get-Content -LiteralPath $file.FullName -Encoding utf8 -ErrorAction SilentlyContinue)) {
            $lineNumber++
            if ($line -notmatch $Pattern) { continue }
            $secretBearing = ($Category -eq 'secrets')
            $key = if ($secretBearing) {
                (($line -split '[:=]', 2)[0]).Trim()
            } else { $null }
            $records += [pscustomobject]@{
                category = $Category
                path = $file.FullName
                line = $lineNumber
                key = $key
                text = Get-RedactedLine -Line $line -SecretBearing $secretBearing
            }
            if ($records.Count -ge $MaxMatches) { return @($records) }
        }
    }
    return @($records)
}

$findings = @()
foreach ($entry in $categories.GetEnumerator()) {
    $files = if ($entry.Key -eq 'secrets') { $configFiles } else { $sourceFiles }
    foreach ($finding in (Find-CategoryMatches -Files $files -Category $entry.Key -Pattern $entry.Value)) {
        $findings += $finding
    }
}

$configManifest = @($configFiles | Sort-Object FullName | ForEach-Object {
    $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
    [ordered]@{ path = $_.FullName; length = [int64]$_.Length; sha256 = $hash.Hash }
})

$result = [ordered]@{
    schema = 'metin2-modernization-security-audit/v1'
    generatedAt = (Get-Date).ToString('o')
    repository = $RepoRoot
    gitWorkflow = 'not-used'
    executionBoundary = 'Read-only source/config inventory; no server, client, database mutation, pack tool, BAT, CMD or registry operation.'
    configFiles = $configManifest
    categoryCounts = [ordered]@{}
    findings = @($findings)
    openControls = @(
        'Replace checked-in runtime credentials with local secret injection before any public deployment.',
        'Split database roles by process and verify migrations against a disposable restore.',
        'Replace the legacy password protocol and database PASSWORD() path with a versioned password migration.',
        'Add server-authoritative deletion, GM/RBAC, rate-limit and parser tests before enabling new gameplay systems.',
        'Remove or sandbox the unqualified crash-helper process start and keep outbound reporting disabled by default.'
    )
}
foreach ($entry in $categories.GetEnumerator()) {
    $result.categoryCounts[$entry.Key] = @($findings | Where-Object { $_.category -eq $entry.Key }).Count
}

$jsonPath = Join-Path $runPath 'security-audit.json'
Write-JsonUtf8NoBom -Value $result -Path $jsonPath -Depth 15
$result | ConvertTo-Json -Depth 15
exit 0
