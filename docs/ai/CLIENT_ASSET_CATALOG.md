# Client-Asset-Katalog

Stand: 2026-08-01

Dieser Katalog trennt visuelle Quellen, Layout und Logik. Er ist die Arbeitskarte für ChatGPT/Codex, wenn Screens, Icons oder Login-UI modernisiert werden.

## Quellenkarte

| Repo-Pfad | Ursprungsbereich | Verwendung |
|---|---|---|
| assets/client/ui/ | Lead-Client/pack/ETC/ymir work/ui | Core-UI-Snapshot mit Intro/Login, Taskbar, Fenstern, Quest, Dungeon, Guild, Pattern und Switchbot. |
| assets/client/locale/de/ui/ | Lead-Client/pack/locale_de/locale/de/ui | Deutsche lokalisierte UI-Assets und große Locale-Bilder. |
| assets/client/icons/item/ | Lead-Client/pack/icon/icon/item | Vollständiger Satz direkt referenzierter Item-TGA-Icons. |
| assets/client/icons/action/ | Lead-Client/pack/icon/icon/action | Emote-/Aktions-Icons. |
| assets/client/icons/face/ | Lead-Client/pack/icon/icon/face | Gesichts-/Charakter-Icons. |
| assets/client/loading/ | Lead-Client/pack/uiloading | Loading-Bilder plus .sub-Metadaten. |
| source/client-pack/uiscript/ | Lead-Client/pack/uiscript/uiscript | Fenstergröße, Position, Child-Elemente, Bilder und Alignment. |
| source/client-pack/root/ | Lead-Client/pack/root | UI-Logik, Events und Zustände. |
| source/client-ui/UserInterface/ | Lead-Client-Source/UserInterface | Native Python-/UI-Bridge und Client-Funktionen. |

## Wichtig für Asset-Arbeit

- .sub ist keine optionale Beilage: Sie beschreibt den Ausschnitt eines DDS-Atlas.
- Item-Icons werden direkt über ihre TGA-Datei und die Item-/Locale-Zuordnung referenziert.
- Virtuelle Pfade wie d:/ymir work/ui/... werden über den Pack-Index auf die entpackte Quelle abgebildet.
- Login, Loading und Character-Select können aus allgemeinem UI, Locale-UI und Effect-Assets zusammengesetzt sein.
- Vor einer Änderung immer die Referenzkette notieren: uiscript → Bildpfad → Atlas → .sub → Pack-Ziel.

## ChatGPT-Arbeitsablauf

1. Screenshot oder Zielzustand nennen.
2. Passendes uiscript und root-Modul nennen.
3. Assetpfad inklusive Atlas und .sub angeben.
4. Zustände normal/hover/pressed/disabled/selected festlegen.
5. Antwort als isolierten Entwurf mit Dateiliste, Exportgrößen und Testfällen anfordern.
6. Erst nach Sichtprüfung und lokalem Start in die Arbeitskopie übernehmen.

## Umfang

- Der Core-UI-Snapshot ist bewusst kleiner als der komplette ETC/ui-Bereich; Questboard und Welt-/Map-Material bleiben lokal.
- Item-Icons, deutsche UI-Assets, Loading, UI-Skripte und Character-Select-Effekte sind vollständig im kuratierten Satz enthalten.
- Der übrige 1,1-GB-Pack bleibt lokal, insbesondere Welt-, Monster-, Map-, Sound- und vollständige Servermaterialien.