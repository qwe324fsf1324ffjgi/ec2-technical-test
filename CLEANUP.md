# Controlled cleanup

Routine EC2 stop is not full cleanup: retained IPv4, disks, snapshots, logs and security services can continue billing. The operator role cannot terminate the instance; deployment credentials are needed for infrastructure teardown.

## Temporary test artifacts

The snapshot-backed restore disk vol-011a927c75c4a7674 and attachment were already deleted after unmount. Keep enable_corruption_drill=false. The monitor marker was restored and healthy HTTPS verified. To clean its retained copy, first verify the live baseline hash and that the transient restore service is not running; stop its timer before removing `/srv/ec2-test/.monitor-drill-index.html`. Do not delete a copy still needed by a running restore job.

Synthetic GuardDuty findings are tests, not evidence of compromise. If desired, archive confirmed sample findings after preserving test evidence; do not indiscriminately archive real findings. Keep original evidence outside a public repository.

## Full teardown

1. Decide which evidence, audit records, source, certificates and backups must be retained and where. Deletion is permanent once all recoverable copies are removed.
2. Confirm the exact account/backend/state and save a protected state copy. Coordinate with other operators; no Terraform operation may be running.
3. Migrate this deployment's remote state to a deliberately selected protected local backend before removing its S3 backend infrastructure. In a controlled maintenance directory, replace the S3 backend block with a local backend and use init -migrate-state, inspecting copy direction. Verify the local state contains the complete resources before any deletion.
4. Audit bucket force_destroy=false and nonempty versioned buckets will block deletion. Explicitly decide to retain/export the logs or delete all required object versions/delete markers through an approved separate process. Do not enable force_destroy merely to bypass a retention decision.
5. The state bucket has prevent_destroy=true. Only after it is no longer the active backend and required backups are protected should its lifecycle guard be deliberately changed for teardown.
6. Generate and review a saved destroy plan. Confirm all resources, EIP release, detector/alarms/schedules, IAM roles, snapshots and buckets against the intended scope. Apply only after the owner authorizes the specific reviewed teardown. No teardown is performed by this handover.
7. The manual initial snapshot was created outside Terraform. Inventory it separately. Deregister recovery AMIs before deleting snapshots they reference, and verify whether provider AMI snapshot-management settings retain/delete snapshots. Do not rely on DLM to remove manual snapshots.
8. Verify no unintended residual volumes, allocated IPv4 addresses, snapshots, log storage, bucket versions or enabled detectors remain. Confirm final billing later. AWS-managed service-linked roles may remain; do not delete shared roles without checking other workloads.

Avoid broad account-wide delete scripts. Audit logs/state and manual backups are intentionally guarded and require a separate retention decision.
