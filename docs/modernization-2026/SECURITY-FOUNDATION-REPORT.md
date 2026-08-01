# Gate 030 · Security Foundation Report

Stand: 2026-08-01  
Workspace: `C:/Dev/M2Lead/lead-files-community`  
Arbeitsmodus: Git-freier Snapshot-/Manifest-/SHA-256-Nachweis

## Ergebnis

Die Security Foundation ist als Ist-Modell, Vertrauensgrenze und
Remediation-Backlog dokumentiert. Die Audit- und Dokumentationsseite des Gates
ist abgeschlossen; die eigentlichen sicherheitsrelevanten Migrationen bleiben
offen und werden nicht als fertig behauptet.

## Ausgeführter Nachweis

```text
Kommando: m2.ps1 security-audit -RunId gate030-security-inventory
Exitcode: 0
Artefakt: C:\Dev\M2Lead\_local\modernization-2026\runs\gate030-security-inventory\security-audit.json
Grenze: read-only; keine Runtime-, DB-, Pack-, Registry- oder Prozessänderung
```

Der redigierende Scan erfasste 15 Konfigurations-/Setup-Dateien und 43 Secret-
Konfigurationsbefunde. Quelltexttreffer werden kategorisiert und gekappt, damit
der Nachweis übersichtlich bleibt; geheime Werte werden nicht in das Artefakt
geschrieben.

Nach dem Audit liefen `m2.ps1 doctor`, `m2.ps1 status`, `m2.ps1 smoke` und der
Command-Surface-Test erfolgreich. DB, Auth und Game1 blieben auf den erwarteten
Loopback-Ports aktiv; es wurde kein Binary neu gebaut.

## Befunde

| Bereich | Befund | Bewertung |
|---|---|---|
| Secrets | Mehrere `CONFIG`-/`conf.txt`-Dateien enthalten weiterhin lokale DB-Credentials; Compose enthält ebenfalls lokale Zugangsdaten. | offen, vor Release zu migrieren |
| DB-Rechte | `root@%` hat `ALL ON *.*` plus `GRANT OPTION`; `metin2@%` hat keine globalen Rechte/Grant-Option, aber `ALL` auf `account`, `common`, `player` und `log`. | für lokale Baseline sichtbar, für Produktion nicht akzeptabel |
| Legacy-Login | `TPacketCGLogin3` enthält ein Passwortfeld; `input_auth.cpp` verwendet den Legacy-`PASSWORD()`-Pfad. | Protokoll-/Hash-Migration erforderlich |
| Charakterlöschung | Server prüft Login, Private-Code und Levelgrenzen und führt danach den Delete-Pfad aus. Zusätzlich wird effektiv nur ein siebenstelliger Code verglichen, der Löschcode wird geloggt und die Löschung ist mehrstufig/asynchron statt transaktional. | sicherheitskritisch offen |
| GM/Admin | `gmlist`, Authority-Strings und Host-IP bestimmen privilegierte Zustände; `test_server` setzt global `GM_IMPLEMENTOR`, die Kommandoliste enthält Authority-Schwellen. | RBAC- und Startflag-Migration erforderlich |
| SQL | Viele `DirectQuery`-/`ReturnQuery`-Pfade bauen Queries formatiert; Quest-Lua-APIs und Multi-Statements erweitern die Oberfläche. | systematisch zu härten |
| Outbound/Crash | `error.cpp` enthält einen unqualifizierten `WinExec("errorlog.exe")`; zusätzlich existieren Shell-/Lua-Prozesspfade, ein altes externes Reporting-Ziel ist auskommentiert. | Helper und Shellpfade entfernen oder strikt sandboxen |
| WebView2 | CWebBrowser navigiert über übergebenes `addr`; Wiki-/Mall-HTTP-Ziele sind im Client enthalten, eine explizite Navigation-/Download-Allowlist ist nicht belegt. | UI-Gate mit Sicherheitskontrolle |
| Binärvertrauen | Hash-/PE-Inventur ist vorhanden; x86-`libmysql.dll` und x64-Ziele bleiben ein Architekturhinweis. PackMakerLite bleibt nicht installiert und ohne Registry-Import. | Release-Gate offen |

