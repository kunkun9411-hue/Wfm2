# ADR-0005 · Security-Vertrauensgrenzen

## Status

Accepted for Gate 030 inventory; remediation remains open.

## Entscheidung

Client, Pack-/Config-Eingaben und Netzwerkpakete gelten als untrusted. Auth,
Game und DB bilden getrennte Prozessgrenzen. Autorität für Accounts,
Wirtschaft, Charakterlöschung und GM-Rechte liegt ausschließlich serverseitig.
WebView2, Crashreporting und externe Ziele bleiben standardmäßig gesperrt und
werden nur über explizite Policies freigeschaltet.

## Konsequenzen

- Jede neue Funktion erhält eine Zone, eine Eingangsvalidierung und einen
  Negativtest.
- Pack- und MSM-Ablösungen dürfen keine Sicherheitsautorität aus Assetdaten
  ableiten.
- Der Gate-030-Bericht führt offene Controls als Backlog, statt sie durch
  UI-/Featuretexte zu verdecken.
