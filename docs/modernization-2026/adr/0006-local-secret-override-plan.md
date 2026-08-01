# ADR-0006 · Lokale Secret-Injektion

## Status

Planned; Gate 030 inventarisiert den Iststand, implementiert noch keine
Credential-Rotation.

## Entscheidung

Runtime-Credentials werden aus den versionierten CONFIG-/Compose-Dateien
entfernt und über eine lokale, nicht distributierte Quelle injiziert. Die
Quelle muss vor Prozessstart validiert werden, darf nicht in Logs, Packs,
Crashreports oder Buildartefakten landen und muss für jede Umgebung getrennt
sein.

## Migrationsanforderungen

1. Bestehende lokale Datenbank sichern und Restore in einer Wegwerf-Instanz
   nachweisen.
2. Secret-Quelle und Fallback-Verhalten definieren; kein stiller Default für
   öffentliche Builds.
3. Alle Serverprozesse auf den neuen Parser umstellen und mit absichtlich
   fehlendem Secret abbrechen lassen.
4. Redigierten Config-Scan und Start-Smoke wiederholen.

Bis diese Punkte erfüllt sind, bleiben die lokalen Zugangsdaten ein offen
dokumentierter Gate-030-Befund und der Workspace ist kein Release-Input.