## Schritte 021–030

| Schritt | Status | Begründung |
|---:|---|---|
| 021 | DONE | Vertrauensgrenzen, Zonen und zehn priorisierte Risiken dokumentiert. |
| 022 | IN_PROGRESS | Secret-Funde sind belegt; Secret-Injektion und Fallback-Entfernung fehlen. |
| 023 | IN_PROGRESS | Rechte inventarisiert; Rollen-Split und Negativtests fehlen. |
| 024 | IN_PROGRESS | Legacy-Passwortpfad belegt; migrationsfähiger Ersatz fehlt. |
| 025 | IN_PROGRESS | Löschpfad inventarisiert; vollständiger serverautoritärer Vertrag fehlt. |
| 026 | IN_PROGRESS | GM-/Authority-Pfade belegt; zentrales RBAC fehlt. |
| 027 | IN_PROGRESS | Einheitliche Limits und Abuse-Tests sind nicht nachgewiesen. |
| 028 | IN_PROGRESS | SQL-Oberfläche inventarisiert; zentrale sichere Query-Schicht fehlt. |
| 029 | IN_PROGRESS | Eingaben sind punktuell validiert/escaped; einheitliche Policy fehlt. |
| 030 | IN_PROGRESS | Outbound-/Crash-/Binary-Inventur liegt vor; `WinExec`, WebView2-Policy und Release-Gates sind offen. |

## Zusätzliche bestätigte Hochrisiko-Nachweise

- MariaDB: `root@%` besitzt `ALL PRIVILEGES ON *.*` und `PROXY ... WITH GRANT OPTION`.
- Datenbank-Setup: Root-Host, Root-Benutzer und Default-Passwort stehen in
  `Lead-Database-Scripts/compose.yml` und `setup.py`; Runtime-Konfigurationen
  wiederholen lokale Zugangsdaten.
- WebView2: `CWebBrowser.cpp` übergibt `addr` ohne erkennbare Allowlist an
  `Navigate`; `consolemodule.py` und `uishop.py` enthalten externe HTTP-Ziele.
- Test-/Adminpfad: `gm.cpp` und `char.cpp` geben bei `test_server` global
  `GM_IMPLEMENTOR`; `input_p2p.cpp` akzeptiert den Shutdown-Header ohne im
  Handler sichtbare zusätzliche Command-Autorisierung.
- Abuse-/Parserpfade: Slash-Kommandos werden vor dem normalen Chat-Counter
  dispatcht; der Command-Parser akzeptiert Präfixe; variable DB-/P2P-Payloads
  brauchen explizite Remaining-Length- und Overflow-Tests.
- Quest-/SQL-Pfad: `questlua_pc.cpp` baut Award-Queries aus Lua-Eingaben;
  `AsyncSQL.cpp` aktiviert Multi-Statements. Das ist ein priorisierter
  Prepared-Statement-/Range-Check-Kandidat.

## Bewusste Nichtänderungen

- Keine Passwörter rotiert.
- Keine MariaDB-Grants, Tabellen oder Daten verändert.
- Keine Login-, Lösch-, GM- oder SQL-Produktionslogik blind gepatcht.
- Keine Server-/Client-Binaries neu gebaut; Gate-020-Runtime bleibt unverändert.
- Kein Pack, keine MSM-Datei und keine UI geändert.

## Nächster Block

Schritt 031 beginnt erst nach einer neuen Freigabe. Der nächste sinnvolle
Arbeitsblock ist die Correctness Baseline: bekannte Bugs als reproduzierbare
Tests katalogisieren und erst danach gezielte Fixes mit frischen Logs und
Snapshots durchführen.
