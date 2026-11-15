
## Checkpoint: 14 November 2026

### Project
AWS EC2 technical test. Infrastructure managed with Terraform.
Account: 312660809284
Region: eu-north-1
AWS CLI profile: ec2-test
Login source: default profile, technical-test bootstrap role.
Refresh an expired login with: aws login --profile default
Confirm the proposed identity belongs to account 312660809284.

### Verified today
- Existing project folder located; existing infrastructure retained.
- Instance i-089b289452aa69694 is running in eu-north-1a.
- Public IP: 16.192.190.65
- Systems Manager reports Online; agent version 3.3.5828.0.
- Landing page loads in Chrome without a visible certificate warning.
- https://16.192.190.65/healthz displays ok in Chrome.

### Unresolved
- Windows curl failed with CRYPT_E_REVOCATION_OFFLINE.
- No certificate-validation bypass was used.
- An initial AWS endpoint connection failed; retry succeeded.

### Next action
Open a Systems Manager terminal session. Inspect bootstrap, Nginx,
certificate expiry and renewal timers. Verify renewal afterwards.

### Remaining acceptance work
- Verify secure operator access and record session activity.
- Verify HTTPS, renewal, and HTTP redirect.
- Verify daily stop/start at 19:00/07:00 Africa/Lagos.
- Implement and test backups and versioned website releases.
- Demonstrate EC2 failure, AZ failure, and corruption recovery.
- Implement ongoing OS patching and verify compliance.
- Implement monitoring, audit logging, and threat detection.
- Complete cost estimate, account replication, and cleanup instructions.
- Maintain requirement-to-implementation and verification records.

### Working rules
Give one step at a time and wait for the result.
Never treat saved plans or old state backups as current AWS state.
Keep credentials, tfvars, state files, and saved plans out of Git.
Record actual test results; distinguish pending work from completed work.

## Verification update: 14 November 2026

### Passed
- Interactive Systems Manager session opened and closed successfully.
- Bootstrap service completed successfully.
- Nginx is running; its startup configuration check passed.
- Certificate covers 16.192.190.65.
- Certificate expiry: 20 November 2026, 04:42:34 UTC.
- Renewal and operating-hours timers are scheduled and have run.
- Certbot renewal dry run succeeded.
- Linux curl accepted the HTTPS certificate without bypass options.
- HTTPS /healthz returned HTTP 200 and body "ok".
- Response includes CSP, frame, content-type and referrer protections.
- HTTP / returned 301 with Location: https://16.192.190.65/

### Still pending
- Actual scheduled shutdown/startup and renewal reload verification.
- Windows certificate revocation connectivity issue.
- Nginx types_hash warning: nonfatal; cleanup pending.
- Backups, recovery drills, ongoing patching, monitoring,
  audit logging, threat detection and restricted operator access.

### Next action
Run a fresh Terraform plan against the remote state.
Review differences before applying any changes.
Never apply an old saved plan.

Configuration update: added ignore_changes for aws_instance.website.associate_public_ip_address only. Launch setting remains false. Original compute.tf saved at .local-backups\compute-20261114-094008.tf.bak. AWS unchanged; validation and fresh plan pending.

Verification: terraform validate passed; fresh terraform plan reported no changes after the narrow public-IP lifecycle correction. No apply or server replacement was performed.

Schedule verification: both schedules enabled, Africa/Lagos, correct instance target. CloudTrail shows scheduler-role StopInstances at 2026-11-13T18:00:30Z and StartInstances at 2026-11-14T06:00:23Z, with no errorCode. Current server is running.

Backup configuration prepared and validated: backups.tf defines a DLM service role and daily EBS snapshots targeting Project=ec2-technical-test, at 20:00 UTC with seven-day retention. Not deployed. Snapshot creation and restore tests remain pending.

Backup policy policy-0b52adace8f128c61 verified ENABLED with daily 20:00 UTC schedule and seven-day retention. Encrypted project disk confirmed. Manual recovery-test snapshot requested: snap-0248cc99d2eaa7aed. Completion and restore pending. This manual snapshot needs separate cleanup; DLM retention does not manage it.

Recovery preparation: source website SHA256 hashes saved in evidence/website-baseline.csv. These describe local source files; comparison with live and restored files is pending. Initial snapshot snap-0248cc99d2eaa7aed remains pending at the last check. No recovery test has passed yet.

