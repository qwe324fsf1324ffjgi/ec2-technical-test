resource "aws_cloudwatch_log_group" "website_monitor" {
  name              = "/aws/lambda/ec2-test-website-monitor"
  retention_in_days = 14
}

resource "aws_iam_role" "website_monitor" {
  name_prefix = "ec2-test-monitor-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "website_monitor" {
  name = "publish-monitor-results"
  role = aws_iam_role.website_monitor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "cloudwatch:PutMetricData"
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "EC2TechnicalTest"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.website_monitor.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "website_monitor" {
  function_name = "ec2-test-website-monitor"
  description   = "Check website TLS, health and content during operating hours"
  role          = aws_iam_role.website_monitor.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "handler.lambda_handler"
  memory_size   = 128
  timeout       = 60

  filename         = "${path.module}/.local-backups/website-monitor.zip"
  source_code_hash = filebase64sha256("${path.module}/.local-backups/website-monitor.zip")

  environment {
    variables = {
      WEBSITE_IP   = aws_eip.website.public_ip
      INDEX_SHA256 = filesha256("${path.module}/website/index.html")
      STYLE_SHA256 = filesha256("${path.module}/website/style.css")
    }
  }

  depends_on = [aws_iam_role_policy.website_monitor]
}

resource "aws_cloudwatch_event_rule" "website_monitor" {
  name                = "ec2-test-website-monitor"
  description         = "Run the website checker every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_lambda_permission" "website_monitor" {
  statement_id  = "AllowProjectMonitorSchedule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.website_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.website_monitor.arn
}

resource "aws_cloudwatch_event_target" "website_monitor" {
  rule      = aws_cloudwatch_event_rule.website_monitor.name
  target_id = "website-checker"
  arn       = aws_lambda_function.website_monitor.arn

  retry_policy {
    maximum_event_age_in_seconds = 300
    maximum_retry_attempts       = 2
  }

  depends_on = [aws_lambda_permission.website_monitor]
}

resource "aws_cloudwatch_metric_alarm" "website_monitor" {
  for_each = {
    website-failure = {
      metric      = "WebsiteFailure"
      description = "HTTPS, health or website content check failed, or checker metrics are missing"
    }
    certificate-risk = {
      metric      = "CertificateRisk"
      description = "TLS certificate validation failed, expiry is within 24 hours, or checker metrics are missing"
    }
  }

  alarm_name          = "ec2-test-${each.key}"
  alarm_description   = each.value.description
  namespace           = "EC2TechnicalTest"
  metric_name         = each.value.metric
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    Monitor = "website"
  }

  alarm_actions = [aws_sns_topic.operations.arn]
  ok_actions    = [aws_sns_topic.operations.arn]

  depends_on = [aws_sns_topic_policy.operations]
}

output "website_monitor_function" {
  description = "Scheduled website-checking function"
  value       = aws_lambda_function.website_monitor.function_name
}
