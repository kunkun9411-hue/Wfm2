# Metin2 Modernization 2026 · AI / UI Dev Workspace

Diese öffentliche Repo ist der gemeinsame Arbeitsbereich für die Metin2-Modernisierung: Performance-Messung, Client-UI-Rework, Asset-Pipeline, Sicherheitsmodell und die Vorbereitung auf moderne Grafik.

Die README ist zugleich der Devlog. Nach jedem abgeschlossenen Gate werden Status, Belege, Entscheidungen und der nächste sichere Schritt hier ergänzt.

> Arbeitsprinzip: erst messen, dann umbauen. Performance vor Optik. Jede große Änderung braucht einen reproduzierbaren Test und eine klare Rückfallebene.

## Aktueller Stand

| Gate | Status | Ergebnis |
|---|---|---|
| 010 · Baseline | DONE | Client gestartet, Login und Ingame-Bewegung live bestätigt; lokale Services und Ports dokumentiert. |
| 020 · Engineering Foundation | DONE | Diagnose-, Status-, Snapshot- und Lifecycle-Werkzeuge; Release/Profile-/Static-Analysis-Struktur; 014–019 als aktive Arbeitslinien. |
| 030 · Security Foundation | IN PROGRESS | Sicherheitsinventar, Trust Boundaries und Least-Privilege-Zielbild dokumentiert; Credentials bleiben lokal. |
| 040 · Performance Proof | PLANNED | Frame-Time-, Main-Thread-, Draw-Call-, RAM- und Asset-Streaming-Baseline mit reproduzierbaren Szenen. |

## Devlog

### 2026-08-01 · Gate 010 — Baseline abgeschlossen

- Der Windows-Client wurde gepackt, gestartet, eingeloggt und im Spiel bewegt.
- MariaDB, Auth, DB und Game liefen lokal über 127.0.0.1.
- Die technische Richtung wurde festgelegt: messbare Stabilität und Performance vor neuen Grafikfeatures.

### 2026-08-01 · Gate 020 — Engineering Foundation

- Ein zentraler PowerShell-Einstiegspunkt unter scripts/modernization-2026/m2.ps1 bündelt Doctor, Status, Smoke, Snapshot, Lifecycle, Build und Security-Audit.
- Die lokale Arbeitsweise bleibt Git-frei: Snapshots, Hashes und Reports sichern den Zustand, ohne den Entwickler-Workflow umzustellen.
- Release-/Profile-Builds, statische Analyse und Diagnosegrenzen wurden als Grundlage für spätere Optimierung festgehalten.

### 2026-08-01 · Gate 030 — Security Foundation begonnen

- Der Security-Audit erfasst lokale Konfigurationen, ohne geheime Werte in Reports zu schreiben.
- Als technische Themen sind unter anderem Datenbank-Least-Privilege, Auth-/Packet-Grenzen, SQL-/Input-Härtung, WebView2-Navigation, Prozess-/Script-Ausführung und Pack-Tools markiert.
- Öffentliche Repo-Grenze: keine Server-Konfigurationen, Passwörter, Dumps, Logs, Datenbanken, EPK/EIX-Archive oder Builds.

### Nächster Devlog-Eintrag

- [ ] Security-Entscheidungen mit lokalem Test belegen.
- [ ] Performance-Baseline in einer reproduzierbaren Szene erfassen.
- [ ] UI-Zielbild und Screen-State-Matrix definieren.
- [ ] Erst danach kontrollierte Client- oder Asset-Änderung starten.

## Ziele der Modernisierung

### Performance

- Main-Thread-Hotspots sichtbar machen.
- Frame-Pacing, CPU/GPU-Zeit, Draw Calls, RAM und Ladezeiten messen.
- Asset-Streaming und Pack-Pipeline deterministisch, hashbar und reparierbar machen.
- D3D9 als stabile Baseline erhalten, bevor ein neuer Renderer als Pilot bewertet wird.

### Client und UI

- Das bestehende Python/UI-System schrittweise durch klare Zustände, Datenmodelle und wiederverwendbare Komponenten ersetzen.
- Die UI responsive skalierbar machen: DPI, Fenstergröße, Anchoring, Input-Fokus und Accessibility-Zustände.
- Legacy-Code nicht blind löschen: erst Verhalten erfassen, neue Komponente parallel testen, dann die alte Abhängigkeit entfernen.

### MSM, Effekte und Texturen

- MSM-Dateien gehören häufig zur Effekt- oder Texturzuweisung und liegen oft in der root-EPK.
- Die Ablösung wird pro Datenfamilie geplant: zunächst Schema und Referenzinventar, dann CSV oder JSON je nach Einsatzzweck, danach Loader, Validierung und Pack-Integration.
- Kein stiller Fallback: fehlende Referenzen müssen im Audit sichtbar werden.

