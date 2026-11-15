# EC2 website: infrastructure, recovery and operations

Terraform-managed AWS infrastructure for a static HTTPS website, with scheduled operating hours, encrypted backups, tested recovery, OS patching, audit logging and external content monitoring.

**Owner:** Zerah Abba  
**Region:** Stockholm (`eu-north-1`)  
**Operating hours:** 07:00-19:00 Africa/Lagos (UTC+1)  
**Evidence updated:** 15 November 2026

[Detailed report](REPORT.pdf) · [Acceptance record](ACCEPTANCE.md) · [Screenshot evidence](evidence-guide/README.md) · [Current status](STATUS.md)

## Results at a glance

| Area | Recorded result |
| --- | --- |
| Scheduled shutdown | 14 November, 19:00:30 Lagos; Scheduler role; no reported error |
| Scheduled startup | 15 November, 07:00:23 Lagos; same instance and Scheduler role |
| Server health | Running; system, instance and attached-EBS checks OK |
| Automatic backup | Completed encrypted DLM snapshot of the current root disk |
| Daily OS installation | 15 November; missing, failed and pending-reboot counts all zero |
| Monitoring | Seven alarm states OK in the latest capture |
| Recovery | Controlled cross-AZ replacement and corrupt-file restoration recorded |
| Notification receipt | Synthetic GuardDuty and separate EC2-status ALARM/OK messages captured |

These are dated observations, not continuous availability guarantees. This is a single-server design with operator-led recovery, rather than an active standby service. See [ACCEPTANCE.md](ACCEPTANCE.md) for the evidence and limits of each result.

## Architecture

Visitors reach Nginx through a retained Elastic IP. The server normally runs in one of two public subnets, with the other AZ available as a recovery destination. Systems Manager supplies administration without inbound SSH. Scheduler controls start/stop. DLM snapshots the tagged EBS disk, and Patch Manager installs OS updates. CloudTrail records management actions; logged SSM sessions capture shell activity. GuardDuty findings and CloudWatch alarms route to SNS. A five-minute Lambda checks trusted HTTPS, the health path and HTML/CSS hashes during operating hours.

The deployed endpoint recorded in this project is https://16.192.190.65/. It is intentionally unavailable outside its scheduled hours and may change or be removed after the assessment.

## Repository guide

| Path | Contents |
| --- | --- |
| Root `*.tf` files | Network, EC2, roles, state storage, schedules, backups, patching, audit and monitoring |
| `.terraform.lock.hcl` | Provider dependency lockfile |
| `server/` | Bootstrap, systemd services/timers and Nginx templates |
| `website/` | Static HTML and CSS |
| `monitor/` | External HTTPS/content checker |
| `evidence/` | Curated schedule, health and verification records |
| `evidence-guide/` | 32 selected images with captions and an offline searchable gallery |
| `proof/` | Selected inbox/browser captures |
| `ci/terraform.yml.example` | Inactive validation workflow example |
| `REPORT.pdf` / `REPORT.md` | Detailed technical handover |
| `DEPLOYMENT.md` | Isolated fresh-account build and state migration |
| `RECOVERY.md` / `OPERATIONS.md` | Recovery and routine procedures |
| `PUBLISHING.md` | Uploading this folder to GitHub |

For a local entry page, open `START-HERE.html`. On GitHub, use this README and the Markdown screenshot guide; GitHub displays HTML source rather than running the gallery in the file viewer.

## Build or reproduce

Follow [DEPLOYMENT.md](DEPLOYMENT.md). Use a deliberately selected account, independent state backend and reviewed temporary-credential profile. Copy the example input files, fill in your own values and build the monitor ZIP with `Build-Monitor.ps1`. Never copy the original account's actual state, backend configuration or recovery IDs into a new account.

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
.\Build-Monitor.ps1
```

Do not run a bare `terraform init`/`apply` as a substitute for the documented fresh-backend bootstrap. No saved plan is a reusable deployment artifact. This repository does not contain the initialized operating-laptop configuration.

## What remains unverified

- Actual website-content ALARM/OK inbox receipt; the selected inbox pair covers the separate EC2-status alarm.
- MFA enforcement/protected login and workload-root account scope; central identity enrollment is evidenced.
- Updated AWS Budgets recipient verification and the full recurring-cost review.
- An actual second-account deployment.
- A completed final repository push and executed CI; packaging this folder does not establish either.
- Future retention deletion and production certificate renewal/reload.

The latest automatic snapshot has not itself been restored; the earlier restore drill used the separate manual snapshot. Read [STATUS.md](STATUS.md) before presenting the project as complete.

## Evidence and publication scope

This GitHub edition contains selected review evidence. Private originals and raw terminal archives are retained separately in the full handover package. Access-key identifiers have been redacted from public event records; timestamps, event IDs, target instance and Scheduler-role identity remain. These files still identify the assessment account and resources. No credentials, state, local backend settings, real tfvars, saved plans or Terraform provider binaries are included.

The earlier 59 original screenshots remain in the separate full handover; this repository includes 32 selected gallery images plus the newer website capture. Curated evidence is deliberately **not** ignored by `.gitignore`.
