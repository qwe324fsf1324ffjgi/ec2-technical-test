locals {
  guardduty_optional_plans = toset([
    "S3_DATA_EVENTS",
    "EKS_AUDIT_LOGS",
    "EBS_MALWARE_PROTECTION",
    "AI_PROTECTION",
    "AI_ANALYST",
    "EKS_RUNTIME_MONITORING",
    "LAMBDA_NETWORK_LOGS",
    "RUNTIME_MONITORING"
  ])

  guardduty_agent_settings = {
    EKS_RUNTIME_MONITORING = [
      "EKS_ADDON_MANAGEMENT"
    ]
    RUNTIME_MONITORING = [
      "EKS_ADDON_MANAGEMENT",
      "ECS_FARGATE_AGENT_MANAGEMENT",
      "EC2_AGENT_MANAGEMENT"
    ]
  }
}

resource "aws_guardduty_detector_feature" "optional" {
  for_each = local.guardduty_optional_plans

  detector_id = aws_guardduty_detector.security.id
  name        = each.value
  status      = "DISABLED"

  dynamic "additional_configuration" {
    for_each = lookup(local.guardduty_agent_settings, each.value, [])

    content {
      name   = additional_configuration.value
      status = "DISABLED"
    }
  }
}

resource "aws_guardduty_detector_feature" "rds_disabled" {
  detector_id = aws_guardduty_detector.security.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "DISABLED"

  lifecycle {
    # This provider cannot configure the AWS-reported RDS_DATA_RISK child.
    # The parent protection plan remains explicitly disabled.
    ignore_changes = [additional_configuration]
  }
}

moved {
  from = aws_guardduty_detector_feature.optional["RDS_LOGIN_EVENTS"]
  to   = aws_guardduty_detector_feature.rds_disabled
}