Initial snapshot snap-0248cc99d2eaa7aed confirmed completed by AWS waiter. Restore and file-integrity verification remain pending.

Recovery image configuration prepared and validated in recovery-image.tf. Selected completed snapshot snap-0248cc99d2eaa7aed in local terraform.tfvars. Boot settings match source: arm64, UEFI, HVM, ENA, /dev/xvda. Image registration not deployed; running server unchanged; recovery tests pending.

Recovery image ami-0d5ea418134c2b9ce verified available, private and encrypted, backed by snap-0248cc99d2eaa7aed. Added recovery-mode.tf and conditional AMI/user-data selection in compute.tf. Recovery mode defaults to false. Recovery startup preserves snapshot content rather than rewriting it from local website files. Validation passed. No AWS changes made; restore test pending.

Recovery cutover prepared: terraform.tfvars now selects use_recovery_image=true and deployment_site=recovery. Intended destination eu-north-1b using snapshot-backed image ami-0d5ea418134c2b9ce. AWS cutover NOT applied. Next: review recovery-cutover.tfplan before execution. Future plans will retain these recovery settings.

Recovery drill started at 2026-11-14T09:09:15.2921312Z. Applying reviewed recovery-cutover.tfplan: replace original server with snapshot-restored server in eu-north-1b; retain Elastic IP. This is a controlled cross-AZ recovery drill, not an actual AWS AZ outage. Service restoration and integrity checks pending.

## Cross-AZ restore verification: 14 November 2026

Result: PASSED for this controlled recovery drill.
Original instance: i-089b289452aa69694, eu-north-1a.
Restored instance: i-0d341cc5ce8fd20a7, eu-north-1b.
Snapshot: snap-0248cc99d2eaa7aed.
Recovery image: ami-0d5ea418134c2b9ce.
Retained public IP: 16.192.190.65.

Verified:
- Restored instance running in eu-north-1b.
- Systems Manager Online; interactive session succeeded.
- Restored index.html and style.css hashes match evidence/website-baseline.csv.
- HTTPS certificate accepted by Linux curl without bypass.
- /healthz returned HTTP 200 and "ok" at 09:14:09 UTC.
- Security headers present.

Scope: deliberate replacement and snapshot restore across Availability Zones.
This was not an actual AWS AZ outage or an unplanned instance failure.
Exact outage duration was not measured.

Current configuration: use_recovery_image=true; deployment_site="recovery".
Keep these settings when resuming; changing them can replace the server.

Next: test recovery from deliberate website-file corruption.
Still pending: automated backup execution, patching, monitoring,
audit logging, threat detection, restricted operator access,
account replication and final operating documentation.

Corruption drill prepared: recovery-drill.tf defines a temporary encrypted disk restored from the selected snapshot and attached to the current server. enable_corruption_drill=true. Disk has a separate Project tag to exclude it from daily project backups. Not deployed. Live website unchanged. Unmount before setting the drill to false and applying cleanup.

Corruption recovery PASSED at 2026-11-14T09:31:05Z: deliberate index.html alteration detected by hash and HTTPS response; restored from snapshot-backed disk; restored file and HTTPS page matched baseline. Temporary volume vol-011a927c75c4a7674 unmounted successfully. enable_corruption_drill=false now set; AWS disk removal pending.

Corruption-drill cleanup completed: Terraform removed only temporary volume vol-011a927c75c4a7674 and its attachment. Live server and backup remain. enable_corruption_drill=false. Next: configure and verify automatic OS patching.

OS patching prepared and validated: patching.tf defines an AL2023 baseline approving all classifications with nonsecurity updates and zero-day approval delay, patch-group registration, and daily AWS-RunPatchBaseline Install association at 08:00 UTC / 09:00 Africa/Lagos with RebootIfNeeded. Instance PatchGroup tag added to compute.tf. Association configured not to execute immediately on creation. Not deployed; first execution, compliance and post-patch website checks pending. Certbot's separate Python environment is outside OS patching.

Patching deployed: baseline pb-078e511dd3f341434; association 3927abcd-c087-47e9-9dd5-ac717fc0c383; current instance i-0d341cc5ce8fd20a7. Requesting first patch execution with RebootIfNeeded. Completion, compliance and website checks pending.

