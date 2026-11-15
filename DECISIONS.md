# Design decisions and practical consequences

| Choice | Reason | Consequence to explain |
| --- | --- | --- |
| One t4g.micro | A small static page has a modest workload and the brief permits recovery downtime | Recovery requires intervention; no active standby |
| Two AZ subnets | Supply a placement destination if the original AZ is unavailable | A second subnet alone does not provide failover |
| Retained EIP | Keep the IP-based website/certificate endpoint consistent through replacement | Public IPv4 continues billing overnight |
| Nginx/static files | Simple serving stack with a small application surface | Content updates need a deliberate release and baseline change |
| Root-disk snapshots | Preserve content, certificates and service configuration together | Restored packages/certificates may be old and need maintenance |
| Dedicated recovery user data | Preserve the snapshot content during a restore | Source edits alone do not update the restored site |
| Read-only XFS restore mount | Inspect and restore backup files while protecting the recovery copy | NVMe identity and duplicate XFS UUID require careful device selection |
| SSM plus temporary credentials | Auditable shell access without an inbound SSH rule | SSM and internet connectivity are dependencies |
| Separate operator profile | Limit routine AWS actions to the server and logged shell | Bootstrap admin remains powerful; server shell has sudo |
| Scheduler direct EC2 target | Start/stop at the specified Lagos times using an AWS service integration | Keep the target current after replacement |
| External Lambda hash checks | Detect incorrect served content even if the static health path returns ok | Expected source hashes must match the intended live release |
| OS baseline with immediate approval | Keep available AL2023 baseline patches installed daily | Installation may reboot the single host |
| CloudTrail plus shell logs | Capture both management API activity and interactive shell commands | These record different layers of activity |
| GuardDuty foundational sources | Analyse account/network threat signals with limited optional-service scope | Enabled detection is distinct from a real incident test |
| Versioned remote Terraform state | Shared resource mapping, recovery of prior state versions and lock protection | State is sensitive and must stay out of Git |
| Inactive CI/CD example | Document the proposed validation path requested for the assessment | No workflow is activated or deployment credentials configured |

The operating window appears in Scheduler, local enforcement and the monitor. Change and verify all three together. A daily backup policy suggests a recovery-point target, but the latest usable completed snapshot determines actual data-loss exposure. Record measured recovery time in future drills before quoting an RTO.
