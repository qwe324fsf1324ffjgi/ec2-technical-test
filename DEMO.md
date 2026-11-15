> Release update - 15 November 2026: see STATUS.md and ACCEPTANCE.md for the latest evidence. This technical/historical guide retains its original scope. Automatic backup execution is now observed; GuardDuty and EC2-status inbox messages are evidenced. Remaining MFA, website-content inbox and cost claims are scoped in STATUS.md.

# Five-minute reviewer walkthrough

1. Open the homepage and /healthz during operating hours. Explain that the monitor also compares both served files with SHA256 baselines. A static health path can stay healthy while the landing page is corrupted.
2. Open compute.tf, network.tf and schedule.tf. Trace the EIP to the one running instance. Two subnets provide another placement option. Scheduler directly calls EC2 start/stop, eliminating a scheduling Lambda. A local timer catches an out-of-hours manual start.
3. Open ACCESS.md and the session-audit policy. Demonstrate the restricted profile in a screen share. In the shell run id, systemctl is-active nginx and the SHA256 check in OPERATIONS.md, then exit. Keep credentials and private evidence off screen.
4. Open RECOVERY.md. If the instance disappears, first inspect state, the surviving EIP, latest completed known-good root snapshot and target AZ. Register/select that snapshot's AMI, choose a healthy subnet and plan replacement. During the observed drill the original instance was terminated, the replacement booted in eu-north-1b, and the same address served matching content. For a demonstration on the production test account, show the plan and recorded cutover evidence. A fresh isolated deployment can exercise destruction and recreation.
5. Show proof/ and VERIFICATION.md. Explain the initial default patch baseline, subsequent correct custom Install and the distinction between an enabled backup policy and an observed completed automatic backup.

## Questions to practice

**What is lost after a failure?** Changes since the latest usable snapshot. A missed daily run increases the exposure. Recovery duration depends on human action and boot time and was not measured.

**Why snapshot the root disk?** It contains site files, Nginx configuration, certificates and service units. Recovery user data preserves these files. Restored packages and certificates may need updates.

**Why use a retained IPv4 address?** The IP certificate and reviewer link depend on it. Reassociation preserved both during replacement. It continues to incur cost overnight.

**How would an assessor inspect it?** The live links, source and evidence are available directly. Use an owner-operated screen share for AWS console or SSM demonstration. The daily operator role includes start/stop and sudo-capable shell access. Keep its credentials with the operator.

**What does replication require?** Use a new account profile, isolated backend, regional AMI, new EIP/certificate and verified email subscription. Follow DEPLOYMENT.md. The demonstrated recovery was cross-AZ in one account.

## Pipeline design

See ci/terraform.yml.example for the proposed manual validation job. A future deployment stage would use protected environments, short-lived GitHub OIDC credentials scoped to the repository, reviewed Terraform plans and approval before apply. Deployment credentials and workflow activation are outside this submission.
