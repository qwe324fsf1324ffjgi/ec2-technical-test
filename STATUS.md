# Current status - 15 November 2026

Start with [ACCEPTANCE.md](ACCEPTANCE.md) for the requirement-by-requirement record and [REPORT.pdf](REPORT.pdf) for the detailed handover.

## Closed by the latest evidence

- Successful scheduled stop on 14 November at 19:00:30 Lagos and start on 15 November at 07:00:23, targeting the current instance under the Scheduler role.
- Both schedules enabled in Africa/Lagos, flexible windows OFF.
- Current instance running, system/instance/attached-EBS checks OK; website shown loading afterward.
- Completed encrypted DLM-filtered snapshot snap-000f7e5c9f820db42 of the current root disk, initiated at 21:26:47 Lagos on 14 November.
- Another custom-baseline OS patch Install on 15 November: missing/failed/pending-reboot zero; seven alarms OK; foundational GuardDuty enabled.

## Evidence recovered from the earlier folder

- Synthetic GuardDuty finding message received in the inbox.
- Separate EC2-status ALARM and OK emails received in the inbox.
- Central Identity Center operator MFA enrollment shown (one device).
- Restricted operator shell/exit and termination dry-run denial recorded.

## Open sign-off items

1. The website-content ALARM/OK inbox pair; EC2-status inbox captures prove a different alarm.
2. Identity Center MFA enforcement/protected-login evidence, and workload-root MFA evidence if required. Central account 071770169654 differs from workload account 312660809284.
3. Updated AWS Budgets recipient verification; earlier screenshots show 0/1 verified.
4. The complete regional recurring-cost review. Historical base pricing is not an all-service quote.
5. An actual isolated second-account deployment, if required by the assessment.
6. Confirmed final GitHub push and executed CI, if claimed. Only an inactive workflow example is included.

Later observations are needed for seven-day retention deletion, production certificate renewal/reload and continuing unattended operation. The newly completed automatic snapshot has not itself been restore-tested. The earlier recovery drill used the manual snapshot.

## Time and scope

All friendly operating times use Africa/Lagos (UTC+1). AWS source timestamps are preserved. Synthetic findings and requested alarm transitions are labelled as tests. Historical records are retained in the separate private handover; current status takes precedence. No AWS deployment, destructive drill or new Terraform plan was executed while preparing this release.
