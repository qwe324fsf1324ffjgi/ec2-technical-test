locals {
  foundation_alarms = {
    instance-status = {
      description = "EC2 status checks failed for two consecutive minutes"
      namespace   = "AWS/EC2"
      metric      = "StatusCheckFailed"
      statistic   = "Maximum"
      period      = 60
      evaluations = 2
      threshold   = 1
      dimensions  = { InstanceId = aws_instance.website.id }
    }
    sustained-cpu = {
      description = "CPU utilization at or above 80 percent for fifteen minutes"
      namespace   = "AWS/EC2"
      metric      = "CPUUtilization"
      statistic   = "Average"
      period      = 300
      evaluations = 3
      threshold   = 80
      dimensions  = { InstanceId = aws_instance.website.id }
    }
    scheduler-failures = {
      description = "A failed scheduling event is waiting in the failure queue"
      namespace   = "AWS/SQS"
      metric      = "ApproximateNumberOfMessagesVisible"
      statistic   = "Maximum"
      period      = 300
      evaluations = 1
      threshold   = 1
      dimensions  = { QueueName = aws_sqs_queue.schedule_failures.name }
    }
    security-routing-failures = {
      description = "EventBridge failed to deliver a GuardDuty finding to SNS"
      namespace   = "AWS/Events"
      metric      = "FailedInvocations"
      statistic   = "Sum"
      period      = 300
      evaluations = 1
      threshold   = 1
      dimensions  = { RuleName = aws_cloudwatch_event_rule.guardduty.name }
    }
    notification-failures = {
      description = "SNS reported a failed operations notification delivery"
      namespace   = "AWS/SNS"
      metric      = "NumberOfNotificationsFailed"
      statistic   = "Sum"
      period      = 300
      evaluations = 1
      threshold   = 1
      dimensions  = { TopicName = aws_sns_topic.operations.name }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "foundation" {
  for_each = local.foundation_alarms

  alarm_name          = "ec2-test-${each.key}"
  alarm_description   = each.value.description
  namespace           = each.value.namespace
  metric_name         = each.value.metric
  statistic           = each.value.statistic
  period              = each.value.period
  evaluation_periods  = each.value.evaluations
  datapoints_to_alarm = each.value.evaluations
  threshold           = each.value.threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  dimensions          = each.value.dimensions

  # Scheduled overnight shutdown produces no EC2 metric data.
  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.operations.arn]
  ok_actions    = [aws_sns_topic.operations.arn]

  depends_on = [aws_sns_topic_policy.operations]
}

output "foundation_alarm_names" {
  description = "Operational alarms for the server and notification pipeline"
  value = [
    for alarm in aws_cloudwatch_metric_alarm.foundation : alarm.alarm_name
  ]
}