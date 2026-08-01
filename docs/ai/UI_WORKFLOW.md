# UI-Workflow für ChatGPT/Codex

## Eingang

- Screenshot oder Mockup mit Zielgröße und gewünschtem Zustand.
- Betroffene uiscript-/Python-Datei oder C++-Bridge aus source/client-ui/.
- Aktuelles Verhalten, gewünschtes Verhalten und bekannte Einschränkungen.
- Eingabemethoden: Maus, Tastatur, Escape, Drag, Fokus und Controller falls relevant.

## Arbeitsablauf

1. Bestehende UI-Struktur und Abhängigkeiten lesen.
2. Screen-State-Matrix erstellen: hidden, loading, empty, populated, error, disabled, focused.
3. Layout-Kontrakte festlegen: Anchors, Mindestgröße, DPI-Skalierung, z-Order und Input-Fokus.
4. Datenfluss und Events benennen; keine globale Variable ohne Begründung einführen.
5. Kleinste isolierte Änderung erzeugen.
6. Mit Screenshot, Start/Close/Resize/Input und Performance-Sanity-Check prüfen.
7. Erst danach in die lokale Quelle übernehmen und den Devlog ergänzen.

## Ausgabeformat

- Annahmen.
- Betroffene Dateien.
- UI-State-Matrix.
- Code oder uiscript-Entwurf.
- Asset-Liste mit Namen, Größe, Format und Transparenz.
- Testfälle.
- Offene Fragen und Rückfallebene.

## Designrichtung

Modernes Gaming-UI darf klar, kontrastreich und charaktervoll sein. Lesbarkeit, stabile Frame-Zeit, geringer Overdraw und saubere Skalierung sind aber harte technische Anforderungen.