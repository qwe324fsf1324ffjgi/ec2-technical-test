> Release update - 15 November 2026: see STATUS.md and ACCEPTANCE.md for the latest evidence. This technical/historical guide retains its original scope. Automatic backup execution is now observed; GuardDuty and EC2-status inbox messages are evidenced. Remaining MFA, website-content inbox and cost claims are scoped in STATUS.md.

# Commands and where they run

## Windows PowerShell in the original project

```powershell
$env:AWS_PROFILE = 'ec2-test'
aws sts get-caller-identity --profile ec2-test --no-cli-pager
terraform validate -no-color
terraform plan -no-color
.\Collect-Proof.ps1
```

Read outputs and any proposed changes. A plan alone does not apply changes. Collect-Proof.ps1 performs AWS reads and writes evidence files locally. API reads can appear in CloudTrail and incur service API usage. See the script and its collection metadata for the exact commands.

```powershell
aws ssm start-session --profile ec2-test-operator --region eu-north-1 --document-name SSM-SessionManagerRunShell --target i-0d341cc5ce8fd20a7
```

Use current terraform outputs after any instance replacement. The daily shutdown can end sessions after 19:00 Lagos.

## Inside the SSM shell

Run the read-only observations in HOST-CHECKS.txt. Capture actual output with the UTC time and instance/session context. Exit returns to PowerShell.

## Fresh account only

Follow DEPLOYMENT.md in a clean directory. Set a new account/region/AMI and isolated backend. Build the missing monitor ZIP with Build-Monitor.ps1. Do not copy the example over the existing production tfvars. Account replication and recovery are separate procedures.

## Recovery and cleanup

RECOVERY.md describes snapshot selection, plan review, replacement and post-restore verification. CLEANUP.md describes preservation of audit/state records before teardown. Destructive commands should be tied to a reviewed specific plan and an actual intended drill or teardown.

## Screenshot evidence

Use evidence-guide/index.html for annotated source views. Original screenshot files and original uploaded text are retained in the separate private evidence archive. Terminal excerpts in proof/ are labeled as excerpts. A screenshot of a saved transcript should be labeled as such.
