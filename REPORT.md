# EC2 technical test - GitHub edition

Zerah Abba | 15 November 2026

## 01 / DELIVERY - What was built

A small public website with a complete operating record.

### The service

The project runs a static Nginx website on an Amazon Linux 2023 ARM64 EC2 instance in Stockholm. Terraform defines the network, server, retained public address, access roles, schedules, backup policy, patching, audit trail and monitoring. The public endpoint is https://16.192.190.65/. The separate /healthz path returns a predictable response for the external checker.

### What makes the result convincing

The evidence follows the same instance through recovery, health checks and scheduled operation. A deliberate cross-AZ replacement retained the Elastic IP. File-corruption recovery was checked against SHA256 baselines. The current machine then stopped at the scheduled evening time and started the next morning under the Scheduler role. A completed policy-created backup and the following morning's patch installation were captured separately.

### How to read this handover

The report explains the design and observed results. The acceptance record maps each claim to a file. The offline gallery preserves the earlier reviewer view, including captions and scope notes. Selected captures are included here; private originals and terminal transcripts remain in the separate full handover. Terraform and application source are included in their original directory layout.

### Evidence boundary

This is a handover based on supplied source, screenshots, AWS output and session records dated 13-15 November 2026. Preparation of this release did not log in to AWS, execute Terraform or repeat the destructive drills. Current direct captures, historical test records, configuration and unverified items are labelled separately.

| Record | Value |
| --- | --- |
| Workload account | 312660809284 |
| Region | eu-north-1 / Stockholm |
| Current server | i-0d341cc5ce8fd20a7 / eu-north-1b |
| Operating hours | 07:00-19:00 / Africa/Lagos |
| Evidence cut-off | 15 November 2026 |

## 02 / TOPOLOGY - One server. A separate recovery destination.

The design supports restoration across Availability Zones; it does not run an active standby.

### Traffic path

Visitors reach the retained Elastic IP through the internet gateway and public route table. Both subnets use that route table. The primary subnet is in eu-north-1a; the recovery subnet is in eu-north-1b. Only one subnet normally hosts the website instance. The current server is in the recovery subnet after the recorded drill.

### Operating plane

A server IAM role supports Systems Manager. The human operator connects through a separate assumed role and the selected logged session document. EventBridge Scheduler calls StartInstances and StopInstances. Patch Manager runs the installation association. Data Lifecycle Manager snapshots the tagged EBS root disk.

### Observation plane

CloudTrail records management actions and stores logs in a separate audit bucket. GuardDuty analyses foundational security signals. A scheduled Lambda function checks trusted HTTPS, /healthz and page hashes. CloudWatch alarms route state changes to SNS. An EventBridge rule routes qualifying GuardDuty findings to the operations topic.

### Why the distinction matters

A second subnet and a recovery image make a replacement possible. They do not make this website highly available. There is no load balancer, autoscaling group or second continuously serving instance in the reviewed source. An instance or AZ failure requires operator-led recovery and can interrupt service.

## 03 / PUBLIC SERVICE - The web and network boundary

HTTP is available for certificate validation and redirection; the website is served over HTTPS.

### Network configuration

The VPC uses 10.42.0.0/16. Primary and recovery subnets use 10.42.10.0/24 and 10.42.20.0/24. Subnets do not automatically assign public IP addresses. The separate Elastic IP supplies the stable endpoint. The security group permits inbound TCP 80 and 443 from IPv4 clients. No inbound port 22 rule is present.

### Outbound access

The reviewed security group permits outbound TCP 80 and 443 to any IPv4 destination. These ports support repository downloads, AWS APIs, Systems Manager and certificate operations. This restricts destination ports; it is not a destination allowlist. The host and managed-service configuration form additional parts of the access boundary.

### Web configuration

Nginx serves the static HTML/CSS site and the health path. The supplied server configuration redirects regular HTTP requests to HTTPS and includes content-security, frame, content-type and referrer protections. The monitor checks expected bytes as well as response status, so a page that still returns HTTP 200 can be detected when its content changes.

### Source and observed result

