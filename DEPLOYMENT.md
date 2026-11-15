# Deployment into a fresh account

This procedure is documented, not demonstrated in a second account. Start in a new directory with independent state and temporary credentials for the intended account. Do not copy the existing `.terraform/`, actual backend config, state, recovery IDs, operator trust ARN or tfvars into the new account.

## Prerequisites and account checks

Use AWS CLI v2 with the required login/session plugin capability, Terraform >=1.15.0 and <2, and the committed AWS provider lockfile. The supplied working deployment used AWS provider 6.60.0; do not run init -upgrade without reviewing the resulting plan. The region must support the selected AZs, t4g.micro and configured GuardDuty features, and the account must permit these services. Check budgets, existing regional GuardDuty detector and existing SSM-SessionManagerRunShell document before attempting resource creation; import/adapt existing managed resources instead of duplicating or overwriting them.

Authenticate using your organization's supported temporary-credential flow and configure a separate AWS profile. In the commands below, `ec2-test` means that new account's deliberately configured deployment profile. Always inspect sts account output before setting expected_account_id. The example values are placeholders.

```powershell
$env:AWS_PROFILE = 'ec2-test'
aws sts get-caller-identity --profile ec2-test --no-cli-pager
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
```

Edit account ID, region, email and regional AL2023 ARM64 AMI ID. A possible AWS-published current regional AMI lookup is:

```powershell
aws ssm get-parameter --profile ec2-test --region eu-north-1 --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64 --query Parameter.Value --output text --no-cli-pager
```

Verify returned image owner/architecture/boot configuration before pinning it. Fresh mode is deployment_site=primary, use_recovery_image=false, recovery_snapshot_id=null and enable_corruption_drill=false. Set operator_trusted_role_arn to the actual existing human login role ARN, or null to skip the optional operator role. Never substitute an STS assumed-role session ARN for the IAM role ARN.

## Build the monitor before Terraform validation

```powershell
.\Build-Monitor.ps1
```

The ZIP is generated locally under .local-backups and is not a source-control input. Keep handler.py at ZIP root. Terraform reads the ZIP hash during planning.

## Bootstrap isolated state

The backend bucket does not yet exist in a fresh account. In this fresh directory only, temporarily move backend.tf outside the directory or rename it to `backend.tf.disabled` so Terraform starts with local state. Use a new empty directory without backend initialization metadata.

```powershell
Rename-Item .\backend.tf backend.tf.disabled
terraform init
terraform validate -no-color
terraform plan -no-color '-out=fresh.tfplan'
```

Review the full fresh-account plan and costs, then apply the saved plan. This initially creates the stack and state bucket under local state. Preserve the local state securely until migration is verified. Bootstrap runs with local state, so do not run multiple operations concurrently.

```powershell
terraform apply -no-color fresh.tfplan
Copy-Item .\backend.s3.hcl.example .\backend.s3.hcl
```

Edit backend.s3.hcl with the newly created account-specific state bucket, account ID, region and unique key. Restore the backend block and migrate:

```powershell
Rename-Item .\backend.tf.disabled backend.tf
terraform init -migrate-state '-backend-config=backend.s3.hcl'
```

Accept copying local state only into the verified intended empty backend. Stop if asked to overwrite unexpected remote state. Verify state list, no-change plan, state-object encryption/version ID and release of the lock. Retain a protected pre-migration backup. Do not use the first account's backend or blindly use -reconfigure in place of migration.

## Staged activation and acceptance

Before a new account's first apply, temporarily set the new copy's GuardDuty detector enable=false. Create the detector with optional-plan resources, inspect that optional parent/agent features are disabled, then enable it in a reviewed second plan. This staged approach avoids relying on AWS default optional-feature activation. Do not make this edit in the already verified live project merely to rehearse these instructions. Existing detectors should be imported and inspected instead.

Confirm the SNS email subscription in the recipient inbox. Observe EC2 readiness, SSM Online, boot logs, trusted HTTPS and hashes before declaring success. Bootstrap may retry while EIP or permissions propagate. Configure the operator profile with the new output ARN and test shell access plus denied termination dry run. Verify the custom-baseline Scan/Install, snapshot creation, alarms, audit log delivery/integrity and scheduled start/stop with fresh evidence.

Creation success does not prove all integrations. Provider/region feature compatibility can change; the current RDS optional feature has a narrow additional_configuration ignore because provider 6.60.0 rejects AWS's reported RDS_DATA_RISK child. Preserve parent DISABLED and inspect AWS state after activation.

## Existing-account updates

Use the existing remote backend and local variables. Do not run the fresh-account bootstrap/renames. Save/review a new plan; old saved plans are not reusable release artifacts. Recovery-mode source changes need a deliberate content rollout and baseline update. Changing normal user-data can replace the instance. A GitHub push does not deploy anything by itself.
