# Ist-Architektur · Windows Local Baseline

Stand: 2026-08-01. Aussagen sind nur aufgenommen, wenn sie aus Workspace, Konfiguration, Laufzeit oder Snapshot belegt sind. Unklare Pfade bleiben `UNKNOWN`.

## Komponentenkarte

| Komponente | Rolle | Eingang/Ausgang | Laufzeitstand | Beleg |
|---|---|---|---|---|
| MariaDB `lead_db_container` | Persistente Daten für account/common/player/log | TCP `127.0.0.1:3306` | läuft | Docker-Portmapping, DB-Rowcounts |
| `db_d.exe` | DB-Core zwischen Serverprozessen und MariaDB | interner DB-Port `15000` laut lokaler Baseline | läuft | `Lead-Serverfiles/db`, Runtime-PID |
| Auth `game_d.exe` | Login-/Serverauswahlpfad | `127.0.0.1:11000`, `12000` | läuft | `Lead-Serverfiles/auth/CONFIG`, Runtime-PIDs |
| Game1 `game_d.exe` | Spielkanal und Charakter-/Itempfad | `127.0.0.1:13001`, `14001` | läuft | `Lead-Serverfiles/channel1/game1/CONFIG`, Runtime-PID |
| Game2 / Channel99 / Markserver | zusätzliche Serverdienste | Ports und vollständiger Lifecycle | UNKNOWN / nicht im Gate-010-Lauf | Handoff und Serverfiles vorhanden |
| `metin2client_debug.exe` | Windows-Client, UI, Netzwerk und Renderer | Clientprofil/Loopback, Packzugriff | gebaut; Relog bestätigt | `Lead-Client`, Gate-010-Snapshot |
| `Lead-Client/pack` | EIX/EPK-Assets, Root, UI, Modelle, Effekte und Texturen | Client liest Packindex und Inhalte | 106 EIX + 106 EPK | Packinventar, Root-Hashes |
| `Lead-Tools` / PackMakerLite | Offline-Tools und Packworkflow | Dateien/Manifeste | nicht als Runtime angenommen | Toolbestand und Handoff |

## Datenflüsse

### Login und Charakter

1. Client liest sein lokales Profil und baut die Verbindung zum Auth-Endpunkt auf.
2. Auth validiert die Anmeldung über DB-Core und MariaDB im `account`-/`common`-Kontext.
3. Nach Server-/Charakterauswahl wechselt der Client zum Game1-Endpunkt.
4. Game1 lädt Charakter-/Itemdaten über DB-Core aus `player` und bestätigt die erste Map.
5. Der Gate-010-Relog bestätigte, dass der persistente Datenbestand den Neustart übersteht.

### Items und Persistenz

Clientaktion → Game1-Handler → serverseitige Mutation → DB-Core → MariaDB `player`/`log` → Rückmeldung an Client. Konkrete Packet-Handler und Transaktionsgrenzen werden ab Schritt 051/057 als Sourcekarte nachgezogen.

### Chat, P2P und Mapwechsel

Die fachliche Verantwortung ist im Client-/Game-Code verteilt; genaue Handler- und Sequenzbeziehungen sind für den Foundation-Stand `UNKNOWN` und werden nur mit Sourcepfad ergänzt. Es wird keine Architektur aus Namenskonventionen erfunden.

### Assets und MSM

Client → Packindex (`.eix`) → Packinhalt (`.epk`) → Modell-/Textur-/Material-/Effektauflösung. `root.epk` ist die erste Prüfzone; anschließend werden alle Packpaare extrahiert und gegen ein kanonisches Asset-Binding-Schema geprüft. MSM-Inhalte sind noch nicht migriert.

## Ownership-Grenzen

- Client entscheidet Darstellung und Eingabe, aber nicht über autoritative Wirtschaftsdaten.
- Auth und Game1 besitzen getrennte Prozessgrenzen; DB-Core vermittelt die persistente Datenbankkommunikation.
- MariaDB bleibt lokal und wird nicht als öffentliche Spielserver-Schnittstelle behandelt.
- Neue UI-Logik und neue Asset-Bindings dürfen nicht direkt von unmarkierten Lead-Legacy-Globals abhängen.

## Offene Architekturfragen

- Exakte DB-Core-Port-/Configbeziehung für alle zusätzlichen Channels.
- Vollständige Auth-/Game1-/P2P-Sequenz für Chat und Mapwechsel.
- MSM-Feldinventar in `root.epk` und allen weiteren Packs.
- Zielvertrag für neue UI-Shell, Screennavigation und Engine-/Script-Grenze.