network.tf defines the VPC, subnets, gateway, routes and security-group rules. compute.tf defines the machine, encrypted root storage and metadata settings. server/ contains the bootstrap and Nginx configuration. Historical service checks and the latest website screenshot support the running application result; the 15 November status JSON reports system, instance and attached-EBS checks OK.

| Record | Value |
| --- | --- |
| VPC | vpc-048ac0bb3aa5d73a5 |
| Security group | sg-0de6db7cee00e05f2 |
| Primary subnet | subnet-05902f65bafe9fd98 |
| Recovery subnet | subnet-013777548f762aa30 |
| Retained address | 16.192.190.65 |

## 04 / ACCESS - Separate deployment and daily access

A restricted AWS role narrows daily operations while the bootstrap path remains powerful.

### The two profiles

ec2-test obtains temporary credentials through a credential process that exports the default profile session. The correct refresh command for this setup is aws login --profile default. Running aws sso login --profile ec2-test fails because this profile does not carry the required SSO configuration. The deployment identity is the EC2TechnicalTestBootstrap role in workload account 312660809284.

### Daily operator scope

ec2-test-operator assumes the Terraform-managed operator role. Its supplied policy permits start/stop for the managed instance, the selected SSM session document, session management and selected read APIs. A logged shell and clean exit were recorded after the policy fix. An EC2 termination dry run was denied. This proves that tested denial, rather than every possible permission boundary.

### Inside the machine

The SSM shell uses ssm-user with sudo. This is trusted server-administrator access. It is not an unprivileged application account. CloudWatch session transcripts record commands, output, caller identity and target through the tested session flow. The source does not demonstrate equivalent content logging for arbitrary SSH or port-forward sessions.

### MFA and account scope

Earlier screenshots show one MFA device enrolled for the enabled zerah-technical-test Identity Center user. Enrollment does not prove enforcement or a recent MFA-protected login. Identity Center and a root-MFA dashboard are shown in central account 071770169654, not the workload account. Those captures cannot establish workload-account root MFA. The separate AdministratorAccess bootstrap path remains available.

| Record | Value |
| --- | --- |
| Session log group | /ec2-test/ssm-sessions |
| Retention | 30 days |
| Session limits | 20-minute idle / 60-minute maximum |
| Observed operator role | ec2-test-operator-ae994221b6530214561233eafb |

## 05 / BACKUP - The first unattended backup is recorded

The enabled policy is now supported by a completed snapshot of the current root disk.

### Policy and selection

backups.tf defines an enabled EBS snapshot policy, policy-0b52adace8f128c61. It selects volumes tagged Project=ec2-technical-test, initiates daily backups from 20:00 UTC and uses age-based seven-day retention. Its execution role uses the DLM service principal and AWS-managed lifecycle permissions, with source-account and source-ARN conditions in the trust policy.

### What happened overnight

The 15 November verification filtered snapshots by the current root volume and the aws:dlm:lifecycle-policy-id system tag. It returned snap-000f7e5c9f820db42 in completed state, encrypted, for vol-0331a7c76186f6e18. Its recorded start is 14 November 2026 at 20:26:47.068 UTC, or 21:26:47.068 in Lagos. The evidence closes the earlier automatic-backup execution gap.

### What the new result does not prove

The record proves this completed policy-selected backup. It does not prove seven-day deletion has already happened or that every future backup will succeed. This new snapshot has not itself been restored in the supplied evidence. Earlier recovery tests used the manual snapshot snap-0248cc99d2eaa7aed. Keep those two backup histories distinct.

### Operational use

Before recovery, inspect a completed known-good snapshot, its volume, age and expected content. A daily policy targets roughly one day of data-loss exposure only when recent usable backups exist. Keep the manual recovery image and its snapshot until they are deliberately retired. They are outside the automatic policy's retention management.

| Record | Value |
| --- | --- |
| Automatic snapshot | snap-000f7e5c9f820db42 |
| Source disk | vol-0331a7c76186f6e18 |
| State / encryption | completed / true |
| Evidence | evidence/verification-20261115/dlm-root-snapshots.json |

