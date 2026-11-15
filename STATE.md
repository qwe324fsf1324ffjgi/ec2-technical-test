# Terraform state

The active backend is private, versioned S3 with AES256 server-side encryption, an HTTPS-only bucket policy, bucket-owner enforcement and native S3 lockfiles. State migration and a no-change plan were observed. Local old state backups are historical, not the live source of truth.

Existing local `backend.s3.hcl` is account-specific and excluded from this package/Git. It was already used for migration. Do not rerun migration for normal daily work. On a new checkout of this same deployment, first restore its correct backend settings, then initialize:

```powershell
$env:AWS_PROFILE = 'ec2-test'
terraform init "-backend-config=backend.s3.hcl"
terraform state list
terraform plan -no-color
```

Confirm account, bucket, key, region and existing state before applying. Never initialize a different account against this deployment's backend. The provider's allowed-account check does not substitute for checking the backend account and state key.

`state-storage.tf` manages the state bucket and uses prevent_destroy. A normal full destroy is therefore blocked. Do not remove this protection while destroying the active backend. See DEPLOYMENT.md for new-account bootstrap and CLEANUP.md for teardown. No state/credential bytes belong in source control.

To investigate damaged state, preserve its current S3 version and lock status, compare historical versions and reconcile actual AWS resources before a deliberate restore. Do not blindly overwrite newer state or force-unlock a live operation. S3 state versioning protects Terraform records, not website content.

Reference: https://developer.hashicorp.com/terraform/language/backend/s3
