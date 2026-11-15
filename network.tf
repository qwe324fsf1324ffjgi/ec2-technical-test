data "aws_availability_zones" "standard" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required", "opted-in"]
  }
}

locals {
  network_sites = {
    primary = {
      cidr = "10.42.10.0/24"
      zone = sort(data.aws_availability_zones.standard.names)[0]
    }
    recovery = {
      cidr = "10.42.20.0/24"
      zone = sort(data.aws_availability_zones.standard.names)[1]
    }
  }
}

resource "aws_vpc" "website" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ec2-test"
  }
}

resource "aws_internet_gateway" "website" {
  vpc_id = aws_vpc.website.id

  tags = {
    Name = "ec2-test"
  }
}

resource "aws_subnet" "website" {
  for_each = local.network_sites

  vpc_id                  = aws_vpc.website.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.zone
  map_public_ip_on_launch = false

  tags = {
    Name = "ec2-test-${each.key}"
  }
}

resource "aws_route_table" "website" {
  vpc_id = aws_vpc.website.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.website.id
  }

  tags = {
    Name = "ec2-test-public"
  }
}

resource "aws_route_table_association" "website" {
  for_each = aws_subnet.website

  subnet_id      = each.value.id
  route_table_id = aws_route_table.website.id
}

resource "aws_security_group" "website" {
  name_prefix = "ec2-test-web-"
  description = "Public HTTP and HTTPS; administration uses Systems Manager"
  vpc_id      = aws_vpc.website.id

  tags = {
    Name = "ec2-test-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.website.id
  description       = "Certificate validation and redirect to HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.website.id
  description       = "Public HTTPS website"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.website.id
  description       = "OS package repository downloads"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.website.id
  description       = "AWS APIs, Systems Manager, updates, and certificate renewal"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

output "network_sites" {
  description = "Primary and recovery subnet locations; only one will host the server normally."
  value = {
    for site, subnet in aws_subnet.website : site => {
      subnet_id         = subnet.id
      availability_zone = subnet.availability_zone
    }
  }
}

output "website_security_group_id" {
  description = "Web-only inbound security group for the future EC2 instance."
  value       = aws_security_group.website.id
}