## 06 / RECOVERY - Two different recovery drills

The tests establish controlled restoration of the server and its content.

### Cross-AZ replacement

The original instance, i-089b289452aa69694 in eu-north-1a, was deliberately replaced from the manual snapshot-backed image ami-0d5ea418134c2b9ce. The replacement, i-0d341cc5ce8fd20a7, runs in eu-north-1b. The Elastic IP stayed 16.192.190.65. Session records report SSM access, expected file hashes and accepted HTTPS after replacement; /healthz returned 200 and ok at 09:14:09 UTC on 14 November.

### File-corruption restoration

The operator deliberately altered index.html, identified the mismatch and restored the file from a read-only snapshot-backed disk. The record at 09:31:05 UTC reports the restored disk file and HTTPS page matching the baseline. The temporary restore volume vol-011a927c75c4a7674 was subsequently unmounted and removed. The separate later monitoring drill exercised detection and notification recovery.

### Current recovery settings

The supplied live variables selected use_recovery_image=true, deployment_site="recovery" and enable_corruption_drill=false. Preserve these on the operating laptop. Resetting them to a fresh-account example can propose a replacement. The submission excludes actual local tfvars, backend settings, state and saved plans, so it must not overwrite or substitute for the initialized working folder.

### Test limits

The exercise was not an actual AWS AZ outage, an unplanned EC2 hardware failure or a measured zero-downtime failover. Exact outage duration was not captured. There is no guaranteed recovery-time objective. RECOVERY.md explains the operator decisions, plan review, volume identification, read-only mounting and post-restore checks required for a real incident.

| Record | Value |
| --- | --- |
| Manual recovery snapshot | snap-0248cc99d2eaa7aed |
| Recovery image | ami-0d5ea418134c2b9ce |
| index.html SHA256 | a04b5cb854eedb6a26216b30c2a01004ff8b7ece3410d4d6fd470bba2a52f6a9 |
| style.css SHA256 | 413164dd07e9d0d3edd90eb0e4bbea365815302da4d33004c14e22173e099f8a |

## 07 / OPERATING HOURS - The evening stop and morning start

CloudTrail links the scheduled time, target instance and automation identity.

### Configured hours

website-start uses cron(0 7 * * ? *); website-stop uses cron(0 19 * * ? *). Both are enabled, use Africa/Lagos and have flexible time windows OFF. Both target i-0d341cc5ce8fd20a7 through the EC2 SDK integration. The targets use the project Scheduler role, a failure queue and a bounded retry policy.

### Observed shutdown

On 14 November, CloudTrail recorded StopInstances at 18:00:30 UTC / 19:00:30 Lagos. The event targets the current instance and identifies ec2-test-scheduler-bf5f87ef53e6815ea9b5bed874 as the session issuer. No errorCode is present. The earlier stopped-state screenshot supplies the resulting EC2 state.

### Observed startup

On 15 November, CloudTrail recorded StartInstances at 06:00:23 UTC / 07:00:23 Lagos, for the same instance and Scheduler role, without a reported error. A subsequent status capture reports running and OK system, instance and attached-EBS checks. The browser screenshot shows the website loading afterward. These captures distinguish the accepted start call from the later healthy server/application result.

### Evidence handling

Public copies of the CloudTrail lookup responses remain in evidence/morning-start-20261115-103523/. Access-key identifier fields are redacted; PUBLIC-EVIDENCE.md documents the changes. The private handover retains the unmodified records. The start response also includes a prior-day event for the old instance; do not confuse that row with the current machine. An event ID lets an authorized reviewer locate the corresponding AWS event. A local file hash protects package comparison, but does not independently authenticate an AWS event.

| Record | Value |
| --- | --- |
| Stop event ID | 3cc10a9f-c315-4f2f-b34c-c21f319a0d54 |
| Start event ID | 0de9dace-302b-47a1-8a01-e65a1d0c3f9b |
| Local time conversion | UTC + 01:00 |
| Website checker window | 07:05 to before 19:00 Lagos |

## 08 / MAINTENANCE - Patching and certificate care

