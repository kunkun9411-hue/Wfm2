# Metin2 Modernization 2026 · Statusregister

Stand: 2026-08-01
Arbeitsmodus: Git-freier Windows-Workspace mit Snapshot-/SHA-256-Nachweisen
Arbeitsanweisung: `C:/Users/xapu/Downloads/CODEX_HANDOFF_METIN2_MODERNIZATION_2026.md`
Baseline-Nachweis: `C:/Dev/M2Lead/_local/gate-010-baseline-snapshot.md`

## Statusregeln

- `DONE` bedeutet: aktueller Nachweis liegt lokal vor.
- `IN_PROGRESS` bedeutet: im aktuellen Gate aktiv, aber noch nicht abgenommen.
- `PLANNED` bedeutet: nicht begonnen; keine Ergebnisse werden vorweggenommen.
- Handoff-Git-Referenzen werden in diesem Workspace durch Snapshot-ID, Dateimanifest, Artefakthashes und Laufzeitprotokoll ersetzt.

## 001–100

| ID | Schritt | Status | Nachweis / Gate |
|---:|---|---|---|
| 001 | Aktuellen Workspace verifizieren und einfrieren | DONE | Gate-010-Snapshot |
| 002 | Datenbankbenutzer und Grants vollständig prüfen | DONE | Gate-010-Snapshot |
| 003 | Legacy-`hotbackup` quellengestützt entscheiden | DONE | Gate-010-Snapshot |
| 004 | Datenbankimport, Migrationen und Restore-Fähigkeit verifizieren | DONE | Gate-010-Snapshot |
| 005 | Toolchain und x64-Abhängigkeiten für den Build abnehmen | DONE | Gate-010-Snapshot |
| 006 | Server als `Debug\\|x64` deterministisch bauen | DONE | Gate-010-Snapshot |
| 007 | Serverfiles, Links und Runtime-Dateien sicher bereitstellen | DONE | Gate-010-Snapshot |
| 008 | Alle Serverprozesse lokal starten, diagnostizieren und wieder stoppen | DONE | Gate-010-Snapshot |
| 009 | Client `Debug\\|x64` bauen und Runtime prüfen | DONE | Gate-010-Snapshot |
| 010 | Ersten vollständigen Login-Smoke-Test abschließen und Baseline taggen | DONE | Gate-010-Snapshot |
| 011 | Modernisierungsdokumentation und 100-Schritte-Statusregister anlegen | DONE | STATUS.md / ROADMAP.md |
| 012 | Ist-Architektur als Komponenten- und Datenflusskarte dokumentieren | DONE | ARCHITECTURE.md |
| 013 | Verbindlichen ADR- und Entscheidungsprozess einführen | DONE | adr/0000-template.md + ADRs |
| 014 | Einheitlichen lokalen Kommandoeinstieg schaffen | IN_PROGRESS | m2.ps1 + Command-Surface-Test; db-backup bleibt bewusst gesperrt |
| 015 | Debug- und Release-Build reproduzierbar kapseln | IN_PROGRESS | Debug server/client mehrfach; Client Release erfolgreich; Server Release fehlt in Solution |
| 016 | Idempotenten Komplett-Lifecycle für Entwickler herstellen | IN_PROGRESS | exact-path start/stop/status/smoke vorhanden; Vollorchestrierung offen |
| 017 | Zentrale Diagnose- und Run-Artefakte standardisieren | IN_PROGRESS | gate020-final-collect mit run.json, Redaction, Prozess-/Portstatus |
| 018 | Kontinuierlichen Windows-x64-Build einrichten | IN_PROGRESS | CI_RUNBOOK.md + lokale Debug/Release-Läufe; kein öffentlicher Runner |
| 019 | Statische Analyse und Warnungsbudget kontrolliert einführen | IN_PROGRESS | gate020-final-analyze: 630 Legacy-Warnungen, keine Sourceänderung; Diff-Gate offen |
| 020 | Abhängigkeiten, Buildherkunft und SBOM erfassen | DONE | gate020-final-dependencies2: 44 Komponenten, CycloneDX, Provenance |
| 021 | Bedrohungsmodell und Vertrauensgrenzen erstellen | DONE | SECURITY_MODEL.md + ADR-0005 |
| 022 | Secrets und umgebungsspezifische Konfiguration aus Git lösen | IN_PROGRESS | 43 redigierte Secret-/Setup-Befunde; ADR-0006 |
| 023 | Datenbankrollen nach minimalen Rechten trennen | IN_PROGRESS | read-only Grant-Prüfung; ADR-0007 |
| 024 | Passwortspeicherung migrationsfähig modernisieren | IN_PROGRESS | Legacy-`TPacketCGLogin3`/`PASSWORD()` belegt |
| 025 | Charakterlöschung vollständig serverseitig absichern | IN_PROGRESS | Löschpfad inventarisiert; Negativtests offen |
| 026 | GM- und Administrationsrechte als RBAC modellieren | IN_PROGRESS | `gmlist`/Authority-Pfade inventarisiert |
| 027 | Missbrauchsschutz und Rate-Limits einführen | IN_PROGRESS | Policy-/Abuse-Testdesign offen |
| 028 | SQL-Zugriffe systematisch härten | IN_PROGRESS | `DirectQuery`/`ReturnQuery`-Oberfläche inventarisiert |
| 029 | Eingaben, Dateipfade und Parser nach einheitlicher Policy validieren | IN_PROGRESS | Audit-Kategorien vorhanden; Policytests offen |
| 030 | Outbound-Netzwerk, Crashreporting und Binärvertrauen kontrollieren | IN_PROGRESS | Outbound-/Binary-Audit; `WinExec`/Release-Gates offen |
| 031 | Bekannte Bugs als reproduzierbare Testfälle katalogisieren | PLANNED | Folgegate |
| 032 | Clipboard-/IME-Crash robust beheben | PLANNED | Folgegate |
| 033 | Mount-Toggle und Seal-State konsistent reparieren | PLANNED | Folgegate |
| 034 | Stacking von Enchant-/Enhance-Items korrekt trennen | PLANNED | Folgegate |
| 035 | Equipment-Lock nach Drachensteinalchemie beseitigen | PLANNED | Folgegate |
| 036 | Equipment-, Belt-, Mount- und Shield-Slots vereinheitlichen | PLANNED | Folgegate |
| 037 | Transparenz-/Time-Sync-Fehler nach Login und Wiederbelebung untersuchen | PLANNED | Folgegate |
| 038 | Messenger- und Freundeslistenstatus synchronisieren | PLANNED | Folgegate |
| 039 | Gold-/Yang-Werte vollständig auf einen kanonischen 64-Bit-Vertrag bringen | PLANNED | Folgegate |
| 040 | Itemzellen, Stackgrößen und Wirtschaftsaktionen transaktional absichern | PLANNED | Folgegate |
| 041 | Konfigurationslandschaft vollständig inventarisieren | PLANNED | Folgegate |
| 042 | Zentrales, versioniertes Konfigurationsschema entwerfen | PLANNED | Folgegate |
| 043 | Typisierten Konfigurationsparser mit kompatiblem Fallback implementieren | PLANNED | Folgegate |
| 044 | Lokale Overrides und Secret-Injektion vereinheitlichen | PLANNED | Folgegate |
| 045 | Strikten Startup-Validator vor Prozessstart einführen | PLANNED | Folgegate |
| 046 | Versioniertes Datenbank-Migrationssystem einführen | PLANNED | Folgegate |
| 047 | Build-, Schema-, Content- und Protokollversionen sichtbar machen | PLANNED | Folgegate |
| 048 | Strukturiertes Logging mit Komponenten und Ereignis-IDs einführen | PLANNED | Folgegate |
| 049 | Crashdumps, Symbole, Rotation und Aufbewahrung professionalisieren | PLANNED | Folgegate |
| 050 | Healthchecks und interne Metriken bereitstellen | PLANNED | Folgegate |
| 051 | Netzwerkpakete und Ownership vollständig katalogisieren | PLANNED | Folgegate |
| 052 | Eine kanonische Quelle für gemeinsame Packetdefinitionen schaffen | PLANNED | Folgegate |
| 053 | Explizite sichere Serialisierung statt impliziter Structkopien etablieren | PLANNED | Folgegate |
| 054 | Protokollverhandlung und sichere Transportstrategie definieren | PLANNED | Folgegate |
| 055 | Parser und Protokolle mit Fuzzing prüfen | PLANNED | Folgegate |
| 056 | Ein geeignetes C++-Unit-Testfundament etablieren | PLANNED | Folgegate |
| 057 | Kerninvarianten mit Domain-Unit-Tests absichern | PLANNED | Folgegate |
| 058 | Automatisierte MariaDB-Integrationstests aufbauen | PLANNED | Folgegate |
| 059 | Headless-Smoke-Client für Kernabläufe entwickeln | PLANNED | Folgegate |
| 060 | Verbindliche Test- und Qualitätsmatrix in CI durchsetzen | PLANNED | Folgegate |
| 061 | Keine-neuen-Python-2-Abhängigkeiten-Policy und Client-Script-Inventur | PLANNED | Folgegate |
| 062 | Stabile Engine-zu-Script-Abstraktionsgrenze einführen | PLANNED | Folgegate |
| 063 | Alle Offline-Tools auf unterstütztes Python 3 konsolidieren | PLANNED | Folgegate |
| 064 | Python-3-Clientpilot mit einem isolierten UI-Modul durchführen | PLANNED | Folgegate |
| 065 | Schrittweisen Python-3-Migrationsplan für den Client ausführen | PLANNED | Folgegate |
| 066 | UTF-8- und Unicode-Vertrag über Source, DB, Locale und Netzwerk festlegen | PLANNED | Folgegate |
| 067 | Textdarstellung, IME und Font-Fallback modernisieren | PLANNED | Folgegate |
| 068 | Per-Monitor-DPI-Awareness und skalierbare UI-Basis schaffen | PLANNED | Folgegate |
| 069 | Responsive Layoutsystem mit Anchors und Constraints einführen | PLANNED | Folgegate |
| 070 | Gemeinsames UI-Komponenten- und Accessibility-Grundsystem etablieren | PLANNED | Folgegate |
| 071 | Renderer-Iststand, Zustände und Abhängigkeiten kartieren | PLANNED | Folgegate |
| 072 | D3D9-Baseline stabilisieren, Framerate entkoppeln und messen | PLANNED | Folgegate |
| 073 | Renderer-Abstraktion und D3D11-Prototyp aufbauen | PLANNED | Folgegate |
| 074 | Shader- und Materialsystem datengetrieben gestalten | PLANNED | Folgegate |
| 075 | Assetladen asynchron und budgetiert machen | PLANNED | Folgegate |
| 076 | Audio hinter eine moderne austauschbare Schnittstelle kapseln | PLANNED | Folgegate |
| 077 | Animation und Granny-Abhängigkeit isolieren | PLANNED | Folgegate |
| 078 | Vegetation und SpeedTree-Abhängigkeit kapseln | PLANNED | Folgegate |
| 079 | Deterministische Pack-, Manifest- und Integritätspipeline schaffen | PLANNED | Folgegate |
| 080 | Assetvalidatoren und kontrolliertes Hot-Reload für Entwicklung | PLANNED | Folgegate |
| 081 | Separaten Launcher als klar abgegrenzte Anwendung entwerfen | PLANNED | Folgegate |
| 082 | Signierte Update-Manifeste und vertrauenswürdigen Downloadpfad implementieren | PLANNED | Folgegate |
| 083 | Delta-Update, Repair und atomaren Rollback bereitstellen | PLANNED | Folgegate |
| 084 | Accountprofile sicher im Windows Credential Manager speichern | PLANNED | Folgegate |
| 085 | Login- und Serverauswahlfenster modernisieren | PLANNED | Folgegate |
| 086 | Charakterauswahl und Charaktererstellung neu strukturieren | PLANNED | Folgegate |
| 087 | Eingabe, Keybindings, Controller und Einstellungen modernisieren | PLANNED | Folgegate |
| 088 | Inventar, Itemvergleich, Shops und Tooltips überarbeiten | PLANNED | Folgegate |
| 089 | Combat-HUD, Buffs, Debuffs und Target-Information modernisieren | PLANNED | Folgegate |
| 090 | Chat, Questtracker, Karte und Accessibility als kohärente UX abschließen | PLANNED | Folgegate |
| 091 | Wirtschafts- und Gameplayaktionen konsequent serverautoritativ validieren | PLANNED | Folgegate |
| 092 | Unveränderliches Transaktionsjournal für Wirtschaftsvorgänge einführen | PLANNED | Folgegate |
| 093 | Offline-Shop oder Marktplatz erst auf Escrow-Basis entwickeln | PLANNED | Folgegate |
| 094 | Kosmetiksystem datengetrieben und erweiterbar aufbauen | PLANNED | Folgegate |
| 095 | Events, Missionen und Battlepass als generisches Regelwerk implementieren | PLANNED | Folgegate |
| 096 | Guild-Mark-System sicher und entkoppelt modernisieren | PLANNED | Folgegate |
| 097 | Last-, Soak- und Failure-Tests für den vollständigen Stack durchführen | PLANNED | Folgegate |
| 098 | Backup, Restore und Disaster-Recovery end-to-end testen | PLANNED | Folgegate |
| 099 | Lizenz-, Datenschutz-, SBOM- und Release-Sicherheitsgate abschließen | PLANNED | Folgegate |
| 100 | Geschlossene Alpha durchführen und `v0.1.0-modern-baseline` einfrieren | PLANNED | Folgegate |

