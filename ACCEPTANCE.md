# Acceptance record - 15 November 2026

This map summarizes the supplied project requirements and observed work. The original assessment brief is not reproduced verbatim. Source configuration, historical tests and fresh service captures have different evidential scope.

| Area | Status | Result and limit | Evidence |
| --- | --- | --- | --- |
| Website and health | Observed | Trusted HTTPS and content checks in historical tests; latest browser screenshot and running/OK status. | evidence/morning-start-20261115-103523/instance-status.json; proof/website.png; evidence-guide/ |
| Daily scheduling | Observed | 14 Nov stop 19:00:30 and 15 Nov start 07:00:23 Lagos; same instance and Scheduler role; no reported errors. | evidence/morning-start-20261115-103523/StartInstances-original.json; StopInstances-original.json; website-start.json; website-stop.json |
| Automatic backup | Observed | Completed encrypted DLM-filtered snapshot snap-000f7e5c9f820db42 of current root vol-0331a7c76186f6e18; started 14 Nov 21:26:47 Lagos. | evidence/verification-20261115/dlm-root-snapshots.json; PROVENANCE.md |
| Cross-AZ recovery | Recorded test | Controlled snapshot-backed replacement from AZa to AZb, retained EIP, hashes and HTTPS checked. No measured outage duration. | evidence/recovery-cutover-apply.txt; SESSION-LOG.md; RECOVERY.md |
| File corruption recovery | Recorded test | Altered index restored from read-only snapshot-backed disk; hashes checked; temporary disk removed. | SESSION-LOG.md; evidence/website-baseline.csv; RECOVERY.md |
| OS patching | Observed | 15 Nov Install 09:00:40-09:01:34 Lagos; missing, failed and pending reboot 0. | evidence/verification-20261115/patch-state.json |
| Network and storage security | Configured + captured | Web-only inbound rules; encrypted root/backup configuration; IMDSv2 configured; selected console views retained. | network.tf; compute.tf; evidence-guide/README.md |
| Restricted operator | Recorded test | Assume role, logged shell and exit succeeded; termination dry run denied. Bootstrap administrator path remains. | ACCESS.md; SESSION-LOG.md; the separate private transcript archive |
| Management/session audit | Recorded test | CloudTrail 5/5 digests and 49/49 logs validated for stated interval; actual SSM transcript captured. | evidence/cloudtrail-validation.txt; session-audit.tf; the separate private transcript archive |
| GuardDuty | Observed + inbox | Foundational detector enabled; synthetic sample email visible. Not evidence of a real attack. | evidence/verification-20261115/guardduty.json; proof/guardduty-email.png |
| Operational alarms | Observed + inbox | All 7 states OK; separate synthetic EC2-status ALARM/OK received. | evidence/verification-20261115/alarms.json; proof/status-alarm-email.png; proof/status-recovery-email.png |
| Website content monitoring | Observed action; inbox open | Content mismatch detected and recovered; SNS alarm/recovery actions succeeded. Specific website ALARM/OK inbox pair not captured. | evidence/website-monitor-corruption.json; evidence/website-monitor-recovery.json; evidence/verification-20261115/website-alarm-history.json |
| MFA | Enrollment captured; enforcement open | Central identity has an enrolled MFA device. Protected-login enforcement and workload-account root MFA remain separate unverified claims. | evidence-guide/images/capture-191045.png; capture-191126.png; STATUS.md |
| Budget and total cost | Partial | USD 10 threshold; earlier Budgets recipient 0/1 verified; historical USD 7.59 base excludes additional services. | COSTS.md; evidence-guide/images/capture-190702.png |
| Account replication | Documented; not executed | New-account source and procedure supplied; no actual second-account deployment evidenced. | DEPLOYMENT.md; terraform.tfvars.example; backend.s3.hcl.example |
| GitHub and CI | Unconfirmed / inactive example | Destination previously identified; final push and executed workflow not evidenced. | ci/terraform.yml.example; STATUS.md |
| Future retention/renewal | Needs later observation | Seven-day backup expiry and future production certificate renewal/reload are not yet demonstrated. | RECOVERY.md; OPERATIONS.md; server/ec2-test-renew.service |

The DLM and other 15 November verification JSON files are readable extracts from an uploaded transcript; see their PROVENANCE.md. This package was assembled offline and does not certify current live AWS state.