Today's patch result extends the original manual verification with another daily installation.

### OS patch installation

The custom baseline pb-078e511dd3f341434 is registered to patch group ec2-technical-test. The daily association uses AWS-RunPatchBaseline Install at 08:00 UTC / 09:00 Lagos, with RebootIfNeeded. The 15 November state reports Install from 09:00:40 to 09:01:34 Lagos. MissingCount, FailedCount, InstalledPendingRebootCount and all reported noncompliance counts are zero.

### Interpret the counters carefully

The result is scoped to the reported OS baseline and operation. It does not establish application dependency maintenance or successful future installations. Two unsupported/not-reported counters in the response are -1; they must not be presented as measured zero values. The recorded InstalledCount is 505.

### TLS provisioning and renewal

The bootstrap installs Nginx and Certbot in a separate Python environment, obtains the IP certificate and installs the HTTPS configuration. A systemd renewal service calls certbot renew with a deploy hook to reload Nginx. The recorded dry run passed. Historical certificate evidence gives expiry as 20 November 2026 at 04:42:34 UTC; this is a capture-time value, not a new live expiry check.

### What still needs observation

A renewal dry run and scheduled timer are useful evidence, but they do not prove a later unattended production renewal and Nginx reload have occurred. The external checker raises certificate risk at 24 hours or less remaining during its operating window. Certbot's separate Python environment is outside the reported OS patch-compliance result.

| Record | Value |
| --- | --- |
| Patch association | 3927abcd-c087-47e9-9dd5-ac717fc0c383 |
| Latest Install end | 15 Nov 2026 / 09:01:34 Lagos |
| Missing / failed / reboot | 0 / 0 / 0 |
| Evidence | evidence/verification-20261115/patch-state.json |

## 09 / MONITORING - Measure the page, not just the process

A successful Lambda invocation is different from a healthy website.

### External checks

The monitor establishes trusted TLS, checks certificate lifetime, requests /healthz and compares the returned HTML/CSS SHA256 hashes with expected values. It rejects unexpected status/redirects and responses exceeding 1 MiB. A healthy active invocation reports WebsiteFailure=0 and CertificateRisk=0. A function can run successfully while reporting WebsiteFailure=1.

### Operating window

The handler requests the website only from 07:05 to before 19:00 Lagos, allowing a startup interval. Outside those hours it publishes zero failure metrics and a note that it is outside the operating window. These off-hours values are intentional heartbeat behaviour; they cannot establish nighttime website availability.

### Controlled content-change test

The supplied records show deliberate content alteration, WebsiteFailure=1, an alarm action at 14:33:47 UTC, restoration around 14:36 UTC and a recovery action at 14:38:47 UTC on 14 November. The healthy monitor output after restoration is retained. This tests content-integrity detection and the alarm action path, rather than an EC2 hardware failure.

### Notification evidence

Recovered inbox screenshots establish the synthetic GuardDuty message and separate EC2-status ALARM/OK messages reached the recipient. Those images do not cover the website-content ALARM/OK pair. CloudWatch action history supports SNS publication for the website alarm; actual inbox receipt of that specific pair remains open. All seven alarm states in the 15 November capture are OK.

| Record | Value |
| --- | --- |
| Foundation alarms | Instance status; sustained CPU; scheduler failures; security routing; SNS delivery failures |
| Website alarms | Website failure; certificate risk |
| Website rule | Five-minute scheduled Lambda invocation |
| Retained evidence | proof/ and evidence/verification-20261115/website-alarm-history.json |

## 10 / AUDIT & THREATS - Actions, sessions and security signals

The evidence separates management-event records, shell transcripts and synthetic threat tests.

### Management events

The multi-region CloudTrail configuration includes read/write management events and global service events. It enables log-file integrity validation and writes to a private versioned audit bucket with SSE-S3 and HTTPS-only access. The historical validation record reports 5/5 digest files and 49/49 log files valid through 14:15:08 UTC on 14 November. Its stated range does not validate later logs automatically.

### Interactive shell evidence

