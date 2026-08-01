# Gate 020 · Engineering Foundation

Stand: 2026-08-01 21:06 Europe/Berlin  
Arbeitsmodus: Git-freier Windows-Workspace; keine Commit-, Branch- oder Tag-Nachweise.

## Ergebnis

Gate 020 ist als Foundation-Nachweis dokumentiert. Der Workspace hat jetzt
einen zentralen PowerShell-Einstieg, lokale Snapshot-/SHA-256-Nachweise,
reproduzierbare Buildmanifeste, redigierte Diagnosepakete, eine Analysebaseline
und eine maschinenlesbare CycloneDX-SBOM. Es wurden keine Packs, MSM-Dateien,
DB-Daten oder UI-Quellen umgebaut.

## Verifizierte Läufe

- `m2.ps1 doctor`, `status` und `smoke`: Exitcode 0; MariaDB bleibt auf
  `127.0.0.1:3306`, Auth auf `11000/12000`, Game1 auf `13001/14001`, DB intern
  auf `15000`.
- Command-Surface-Test: bestanden; Parser, Hilfe, Status, `-WhatIf` sowie
  erwartete Nicht-null-Fehler für gesperrtes `db-backup` und unbekanntes
  Kommando sind abgedeckt.
- Server Debug: zwei Wrapperläufe erfolgreich. Der erste Lauf erforderte den
  kontrollierten Stop/Start der drei bekannten Serverprozesse, weil `game1`
  die EXE gesperrt hatte. Der zweite Lauf war inkrementell erfolgreich; die
  Auth-Kopie blieb bei laufendem Prozess unverändert und der Post-Build-Hinweis
  ist im Log sichtbar.
- Client Debug: zwei Wrapperläufe erfolgreich.
- Client Release: einmal erfolgreich, 51,51 Sekunden; `metin2client.exe`
  erzeugt. Server Release wird vor MSBuild abgelehnt, weil die Solution nur
  `Debug|x64` anbietet.
- Statische Warnungsbaseline: 630 Treffer aus den vorhandenen Buildlogs,
  davon 6 Narrowing-Warnungen und 624 `LNK4099`-PDB-Hinweise. Es wurden keine
  Suppressions oder Massenfixes gesetzt.

## Primäre Artefakte

- Einstieg: `C:\Dev\M2Lead\lead-files-community\scripts\modernization-2026\m2.ps1`
- Tests: `C:\Dev\M2Lead\_local\modernization-2026\runs\command-surface-tests\tests.json`
- Snapshot: `C:\Dev\M2Lead\_local\modernization-2026\runs\gate020-final-snapshot2\snapshot.json`
- Analyse: `C:\Dev\M2Lead\_local\modernization-2026\runs\gate020-final-analyze\analysis.json`
- SBOM/Provenance: `C:\Dev\M2Lead\_local\modernization-2026\runs\gate020-final-dependencies2\bom.cdx.json` und `build-provenance.json`
- Diagnose: `C:\Dev\M2Lead\_local\modernization-2026\runs\gate020-final-collect\run.json`
- Abhängigkeitsübersicht: `C:\Dev\M2Lead\lead-files-community\docs\modernization-2026\DEPENDENCIES.md`

## Bewusst offen

- 014–019 bleiben in der Statusmatrix `IN_PROGRESS`: Die Vollorchestrierung
  `prepare -> build -> db -> stage -> start -> smoke -> stop -> collect`, ein
  echter Snapshot-Diff für geänderte Dateien, ein öffentlicher/selbstgehosteter
  CI-Runner und eine vollständige Release-Konfiguration für den Server sind
  noch nicht abgenommen.
- `db-backup` bleibt bis zu einem getesteten Backup-/Restore-Vertrag gesperrt.
- MSM-Migration aus `root.epk`/weiteren Packs und der vollständige Client-UI-
  Rewrite starten erst in den dafür vorgesehenen Folgegates.

## Halt

Codex hält hier vor Schritt 021. Für die offenen Foundation-Folgepunkte oder
den Start von Gate 030 ist eine neue Freigabe erforderlich.
