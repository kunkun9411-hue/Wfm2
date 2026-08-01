# Lokales CI-Runbook ohne Git

Dieses Projekt nutzt für die Modernisierung keinen Git-Checkout als
Nachweisquelle. Ein sauberer Foundation-Lauf startet aus dem lokalen Workspace
und wird über Snapshot-ID, SHA-256-Manifest, Toolchain und Logs identifiziert.

## Runner-Voraussetzungen

- Windows x64
- Visual Studio v145 mit x64-Tools und passendem Windows SDK
- PowerShell 5.1 oder neuer
- Docker Desktop nur für die lokale MariaDB
- keine Downloads während des Laufs

## Pipeline-Reihenfolge

```powershell
Set-Location C:\Dev\M2Lead\lead-files-community
$ps = Join-Path $PSHOME 'powershell.exe'
$m2 = '.\scripts\modernization-2026\m2.ps1'
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 doctor
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 snapshot -Scope all
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 build-server -Configuration Debug
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 build-client -Configuration Debug
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 build-client -Configuration Release
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 analyze
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 dependencies
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 status
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 smoke
& $ps -NoProfile -ExecutionPolicy Bypass -File $m2 collect-logs
```

Jeder Schritt muss auf einen nicht-null Exitcode reagieren. Der Server besitzt
aktuell nur `Debug|x64`; ein angeforderter Server-Release-Lauf wird deshalb im
Preflight abgelehnt. Proprietäre oder unbekannte Binärdateien werden nicht in
öffentliche Artefakte kopiert.

## Nachweise

Run-Artefakte liegen unter
`C:\Dev\M2Lead\_local\modernization-2026\runs\<run-id>`. Ein Lauf gilt erst
als Foundation-Nachweis, wenn sein Manifest, die beiden Buildlogs, Binärhashes,
Analysebericht und SBOM gemeinsam abgelegt sind.
