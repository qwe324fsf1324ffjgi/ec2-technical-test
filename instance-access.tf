data "aws_partition" "current" {}

resource "aws_iam_role" "website" {
  name_prefix = "ec2-test-server-"
  description = "Service permissions for the technical test EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.website.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "website" {
  name_prefix = "ec2-test-server-"
  role        = aws_iam_role.website.name
}

output "website_instance_profile" {
  description = "Instance profile to attach to the EC2 website server."
  value       = aws_iam_instance_profile.website.name
}
