# Recovery runbook

Use deployment credentials, not the daily operator role, for Terraform recovery. Preserve the correct backend and existing variables. Always inspect the saved plan. Keep source recovery snapshots and AMIs while they are needed; the manually created recovery snapshot is outside DLM retention.

## Instance or Availability Zone recovery

This is manual snapshot recovery of a single server. Choose a completed known-good root snapshot and confirm it contains the intended site/certificate configuration. Existing settings reference the tested initial snapshot and AMI. The current server is already in the recovery subnet; blindly setting deployment_site to recovery again will not replace it.

1. Confirm failure and affected AZ. Use `terraform output network_sites` to choose a working subnet. Do not replace a healthy server merely because a client connection failed.
2. Preserve and review current state/settings. Verify snapshot state, encryption, source disk and creation time. For a new snapshot, set recovery_snapshot_id to that completed snapshot, keep use_recovery_image=true, and select the working deployment_site in local tfvars.
3. Plan the replacement. Changing AMI or subnet generally replaces the server; a healthy in-place same-AZ instance that must be replaced can be explicitly selected with `-replace=aws_instance.website`. Use that option only after deciding replacement is necessary.
4. Review and apply the saved plan. Expect EIP association replacement and retargeting of Scheduler, patching, monitoring dimensions and operator permissions to the new instance. Do not approve unrelated destructive changes.
5. Verify EC2 checks, SSM Online, Nginx, trusted HTTPS, file hashes, current AZ and retained public IP. Compare the snapshot's age and certificate expiry; renew and patch as needed.
6. Record recovery timestamps and a measured outage duration for this incident. The controlled drill did not measure exact downtime.

Example plan commands, after deliberately editing local recovery settings:

```powershell
$env:AWS_PROFILE = 'ec2-test'
terraform validate -no-color
terraform plan -no-color '-out=recovery.tfplan'
# Inspect the plan before this separate apply:
terraform apply -no-color 'recovery.tfplan'
```

When using a new AMI/snapshot or another account, confirm arm64, UEFI, HVM, ENA and root device `/dev/xvda` match. Snapshot permissions and KMS access must be available in the target account/region. A regional snapshot and EIP are not cross-region disaster recovery. Registered backup AMIs should not be assumed bootable without a restore test.

## File corruption recovery

1. Identify which files are corrupt using known-good SHA256 values and live HTTPS content. Do not overwrite the recovery copy from the corrupt live path.
2. Set enable_corruption_drill=true and inspect/apply its plan to attach a temporary encrypted volume from the selected snapshot in the current instance AZ. Its separate Project tag excludes it from project DLM selection.
3. In SSM, use `lsblk -o NAME,SERIAL,SIZE,FSTYPE,MOUNTPOINTS` to match the output volume ID to its NVMe serial. NVMe numbering is not stable. Never format the volume or assume a device name from an earlier session.
4. For the tested XFS root partition, mount the identified partition with `-t xfs -o ro,nouuid` into an empty recovery directory. Verify source hashes before copying. A dirty XFS snapshot may need different recovery handling; if mounting fails, do not force modifications to the only recovery copy.
5. Stage known-good files on the live filesystem, preserve ownership/mode/SELinux context, replace atomically and verify hashes, HTTPS body, `/healthz` and monitor results. Avoid copying unrelated old configuration over a patched server.
6. Unmount and confirm no mount remains. Set enable_corruption_drill=false, inspect/apply cleanup that removes only the temporary attachment/disk. Do not force-detach a mounted filesystem.

The controlled file drill restored index.html from a snapshot-backed disk and matched both on-disk and HTTPS hashes. The separate monitor drill used a staged copy with a server-side restoration timer and proved detection/alert recovery. Neither is a test of an actual AWS AZ outage.

## Recovery objectives and limits

A daily completed backup targets roughly one day's data-loss exposure; the observed recovery point can be older if creation fails or a required snapshot is unavailable. DLM uses a scheduling window and snapshot completion is asynchronous. Recovery time is not measured or guaranteed; it depends on diagnosis, human action, snapshot/image availability, instance launch and service startup. A new account/region needs separately configured backups, keys, AMIs, state and certificates. See VERIFICATION.md for precisely observed evidence.