### Sicherheit und Betrieb

- Keine Secrets im Repository.
- Lokale Overrides bleiben außerhalb der öffentlichen Repo.
- Datenbankrechte, Authentifizierung, Rate Limits, SQL-/Input-Grenzen und Tool-Ausführung werden vor Feature-Ausbau abgesichert.

## Repository-Struktur

- docs/modernization-2026/ — Roadmap, Gate-Reports, Security-Modell und ADRs.
- docs/ai/ — Prompts und Abläufe für ChatGPT/Codex bei UI-, Icon- und Asset-Arbeit.
- assets/icons/ — sichere Zielablage für geprüfte Icon-Quellen und Varianten.
- assets/ui/ — UI-Mockups, Screen-State-Material und Exportregeln.
- assets/references/ — Screenshots und Referenzen mit Herkunft und Lizenznotiz.
- source/shared/ — kuratierter Shared-Code-Kontext.
- source/client-ui/ — kuratierter Client-UI-Kontext.
- source/client-core/ — relevante Client-Core-Module für UI-, Effekt- und Pack-Fragen.
- source/client-pack/root/ — ausgewählte textbasierte root-Skripte; keine Archive oder Builds.
- scripts/modernization-2026/ — reproduzierbare lokale Diagnose- und Audit-Skripte.

## Mit ChatGPT an UI und Icons arbeiten

1. Screenshot oder Referenz unter assets/references/ ablegen und Herkunft notieren.
2. Den passenden Prompt aus docs/ai/ verwenden.
3. Relevante Datei aus source/ und gewünschtes Verhalten nennen.
4. Ergebnis zuerst als Konzept, SVG/PNG oder isolierte UI-Komponente prüfen.
5. Erst nach Review in die lokale Arbeitskopie übernehmen und im Devlog festhalten.

Für Bild- und Icon-Erstellung sollen nur Prompts und klare Exportvorgaben in die Repo. Keine erfundenen Produktionspfade und keine ungeprüften Binärdateien in den Quellkontext mischen.

## Öffentliche Repo-Grenze

Nicht hochladen:

- Passwörter, Tokens, .env-Dateien, private Schlüssel oder echte Zugangsdaten.
- Lead-Serverfiles, Datenbank-Dumps, lokale Logs, Crashdumps und Runtime-Artefakte.
- EXE/DLL, Debug-/Release-Ordner, .eix/.epk-Archive und lokale Pack-Ausgaben.
- Produktions-IP-Adressen oder private Infrastruktur, sofern sie für die UI-Arbeit nicht nötig sind.

Die Repo enthält bewusst einen kuratierten Text-Snapshot. Sie ist Arbeitskontext für AI-gestützte Entwicklung, nicht die vollständige Server- oder Release-Ablage.

## Statuspflege

Jeder Devlog-Eintrag nennt:

- Datum und Gate.
- Was tatsächlich geprüft oder gebaut wurde.
- Beleg oder Testgrenze.
- Offene Risiken.
- Nächsten kleinen, reversiblen Schritt.

Letzte Aktualisierung: 2026-08-01 · Gate 010 DONE · Gate 020 DONE · Gate 030 IN PROGRESS.
## Client-Visualquellen

Der Repo enthält jetzt den kuratierten visuellen Client-Kontext für UI- und Asset-Arbeit:

- assets/client/ui/ — allgemeine UI-Atlanten, Fenster, Intro-, Login-, Select-, Taskbar- und Game-Interface-Grafiken aus ETC/ymir work/ui.
- assets/client/locale/de/ui/ — deutsche UI-/Locale-Assets inklusive lokalisierter Login- und Interface-Bilder.
- assets/client/icons/item/ — Item-Icons aus icon/icon/item.
- assets/client/icons/action/ und assets/client/icons/face/ — Aktions- und Gesichts-Icons.
- assets/client/loading/ — Loading-Screens und zugehörige .sub-Dateien.
- assets/client/effects/select-character/ — ausgewählte Character-Select-Effekte.
- source/client-pack/uiscript/ — echte UI-Layout-Skripte aus pack/uiscript/uiscript.

Die Originalformate bleiben erhalten. Bei DDS-/TGA-Atlanten gehört die zugehörige .sub-Datei zum Asset-Kontext; sie beschreibt den Ausschnitt und darf nicht isoliert ersetzt werden.

Der vollständige 1,1-GB-Pack bleibt lokal. Dieser öffentliche Repo-Snapshot enthält die für UI, Login, Icons, Loading und ChatGPT-Assetarbeit relevanten Dateien.