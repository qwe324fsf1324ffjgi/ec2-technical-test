resource "aws_cloudwatch_log_group" "sessions" {
  name              = "/ec2-test/ssm-sessions"
  retention_in_days = 30
}

resource "aws_iam_role_policy" "session_logging" {
  name = "session-audit-logs"
  role = aws_iam_role.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:DescribeLogGroups"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.sessions.arn,
          "${aws_cloudwatch_log_group.sessions.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_ssm_document" "session_preferences" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Record interactive shell sessions in CloudWatch Logs"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.sessions.name
      cloudWatchEncryptionEnabled = false
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = "20"
      maxSessionDuration          = "60"
    }
  })

  depends_on = [aws_iam_role_policy.session_logging]
}