Patch verification: initial Install used AWS default baseline because its patch group was empty. A later Scan completed at 2026-11-14T10:59:32+01:00 using project baseline pb-078e511dd3f341434 and patch group ec2-technical-test, with Missing=0, Failed=0 and PendingReboot=0. Delayed tag discovery is consistent with observations but not independently proven. Requesting another daily-association execution to verify Install against the project baseline.

OS patch installation verified: association execution e2a77550-795c-4e35-b527-7c592bd4a88e and command cd2cce5f-36e7-4c28-b26d-01df1e0abdeb succeeded. Install completed 2026-11-14T11:03:33+01:00 using baseline pb-078e511dd3f341434 and patch group ec2-technical-test. Missing=0, Failed=0, PendingReboot=0. Post-patch website check pending. No CloudTrail trails or Stockholm GuardDuty detectors found during inspection.

Post-patch landing page visually verified in Chrome. Audit configuration prepared and validated in audit.tf: multi-region read/write management events, global service events, log-integrity validation, private versioned SSE-S3 bucket, HTTPS-only access, trail-specific delivery policy, current-object expiration after 90 days and noncurrent-version expiration after seven days. No paid data events, Insights or CloudTrail Lake configured. Not deployed; delivery and integrity verification pending.

CloudTrail deployed and reports Logging=True with no delivery errors; only zero-byte folder markers observed so far. Event delivery and digest validation pending. GuardDuty configuration prepared in threat-detection.tf with enable=false so available optional plans can be inspected before enabling monitoring. Not deployed.

GuardDuty detector 3959ebba59e6486d9bbb72fa6bcb227c verified DISABLED. Inspected actual feature settings. Prepared guardduty-features.tf to disable nine optional plans and automatic runtime-agent management. RDS child settings are inactive when their parent RDS protection plan is disabled. Detector remains paused; feature changes not applied.

GuardDuty optional plans verified DISABLED; foundational CLOUD_TRAIL, DNS_LOGS and FLOW_LOGS configured. Prepared enable=true in threat-detection.tf. Activation not applied; monitoring and alert-delivery tests pending.

Activation-plan review found AWS-reported RDS_DATA_RISK=DISABLED missing from explicit child settings. Added it under RDS_LOGIN_EVENTS to preserve the disabled setting. Regenerating guardduty-enable.tfplan; activation remains unapplied.

GuardDuty activation blocked by provider rejecting explicit RDS_DATA_RISK configuration. No AWS changes applied. Removed unsupported child configuration. RDS protection now has a separate Terraform address with a moved block preserving its existing state; status remains DISABLED. Only its additional_configuration is ignored. Other optional-plan controls remain enforced. Generating a new activation plan.

GuardDuty ENABLED verified with foundational sources enabled and all nine optional plans disabled. Prepared alerts.tf: SNS email subscription using alert_email, EventBridge rule for GuardDuty severity >=4, summary-only notifications, HTTPS-only topic access and retry settings. Not deployed. Email confirmation and sample-finding delivery test pending.

Alert deployment partially completed: SNS topic, email subscription request and EventBridge rule created. SNS topic policy failed with action-out-of-service-scope; notification target pending. Replaced both sns:* action entries with explicit supported topic actions. Generating a fresh plan for remaining resources; do not reuse alerts.tfplan.

Alert resources deployed and SNS email subscription confirmed. Requested one synthetic GuardDuty finding: Backdoor:EC2/DenialOfService.Tcp. End-to-end email delivery verification pending.

CloudTrail validation retry succeeded for 1/1 initial digest, covering 2026-11-14T10:15:00Z to 10:15:08Z. No event-log files were reported as validated. Later digest and log-file validation remain pending. Output saved in evidence/cloudtrail-validation.txt.

Security alert test: SNS recorded one message published at 2026-11-14T11:59:00+01:00 and one notification delivered at 12:00:00+01:00, with zero reported failures for that interval. This supports service-side delivery after the sample finding. Recipient inbox receipt remains unconfirmed. Next: operational monitoring and alarms.

Prepared monitoring.tf with five operational alarms: EC2 status, sustained CPU, scheduler failure queue, EventBridge security routing failures and SNS delivery failures. Alarm and recovery actions use operations SNS topic. Missing data does not trigger these alarms, accommodating scheduled shutdown. Website availability, certificate expiry, disk space and monitoring of unexpected stops are not covered by these five alarms. Not deployed or tested.

