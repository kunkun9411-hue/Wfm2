# ADR-0002 · Lokale Loopback-Runtime

- Status: accepted
- Datum: 2026-08-01
- Betroffene Gates: 010, 020, 030

## Kontext

Der lokale Entwicklungsstand muss startbar und diagnostizierbar sein, ohne öffentliche Erreichbarkeit.

## Entscheidung

MariaDB wird über `127.0.0.1:3306` veröffentlicht. Auth und Game1 binden auf Loopback; keine Router-, Firewall- oder öffentliche Serverfreigabe gehört zum Foundation-Stand.

## Folgen und Rollback

Weitere Channels bleiben bis zu einer eigenen Prüfung UNKNOWN. Ein falscher Bind kann nur auf den geprüften lokalen Configstand zurückgesetzt werden.

## Nachweis

Gate-010-Snapshot und `docs/windows-local/PORTS.md`.
