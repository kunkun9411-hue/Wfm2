# ADR-0007 · Datenbankrollen nach Prozess trennen

## Status

Planned; keine Grants wurden im Gate-030-Audit verändert.

## Entscheidung

Der gemeinsame lokale Account wird langfristig durch getrennte Rollen für
Auth, Game, DB-/Migration und Log ersetzt. Jede Rolle erhält nur die Tabellen
und Operationen, die der nachgewiesene Prozess benötigt. `root@%` mit
`ALL ON *.*` und `GRANT OPTION` wird auf lokale Initialisierung/Wartung
begrenzt; Root bleibt außerhalb der Runtime.

## Migrationsanforderungen

- Query-Inventar pro Prozess und Schema erstellen.
- Rollen in einer versionierten Migration anlegen; bestehende Runtime bleibt
  bis zur erfolgreichen Parallelprüfung verfügbar.
- Für jede Rolle Positiv- und Negativtests ausführen.
- Backup/Restore und Login-Smoke nach dem Umschalten wiederholen.
- `hotbackup` nicht anlegen, solange die Quellverwendung nicht nachgewiesen
  ist; die bestehende ADR-008-Entscheidung bleibt gültig.
