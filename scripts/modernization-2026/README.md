# Modernization 2026 command surface

The entrypoint is `m2.ps1`. The project workflow is Git-free: local snapshot
IDs, file manifests, SHA-256 hashes and runtime logs are the source of truth.
No command changes Git metadata, downloads dependencies, opens firewall/router
ports or performs hidden administrator actions.

The current machine blocks direct script execution. Start a fresh PowerShell
process with the process-scoped bypass explicitly shown below; this does not
change the machine or user execution policy:

```powershell
Set-Location C:\Dev\M2Lead\lead-files-community
$ps = Join-Path $PSHOME 'powershell.exe'
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 help
```

Read-only commands:

```powershell
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 doctor
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 status
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 smoke
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 snapshot -Scope all
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 analyze
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 dependencies
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 security-audit
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 collect-logs
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\test-command-surface.ps1
```

Commands with effects are explicit and target only the known local resources:

```powershell
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 start -WhatIf
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 stop -WhatIf
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 build-server -Configuration Debug -WhatIf
& $ps -NoProfile -ExecutionPolicy Bypass -File .\scripts\modernization-2026\m2.ps1 build-client -Configuration Debug -WhatIf
```

`start` and `stop` operate only on the exact `db_d.exe`, auth `game_d.exe`
and channel1/game1 `game_d.exe` paths documented in `ARCHITECTURE.md`. MariaDB
is a separate Docker compose service and is never restarted by `status`,
`smoke` or `stop`. `db-backup` remains locked until a tested backup/restore
contract exists; the command fails clearly instead of producing a guessed dump.

Generated run artifacts live below
`C:\Dev\M2Lead\_local\modernization-2026\runs\<run-id>`. Redacted copies are
for handoff. Original logs are never copied unless `-IncludeOriginals` is
explicitly supplied, and then remain local-only.

`security-audit` inventories relevant CONFIG/conf/Compose files and selected
source categories read-only. Secret-bearing lines are redacted before the JSON
artifact is written. The Gate-030 interpretation is in
`docs/modernization-2026/SECURITY-FOUNDATION-REPORT.md` and the trust model is
in `docs/modernization-2026/SECURITY_MODEL.md`.

The existing `scripts/windows-local/doctor.ps1` is a historical baseline script
and still records Git metadata. It remains directly usable for historical
comparison, but it is not authoritative for the new workflow.