## Aktueller Halt

Schritte 001–010 sind durch den Gate-010-Snapshot und den bestätigten Relog abgenommen. Schritte 011–013 sind fertig dokumentiert. Im Gate-020-Lauf wurden der Git-freie Kommandoeinstieg, reproduzierbare Debug-/Client-Release-Builds, Diagnosepakete, Analysebaseline und SBOM/Provenance aufgebaut. 014–019 bleiben wegen der offenen Vollorchestrierung, fehlender Server-Release-Konfiguration und fehlender Snapshot-Diff-Regel `IN_PROGRESS`; Schritt 020 ist nachweisbar fertig. Im Gate-030-Lauf wurden Security-Audit, Vertrauensmodell und ADRs erstellt. 022–030 bleiben wegen ausstehender Migrationen und Negativtests `IN_PROGRESS`; vor Schritt 031 stoppt Codex und fordert eine neue Freigabe an.

## Querschnittsziele

- MSM wird aus allen Packs und dem Runtimepfad entfernt; Asset-Bindings werden in ein kanonisches CSV-/JSON-Modell migriert.
- Die alte Lead-Client-UI wird innerhalb des Jahres durch eine neue Shell-, Screen- und Komponentenarchitektur ersetzt.
- Performance wird vor Optik gemessen: Build, Start, Frame-Pacing, Asset-Laden und UI-Hitches erhalten messbare Gates.
