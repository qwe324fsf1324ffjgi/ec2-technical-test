variable "server_ami_id" {
  description = "Pinned Amazon Linux 2023 ARM64 image ID for the selected region."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.server_ami_id))
    error_message = "Enter the regional Amazon Linux 2023 ARM64 AMI ID."
  }
}

variable "deployment_site" {
  description = "Subnet used by the single server: primary or recovery."
  type        = string
  default     = "primary"

  validation {
    condition     = contains(["primary", "recovery"], var.deployment_site)
    error_message = "Choose primary or recovery."
  }
}

data "aws_ami" "server" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.server_ami_id]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  server_files = [
    {
      path        = "/usr/local/sbin/ec2-test-bootstrap"
      permissions = "0700"
      content = templatefile("${path.module}/server/bootstrap.sh.tftpl", {
        public_ip    = aws_eip.website.public_ip
        email_base64 = base64encode(var.alert_email)
      })
    },
    {
      path        = "/etc/ec2-test/nginx-bootstrap.conf"
      permissions = "0644"
      content     = file("${path.module}/server/nginx-bootstrap.conf")
    },
    {
      path        = "/etc/ec2-test/nginx-https.conf"
      permissions = "0644"
      content = templatefile("${path.module}/server/nginx-https.conf.tftpl", {
        public_ip = aws_eip.website.public_ip
      })
    },
    {
      path        = "/srv/ec2-test/site/index.html"
      permissions = "0644"
      content     = file("${path.module}/website/index.html")
    },
    {
      path        = "/srv/ec2-test/site/style.css"
      permissions = "0644"
      content     = file("${path.module}/website/style.css")
    },
    {
      path        = "/etc/systemd/system/ec2-test-bootstrap.service"
      permissions = "0644"
      content     = file("${path.module}/server/ec2-test-bootstrap.service")
    },
    {
      path        = "/etc/systemd/system/ec2-test-renew.service"
      permissions = "0644"
      content     = file("${path.module}/server/ec2-test-renew.service")
    },
    {
      path        = "/etc/systemd/system/ec2-test-renew.timer"
      permissions = "0644"
      content     = file("${path.module}/server/ec2-test-renew.timer")
    },
    {
      path        = "/usr/local/sbin/ec2-test-enforce-hours"
      permissions = "0700"
      content     = file("${path.module}/server/enforce-hours.sh")
    },
    {
      path        = "/etc/systemd/system/ec2-test-hours.service"
      permissions = "0644"
      content     = file("${path.module}/server/ec2-test-hours.service")
    },
    {
      path        = "/etc/systemd/system/ec2-test-hours.timer"
      permissions = "0644"
      content     = file("${path.module}/server/ec2-test-hours.timer")
    }
  ]

  server_user_data = "#cloud-config\n${yamlencode({
    write_files = local.server_files
    runcmd = [
      ["systemctl", "disable", "--now", "sshd.service"],
      ["systemctl", "mask", "sshd.service"],
      ["systemctl", "enable", "--now", "amazon-ssm-agent.service"],
      ["systemctl", "daemon-reload"],
      ["systemctl", "enable", "--now", "ec2-test-renew.timer", "ec2-test-hours.timer"],
      ["systemctl", "enable", "ec2-test-bootstrap.service"],
      ["systemctl", "start", "--no-block", "ec2-test-bootstrap.service"]
    ]
  })}"
}

resource "aws_eip" "website" {
  domain = "vpc"

  tags = {
    Name = "ec2-test-website"
  }
}

resource "aws_instance" "website" {
  ami                                  = var.use_recovery_image ? aws_ami.recovery[0].id : data.aws_ami.server.id
  instance_type                        = "t4g.micro"
  subnet_id                            = aws_subnet.website[var.deployment_site].id
  vpc_security_group_ids               = [aws_security_group.website.id]
  associate_public_ip_address          = false
  iam_instance_profile                 = aws_iam_instance_profile.website.name
  user_data                            = var.use_recovery_image ? local.recovery_user_data : local.server_user_data
  user_data_replace_on_change          = true
  monitoring                           = false
  instance_initiated_shutdown_behavior = "stop"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name    = "ec2-test-root"
      Project = "ec2-technical-test"
      Backup  = "daily"
    }
  }

  tags = {
    Name       = "ec2-test-website"
    Site       = var.deployment_site
    PatchGroup = "ec2-technical-test"
  }

  lifecycle {
    # Elastic IP association changes the reported public-IP flag after launch.
    ignore_changes = [associate_public_ip_address]

    precondition {
      condition     = length(local.server_user_data) <= 16384
      error_message = "The server bootstrap exceeds EC2's user-data size limit."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.systems_manager,
    aws_route_table_association.website,
    aws_vpc_security_group_egress_rule.http,
    aws_vpc_security_group_egress_rule.https,
    aws_vpc_security_group_ingress_rule.http,
    aws_vpc_security_group_ingress_rule.https
  ]
}

resource "aws_eip_association" "website" {
  allocation_id = aws_eip.website.id
  instance_id   = aws_instance.website.id
}

output "website_url" {
  description = "HTTPS address; usable after bootstrap succeeds and while the instance is running."
  value       = "https://${aws_eip.website.public_ip}"
}

output "website_instance_id" {
  value = aws_instance.website.id
}