The tested SSM session flow streams commands and output to /ec2-test/ssm-sessions with 30-day retention. A transcript at 14:46:30 UTC on 14 November records SESSION-AUDIT-TEST, time, caller and target. CloudTrail covers session API activity; the CloudWatch transcript is the separate evidence of actual shell content.

### Threat detection

The regional GuardDuty detector remains enabled in the latest check. Foundational CloudTrail, DNS and flow-log sources are enabled; optional protection features shown in the response are disabled. The sample Backdoor:EC2/DenialOfService.Tcp finding exercised routing. Its synthetic resource identity is not the live website instance and it does not indicate a real attack occurred.

### Retention and authority

Audit current objects have a 90-day expiration policy and noncurrent versions a seven-day policy, subject to lifecycle behaviour. Versioning and encryption are useful controls but do not make logs immutable or protected from all privileged deletion. Identity Center policy, workload root MFA and the separate bootstrap administrator path require their own account-level evidence.

| Record | Value |
| --- | --- |
| Audit bucket | ec2-test-audit-312660809284-eu-north-1 |
| Trail name | ec2-technical-test |
| Detector | 3959ebba59e6486d9bbb72fa6bcb227c |
| Sample severity route | EventBridge selects findings with severity >= 4 |

## 11 / COST & LIFECYCLE - A budget threshold is not a cost ceiling

The historical base estimate is useful context; it is not the complete bill.

### Measured base

The earlier Stockholm estimate used 31 days, 12 compute hours per day, a retained IPv4 address and an 8 GiB gp3 disk. It reported USD 3.20 compute, USD 3.72 IPv4 and USD 0.67 disk, for USD 7.59 before tax, transfer and other services. These are historical measured assumptions from 13 November, not a refreshed price quote.

### Costs outside that base

The deployed stack also includes custom metrics, seven alarms, Lambda, logs, GuardDuty, EBS snapshots, S3 state/audit objects and requests, notifications and event scheduling. Backups, retained IP/storage and some monitoring components continue to cost money while EC2 is stopped. The separate manual snapshot remains until deliberately cleaned up.

### Budget delivery gap

The Terraform budget is a USD 10 monthly alert threshold. Earlier screenshots show a budget recipient verification count of 0/1. A confirmed SNS subscription does not confirm an AWS Budgets recipient. A second similarly named budget is also visible; its origin was not established. Refresh recipient verification before claiming budget-email delivery.

### Shutdown and cleanup

CLEANUP.md provides a controlled teardown sequence. Inspect Terraform's plan before applying any removal, preserve required audit/backup records and check retained manual images, snapshots, EIPs and buckets separately. Do not treat the existence of a cleanup guide as evidence that resources have been removed. No deployment or teardown was performed for this handover.

| Record | Value |
| --- | --- |
| Historical base | USD 7.59 / 31-day assumption |
| Budget threshold | USD 10 / month |
| Full regional bill | Not yet measured or fully quoted |
| Working estimate source | COSTS.md and Get-BaseCost.ps1 |

## 12 / REPLICATION - Reproducible source, with a clear deployment boundary

The project can be prepared for another account; a second deployment has not been demonstrated.

### Portable inputs

The package includes the reviewed .tf source, provider lockfile, tfvars/backend examples, server configuration, static site, monitor source and build script. DEPLOYMENT.md describes an isolated backend bootstrap and new-account sequence. Actual operating-laptop tfvars, backend configuration, Terraform state, saved plans and provider binaries are excluded from this release.

### Account-specific adaptation

Use the target account identity, region, naming, alert destination and trusted operator role. Do not reuse the original state bucket or state key for an independent deployment. The recovery AMI and snapshot IDs in the current inventory belong to the original account/region. Existing account-managed GuardDuty or SSM settings can need import or adaptation rather than duplicate creation.

### Build and review

A fresh checkout must build the missing monitor ZIP using Build-Monitor.ps1 and initialize its own backend. Review fresh Terraform validation and planning output before apply. Rebuilding the Lambda archive can alter its hash even if Python source is unchanged. An initialized live folder must keep its actual configuration and generated artifacts.

### Delivery claims

