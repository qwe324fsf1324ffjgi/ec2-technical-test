variable "enable_corruption_drill" {
  description = "Create a temporary snapshot-restored disk for file recovery testing."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_corruption_drill || var.recovery_snapshot_id != null
    error_message = "The recovery drill requires recovery_snapshot_id."
  }
}

resource "aws_ebs_volume" "restore_test" {
  count = var.enable_corruption_drill ? 1 : 0

  availability_zone = aws_instance.website.availability_zone
  snapshot_id       = var.recovery_snapshot_id
  type              = "gp3"
  encrypted         = true

  tags = {
    Name    = "ec2-test-temporary-restore"
    Project = "ec2-test-recovery-drill"
    Purpose = "Temporary file recovery test; remove after verification"
  }
}

resource "aws_volume_attachment" "restore_test" {
  count = var.enable_corruption_drill ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.restore_test[0].id
  instance_id = aws_instance.website.id

  force_detach = false
}

output "restore_test_volume_id" {
  description = "Temporary restore disk; unmount before disabling the drill."
  value       = try(aws_ebs_volume.restore_test[0].id, null)
}