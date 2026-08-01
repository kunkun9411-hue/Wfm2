# ADR-0004 · Vollständiger Client-UI-Rewrite

- Status: accepted as target architecture
- Datum: 2026-08-01
- Betroffene Gates: 068–070, 085–090, 100

## Kontext

Der ursprüngliche Lead-Client enthält eine stark gekoppelte UI-Schicht. Ziel ist, innerhalb eines Jahres nahezu keine alte Lead-UI-Logik mehr im aktiven Frontend zu haben.

## Entscheidung

Eine neue UI-Shell mit Komponenten-, Theme-, Input-, DPI-, Unicode- und Screenverträgen wird parallel aufgebaut. Alte Fenster dürfen nur über markierte, befristete Adapter erreichbar bleiben. Neue Features dürfen keine unmarkierten Legacy-Globals erweitern.

## Migration und Rollback

Die Migration erfolgt in testbaren Screen-Wellen: Shell, Login, Charakter, HUD, Chat/Quest/Karte, Inventar/Shop und Restfenster. Jede Welle besitzt Screenshot-/Input-/Performance-Abnahme und kann auf den letzten geprüften Wellenstand zurückgesetzt werden.

## Definition of Done

Alle unterstützten Screens sind neu implementiert, alte UI-Aufrufer inventarisiert oder gelöscht, Kernauflösungen/DPI/IME/Keyboardpfade geprüft und kein Legacy-Fallback bleibt als Dauerzustand aktiv.