The earlier record identifies a GitHub destination, qwe324fsf1324ffjgi/ec2-technical-test, but a successful final push was not established in the supplied evidence. The CI file is an inactive example; no executed GitHub validation or deployment pipeline is demonstrated. The handover supports review and reproduction without claiming those separate delivery actions happened.

| Record | Value |
| --- | --- |
| Terraform source | 34 runtime/lockfile assets verified against the uploaded project |
| Source changes in this release | None |
| Second-account execution | Not demonstrated |
| CI execution | Not demonstrated |

## 13 / EVIDENCE - Keep the claim beside its source

The package preserves original captures and labels extracted results.

### Selected evidence retained

This repository includes the 32 selected gallery images, captions and numbered callouts from the earlier folder. It also includes selected inbox/browser proof and the new website capture. All 59 original screenshot files, earlier raw transcripts and duplicate captures remain preserved in the separate complete handover; they are not included in this GitHub edition.

### Today's additions

The morning-start folder includes public copies of start/stop lookup responses, both Scheduler configurations, instance-status JSON, start summary and the website screenshot. Five verification JSON extracts cover alarms, patch state, GuardDuty, DLM root snapshots and website alarm history. The accompanying provenance note explains their origin in the uploaded PowerShell session.

### Original versus derived

Access-key identifiers have been redacted from the public CloudTrail copies; timestamps, event IDs, instance target and role identity remain. Filenames containing original refer to their source-capture lineage, rather than promising unmodified public bytes. Extracted verification JSON is formatted from the supplied transcript; it is not a new AWS fetch. The unmodified source records remain in the private handover.

### Publication and integrity

This edition excludes private evidence originals, state, real tfvars/backend settings, plans, provider binaries and local backups. Assessment account/resource identifiers remain so the evidence chain can be followed. SHA256SUMS.txt supports file comparison after extraction. It is not a digital signature or proof that the AWS account remains unchanged. See PUBLIC-EVIDENCE.md for the exact publication boundary.

| Record | Value |
| --- | --- |
| GitHub entry point | README.md |
| Local gallery | evidence-guide/index.html |
| Current acceptance | ACCEPTANCE.md |
| Publication scope | PUBLIC-EVIDENCE.md |
| Upload steps | PUBLISHING.md |

## 14 / SIGN-OFF - What remains, and how to demonstrate the result

The remaining gaps are specific. They do not require repeating the recovery drills.

### Complete the evidence gaps

Capture website-content ALARM and OK messages in the recipient inbox. Show the Identity Center MFA policy and an actual protected login; identify workload-root MFA separately if it is in scope. Refresh AWS Budgets recipient verification and the full regional cost review. Execute and verify the isolated second-account deployment if the assessor requires a live reproduction.

### Keep future behaviour separate

Seven-day backup deletion, later certificate renewal/reload and long-term unattended operation need later observations. Today's completed snapshot and patch installation are actual results, but they cannot guarantee future runs. Before a live demonstration, refresh relevant status and the certificate expiry without bypassing certificate validation.

### A focused reviewer walkthrough

Open the landing page during Lagos operating hours. Show the current instance and all three health checks. Compare the evening stop and morning start event IDs, caller role and target. Show the DLM-created completed snapshot. Open the patch-state record and alarm states. Then walk through the recovery source, baseline hashes, cutover record and controlled corruption result.

### Safe presentation

Use the retained evidence outside operating hours. Do not start the server merely to make an off-hours screenshot look healthy, trigger a new destructive drill for presentation, or apply an old saved plan. Demonstrate the restricted shell and its transcript only when needed. This release records the operating system and its limits; the remaining sign-off should be backed by new evidence, not stronger wording.

| Record | Value |
| --- | --- |
| Closed in this update | Overnight automatic backup; current-instance start/stop cycle; fresh patch/health/alarm captures |
| Previously recovered | GuardDuty inbox receipt; EC2-status ALARM/OK inbox receipt; MFA enrollment |
| Still open | Website-content inbox pair; MFA enforcement/account scope; Budgets recipient; full cost; second-account run |

