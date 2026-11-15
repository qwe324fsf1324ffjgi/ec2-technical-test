resource "aws_scheduler_schedule_group" "website" {
  name = "ec2-test"
}

resource "aws_sqs_queue" "schedule_failures" {
  name                      = "ec2-test-schedule-failures"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_iam_role" "scheduler" {
  name_prefix = "ec2-test-scheduler-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.expected_account_id
        }
        ArnEquals = {
          "aws:SourceArn" = aws_scheduler_schedule_group.website.arn
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "scheduler" {
  name = "start-stop-website"
  role = aws_iam_role.scheduler.id

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
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.schedule_failures.arn
      }
    ]
  })
}

resource "aws_scheduler_schedule" "website" {
  for_each = {
    start = { hour = 7, action = "startInstances" }
    stop  = { hour = 19, action = "stopInstances" }
  }

  name                         = "website-${each.key}"
  group_name                   = aws_scheduler_schedule_group.website.name
  schedule_expression          = "cron(0 ${each.value.hour} * * ? *)"
  schedule_expression_timezone = "Africa/Lagos"
  state                        = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:${data.aws_partition.current.partition}:scheduler:::aws-sdk:ec2:${each.value.action}"
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ InstanceIds = [aws_instance.website.id] })

    retry_policy {
      maximum_event_age_in_seconds = 900
      maximum_retry_attempts       = 3
    }

    dead_letter_config {
      arn = aws_sqs_queue.schedule_failures.arn
    }
  }

  depends_on = [aws_iam_role_policy.scheduler]
}
