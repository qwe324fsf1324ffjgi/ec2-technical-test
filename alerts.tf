resource "aws_sns_topic" "operations" {
  name = "ec2-test-operations"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.operations.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_policy" "operations" {
  arn = aws_sns_topic.operations.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccountOwnerAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${var.expected_account_id}:root"
        }
        Action = [
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:AddPermission",
          "sns:RemovePermission",
          "sns:DeleteTopic",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic",
          "sns:Publish"
        ]
        Resource = aws_sns_topic.operations.arn
      },
      {
        Sid    = "EventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.operations.arn
      },
      {
        Sid    = "ProjectAlarmPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.operations.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.expected_account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:cloudwatch:${var.aws_region}:${var.expected_account_id}:alarm:ec2-test-*"
          }
        }
      },
      {
        Sid       = "RequireHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:AddPermission",
          "sns:RemovePermission",
          "sns:DeleteTopic",
          "sns:Subscribe",
          "sns:ListSubscriptionsByTopic",
          "sns:Publish"
        ]
        Resource = aws_sns_topic.operations.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "ec2-test-guardduty"
  description = "Notify on medium and higher severity GuardDuty findings"

  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    account       = [var.expected_account_id]
    detail = {
      severity = [{
        numeric = [">=", 4]
      }]
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_email" {
  rule      = aws_cloudwatch_event_rule.guardduty.name
  target_id = "operations-email"
  arn       = aws_sns_topic.operations.arn

  input_transformer {
    input_paths = {
      finding_type = "$.detail.type"
      finding_id   = "$.detail.id"
      severity     = "$.detail.severity"
      region       = "$.region"
    }

    input_template = <<-MESSAGE
      {"message":"GuardDuty finding: <finding_type>. Severity: <severity>. Region: <region>. Finding ID: <finding_id>. Review the finding in the AWS GuardDuty console."}
    MESSAGE
  }

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 10
  }

  depends_on = [aws_sns_topic_policy.operations]
}

output "operations_topic_arn" {
  description = "Operations and security notification topic"
  value       = aws_sns_topic.operations.arn
}