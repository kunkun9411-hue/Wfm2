# ADR-0001 · Git-freie Baseline-Snapshots

- Status: accepted
- Datum: 2026-08-01
- Betroffene Gates: 010, 011, 015, 020

## Kontext

Der Arbeitsprozess verwendet Git nicht als Bedien- oder Freigabewerkzeug. Gate 010 benötigt trotzdem eine reproduzierbare Referenz für Source-, Build-, Pack- und Runtimezustand.

## Entscheidung

Baselines werden als lokale Snapshot-Artefakte mit Zeitstempel, Dateipfaden, Größen, SHA-256-Hashes, Toolchain-Informationen, DB-Rowcounts und Laufzeitnachweisen festgehalten. Der Snapshot ist die Referenz für Vergleiche und Rollback.

## Folgen und Rollback

Keine Git-Befehle, Branches oder Tags sind erforderlich. Rollback bedeutet, den vorherigen vollständigen, geprüften Datei-/Pack-/Datenstand wiederherzustellen. Snapshot-Dateien dürfen keine Secrets enthalten.

## Nachweis

`C:/Dev/M2Lead/_local/gate-010-baseline-snapshot.md`
