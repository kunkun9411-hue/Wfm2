# Metin2 Modernization 2026 · Foundation Roadmap

Diese Datei ist die knappe Managementsicht. Die vollständigen 100 Arbeitsschritte bleiben im Modernization-Handoff; der technische Status steht in `STATUS.md`.

## Leitplanken

- Git ist kein Bestandteil des Arbeitsprozesses. Baselines werden als vollständige lokale Snapshots mit Dateimanifest und SHA-256 festgehalten.
- Keine öffentliche Serverfreigabe, kein Router-/Firewall-Exposure und keine unversionierte Packet-/Schemaänderung.
- MSM wird nicht umbenannt, sondern semantisch in ein validiertes Asset-Binding-Modell überführt und danach aus Packs und Runtime entfernt.
- Die Client-UI wird neu aufgebaut. Alte Lead-UI darf nur in markierten, befristeten Adaptern weiterlaufen.
- D3D9 bleibt die stabile Messbaseline; Renderer-Modernisierung folgt erst nach reproduzierbaren Performancewerten.

## Gate-Übersicht

| Gate | Bereich | Status | Nächster Nachweis |
|---:|---|---|---|
| 010 | Windows Baseline | DONE | Snapshot und Relog bestätigt |
| 020 | Engineering Foundation | DONE | 020 nachweisbar; 014–019 bleiben offen |
| 030 | Security Foundation | IN_PROGRESS | Audit/Modell dokumentiert; Remediations offen |
| 040 | Correctness Baseline | PLANNED | neue Freigabe nach Gate 030 |
| 050 | Operability | PLANNED | neue Freigabe nach Gate 040 |
| 060 | Protocol & Tests | PLANNED | neue Freigabe nach Gate 050 |
| 070 | Client Platform | PLANNED | neue Freigabe nach Gate 060 |
| 080 | Render & Assets | PLANNED | MSM-/Pack-/Renderer-Gates |
| 090 | Player UX | PLANNED | UI-Rework-Wellen |
| 100 | Modern Baseline | PLANNED | geschlossene Alpha |

## Foundation 011–020

011–013 sind dokumentiert. Im Foundation-Lauf sind `m2.ps1`, exact-path Lifecycle-Bausteine, reproduzierbare Debug-/Client-Release-Buildmanifeste, redigierte Diagnosepakete, Analysebaseline und eine CycloneDX-SBOM mit Provenance entstanden. 014–019 bleiben offen, weil Vollorchestrierung, Server-Release-Konfiguration und Snapshot-Diff-Regeln noch fehlen; 020 ist mit 44 inventarisierten Komponenten und expliziten Unknowns nachgewiesen. Gate 030 hat nun ein read-only Security-Audit, ein Vertrauensmodell und drei Security-ADRs; Secret-, Rollen-, Passwort-, Lösch-, RBAC-, SQL- und Outbound-Remediations bleiben bewusst offen.

## Quellen

- Modernization-Handoff: `C:/Users/xapu/Downloads/CODEX_HANDOFF_METIN2_MODERNIZATION_2026.md`
- Baseline-Snapshot: `C:/Dev/M2Lead/_local/gate-010-baseline-snapshot.md`
- Desktop-Ansicht: `C:/Users/xapu/Desktop/Metin2_2026_Roadmap.html`
- Security-Modell: `C:/Dev/M2Lead/lead-files-community/docs/modernization-2026/SECURITY_MODEL.md`
- Security-Gate-Bericht: `C:/Dev/M2Lead/lead-files-community/docs/modernization-2026/SECURITY-FOUNDATION-REPORT.md`
