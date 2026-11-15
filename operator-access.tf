variable "operator_trusted_role_arn" {
  description = "Existing login role allowed to assume the daily operator role; null disables creation."
  type        = string
  default     = null
}

resource "aws_iam_role" "operator" {
  count                = var.operator_trusted_role_arn == null ? 0 : 1
  name_prefix          = "ec2-test-operator-"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = var.operator_trusted_role_arn }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "operator" {
  count = var.operator_trusted_role_arn == null ? 0 : 1
  name  = "daily-server-operations"
  role  = aws_iam_role.operator[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = aws_instance.website.arn
      },
      {
        Effect   = "Allow"
        Action   = "ssm:StartSession"
        Resource = aws_instance.website.arn
        Condition = {
          BoolIfExists = { "ssm:SessionDocumentAccessCheck" = "true" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:StartSession", "ssm:GetDocument"]
        Resource = aws_ssm_document.session_preferences.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${var.expected_account_id}:session/*"
        Condition = {
          StringEquals = {
            "ssm:resourceTag/aws:ssmmessages:session-id" = "$${aws:userid}"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}

output "operator_role_arn" {
  value       = try(aws_iam_role.operator[0].arn, null)
  description = "Restricted daily operator role; deployment uses the separate bootstrap login."
}