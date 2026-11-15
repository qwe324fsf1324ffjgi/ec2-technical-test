resource "aws_iam_role" "disk_backups" {
  name_prefix = "ec2-test-backups-"
  description = "Allows Data Lifecycle Manager to manage disk snapshots"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dlm.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.expected_account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:dlm:${var.aws_region}:${var.expected_account_id}:policy/*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "disk_backups" {
  role       = aws_iam_role.disk_backups.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

resource "aws_dlm_lifecycle_policy" "disk_backups" {
  description        = "Daily project disk snapshots retained for seven days"
  execution_role_arn = aws_iam_role.disk_backups.arn
  state              = "ENABLED"

  policy_details {
    policy_type    = "EBS_SNAPSHOT_MANAGEMENT"
    resource_types = ["VOLUME"]

    # Use one project-specific tag: multiple DLM target tags are OR-matched.
    target_tags = {
      Project = "ec2-technical-test"
    }

    schedule {
      name      = "daily-seven-days"
      copy_tags = true

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["20:00"]
      }

      retain_rule {
        interval      = 7
        interval_unit = "DAYS"
      }

      tags_to_add = {
        BackupPolicy = "ec2-test-daily"
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.disk_backups
  ]
}

output "disk_backup_policy_id" {
  description = "Daily EBS snapshot lifecycle policy"
  value       = aws_dlm_lifecycle_policy.disk_backups.id
}