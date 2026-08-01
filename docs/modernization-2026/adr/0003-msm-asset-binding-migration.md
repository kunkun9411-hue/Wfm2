# ADR-0003 · MSM durch kanonische Asset-Bindings ersetzen

- Status: accepted as target architecture
- Datum: 2026-08-01
- Betroffene Gates: 020, 079, 080, 099

## Kontext

MSM-Dateien liegen häufig in Packs und beschreiben Modell-, Textur-, Material- und Effektzuweisungen. Ein bloßer Dateiendungswechsel würde semantische Referenzen und Renderverhalten gefährden.

## Entscheidung

MSM wird zuerst aus allen EIX/EPK-Paaren in isolierter Umgebung inventarisiert und in ein neutrales Binding-Modell überführt. Flache, wiederholte Zuweisungen werden als validiertes CSV geführt; verschachtelte Modell-/Material-/Effektbindungen als versioniertes JSON. Danach wird der MSM-Reader aus Runtime und Packpipeline entfernt.

## Abnahme

Keine `.msm`-Datei oder MSM-Referenz im Releasemanifest; alle Texturen, Materialien, Effekte und Attachments bestehen eine visuelle und referenzielle Vergleichsprüfung.