Five foundation alarms verified OK with actions enabled and correct SNS alarm/recovery targets. Requested synthetic ALARM transition for ec2-test-instance-status to test notification routing. This does not simulate an actual EC2 status-check failure. Notification action and automatic return to OK remain to verify.

Synthetic instance-status alarm test: CloudWatch confirmed successful SNS action at 2026-11-14T12:44:25+01:00. Automatic return to OK subsequently observed. Human email receipt remains unconfirmed.

Prepared monitor/handler.py and .local-backups/website-monitor.zip. Checker verifies trusted HTTPS, /healthz, index/CSS hashes and certificate remaining lifetime; flags certificates with <=24 hours remaining. Website requests active 07:05-19:00 Africa/Lagos; outside that window it reports zero failure metrics. Offline logic checks passed using simulated responses for schedule boundaries, corruption, expiry and invalid TLS. No AWS deployment yet. Rebuild package after source edits using Compress-Archive.

Website monitor manually invoked successfully: active=true, WebsiteFailure=0, CertificateRisk=0; HTTPS and content checks passed. Result saved in evidence/website-monitor-result.json. Scheduled execution and controlled failure detection remain pending.

Website monitor recurring execution observed at five-minute intervals from 14:11:51Z through 14:26:51Z on 2026-11-14. All reported active=true, WebsiteFailure=0 and CertificateRisk=0. Both monitor alarms verified OK. Controlled failure detection test pending.

Website monitoring drill passed: changed content detected, alarm SNS action succeeded at 14:33:47 UTC, original page restored at 14:36 UTC, external checks passed, both alarms returned to OK, and recovery SNS action succeeded at 14:38:47 UTC on 2026-11-14. Human email receipt unconfirmed. CloudTrail validation retry was blocked by endpoint connectivity.

CloudTrail validation command completed successfully. Counts and coverage are recorded in evidence/cloudtrail-validation.txt.

Session audit logging deployed and verified at 2026-11-14T14:46:30Z. CloudWatch group /ec2-test/ssm-sessions captured interactive commands, output, operator ARN, target instance and session ID. Retention: 30 days. CloudTrail integrity verification passed for 5/5 digests and 49/49 log files through 14:15:08Z.

Terraform verification after session logging: no changes; deployed infrastructure matches configuration. IAM Identity Center list-instances returned no visible instances in eu-north-1. Restricted operator access remains pending.

Restricted operator role verified: ec2-test-operator successfully opened and exited logged SSM session zerah-operator-tqj9ufzp8nd6ex7uc87bl7ajne. Bootstrap administrator access remains available separately.

Final documentation installed 2026-11-14T16:35:45.5765189+01:00. Runtime source matched review and was not overwritten. Operator shell/exit and denied EC2 termination dry run verified. Automatic DLM backup, inbox receipt, MFA, full cost and second-account acceptance remain documented pending items.


## Evidence update: 15 November 2026

The uploaded CloudTrail records show the current instance stopped under the Scheduler role at 2026-11-14T18:00:30Z and started under that role at 2026-11-15T06:00:23Z. Both records have no errorCode. The enabled schedules use Africa/Lagos with flexible windows OFF. Current instance/system/attached-EBS checks are all OK.

The subsequent Verify-Deployment.ps1 transcript shows seven alarms OK; the custom patch-baseline Install on 15 November completed 09:01:34 Lagos with MissingCount=0, FailedCount=0 and InstalledPendingRebootCount=0; foundational GuardDuty remains enabled. Its DLM-filtered result identifies completed encrypted snapshot snap-000f7e5c9f820db42 of current root vol-0331a7c76186f6e18, started 14 November 21:26:47.068 Lagos. Request failures: 0.

Earlier recovered screenshot evidence confirms receipt of the synthetic GuardDuty alert and the separate EC2-status ALARM/OK messages. Website-content ALARM/OK inbox receipt remains open. Central Identity Center MFA enrollment is visible, but enforced protected login and workload-account root MFA are not established. Actual second-account deployment, full recurring-cost verification and the latest Budgets recipient verification remain open.

This release merges the previous recreated project folder, all 59 original screenshots and 32 selected gallery images, the uploaded runtime source and today's raw/evaluated evidence. Source files are unchanged. Documentation preparation did not execute any AWS changes or a new Terraform plan.
