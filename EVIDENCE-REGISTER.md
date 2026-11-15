# Evidence register

A source capture proves the result and time it records. A configuration file proves the intended implementation. Historical narratives should be paired with underlying output.

## Latest source records

| Path | Meaning | Origin |
| --- | --- | --- |
| evidence/morning-start-20261115-103523/StartInstances-original.json | Successful current-instance morning start, plus a prior-day old-instance event | Uploaded project folder |
| evidence/morning-start-20261115-103523/StopInstances-original.json | Successful current-instance evening stop | Uploaded project folder |
| evidence/morning-start-20261115-103523/website-start.json | Enabled morning schedule / Lagos | Uploaded project folder |
| evidence/morning-start-20261115-103523/website-stop.json | Enabled evening schedule / Lagos | Uploaded project folder |
| evidence/morning-start-20261115-103523/instance-status.json | Running and all three checks OK | Uploaded project folder |
| evidence/morning-start-20261115-103523/start-summary.txt | Human-readable derived start summary | Uploaded project folder |
| evidence/morning-start-20261115-103523/website-after-scheduled-start.png | Browser capture after startup; clean filename copy of supplied .png.png | Uploaded project folder |

## Latest verification extracts

- `evidence/verification-20261115/alarms.json`: extracted from the uploaded PowerShell session; formatted JSON, not a new service fetch.
- `evidence/verification-20261115/patch-state.json`: extracted from the uploaded PowerShell session; formatted JSON, not a new service fetch.
- `evidence/verification-20261115/guardduty.json`: extracted from the uploaded PowerShell session; formatted JSON, not a new service fetch.
- `evidence/verification-20261115/dlm-root-snapshots.json`: extracted from the uploaded PowerShell session; formatted JSON, not a new service fetch.
- `evidence/verification-20261115/website-alarm-history.json`: extracted from the uploaded PowerShell session; formatted JSON, not a new service fetch.

Original transcript: `the original 15 November terminal transcript in the separate private handover`. See `evidence/verification-20261115/PROVENANCE.md`.

## Earlier review collection

59 original screenshot PNG files in `the separate private originals archive`; 32 selected gallery images in `evidence-guide/images/`. Byte-identical repeated screenshots remain retained. The selected evidence includes GuardDuty and EC2-status inbox receipt, central MFA enrollment, security rules and shutdown captures. Original gallery captions are dated historical explanations; current STATUS.md supersedes older pending statuses.

## Interpretation rules

A sample GuardDuty finding is synthetic. A requested ALARM transition is not an actual hardware failure. MFA enrollment is not MFA enforcement. Central-account root MFA does not establish workload-root MFA. A completed new automatic snapshot is not a restore test of that new snapshot. An enabled backup policy alone is not proof of a completed backup. A Lambda invocation without an error can still return a website failure metric.
