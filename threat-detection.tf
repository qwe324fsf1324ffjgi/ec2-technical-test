resource "aws_guardduty_detector" "security" {
  # Foundational monitoring enabled; optional plans managed separately.
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

output "guardduty_detector_id" {
  description = "Stockholm GuardDuty detector"
  value       = aws_guardduty_detector.security.id
}