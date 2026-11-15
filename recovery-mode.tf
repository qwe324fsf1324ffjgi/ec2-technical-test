variable "use_recovery_image" {
  description = "Restore the server from the configured backup image instead of a fresh Amazon Linux image."
  type        = bool
  default     = false

  validation {
    condition     = !var.use_recovery_image || var.recovery_snapshot_id != null
    error_message = "Recovery mode requires recovery_snapshot_id."
  }
}

locals {
  # Preserve restored content, certificates and service configuration.
  recovery_user_data = "#cloud-config\n${yamlencode({
    runcmd = [
      ["systemctl", "disable", "--now", "sshd.service"],
      ["systemctl", "mask", "sshd.service"],
      ["systemctl", "enable", "--now", "amazon-ssm-agent.service"],
      ["systemctl", "enable", "--now", "nginx.service"],
      ["systemctl", "enable", "--now", "ec2-test-renew.timer", "ec2-test-hours.timer"]
    ]
  })}"
}