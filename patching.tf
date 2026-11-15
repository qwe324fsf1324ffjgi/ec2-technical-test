resource "aws_ssm_patch_baseline" "website" {
  name             = "ec2-test-al2023-current"
  description      = "Approve available Amazon Linux 2023 OS updates without delay"
  operating_system = "AMAZON_LINUX_2023"

  approval_rule {
    approve_after_days  = 0
    enable_non_security = true

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["*"]
    }
  }
}

resource "aws_ssm_patch_group" "website" {
  baseline_id = aws_ssm_patch_baseline.website.id
  patch_group = "ec2-technical-test"
}

resource "aws_ssm_association" "daily_patches" {
  name                        = "AWS-RunPatchBaseline"
  association_name            = "ec2-test-daily-os-patches"
  schedule_expression         = "cron(0 8 ? * * *)"
  apply_only_at_cron_interval = true
  max_concurrency             = "1"
  max_errors                  = "0"
  compliance_severity         = "HIGH"
  sync_compliance             = "AUTO"

  parameters = {
    Operation    = "Install"
    RebootOption = "RebootIfNeeded"
  }

  targets {
    key    = "InstanceIds"
    values = [aws_instance.website.id]
  }

  depends_on = [
    aws_ssm_patch_group.website
  ]
}

output "patch_association_id" {
  description = "Daily OS patch installation association"
  value       = aws_ssm_association.daily_patches.association_id
}

output "patch_baseline_id" {
  description = "Project-specific Amazon Linux 2023 patch baseline"
  value       = aws_ssm_patch_baseline.website.id
}