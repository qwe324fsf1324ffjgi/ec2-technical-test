variable "recovery_snapshot_id" {
  description = "Completed root-disk snapshot in this account and region; null disables recovery-image registration."
  type        = string
  default     = null

  validation {
    condition = var.recovery_snapshot_id == null ? true : can(
      regex("^snap-[0-9a-f]{17}$", var.recovery_snapshot_id)
    )
    error_message = "Use a snapshot ID such as snap-0123456789abcdef0, or null."
  }
}

resource "aws_ami" "recovery" {
  count = var.recovery_snapshot_id == null ? 0 : 1

  name                = "ec2-test-recovery-${var.recovery_snapshot_id}"
  description         = "Private recovery image registered from a project disk backup"
  architecture        = "arm64"
  boot_mode           = "uefi"
  virtualization_type = "hvm"
  ena_support         = true
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name           = "/dev/xvda"
    snapshot_id           = var.recovery_snapshot_id
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name   = "ec2-test-recovery"
    Source = var.recovery_snapshot_id
  }
}

output "recovery_image_id" {
  description = "Private bootable recovery image; null when not configured"
  value       = try(aws_ami.recovery[0].id, null)
}