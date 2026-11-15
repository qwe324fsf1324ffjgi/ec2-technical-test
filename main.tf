terraform {
  required_version = ">= 1.15.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region used for the deployment."
  type        = string
  default     = "eu-north-1"
}

variable "expected_account_id" {
  description = "Only permit Terraform to operate in this AWS account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Enter the 12-digit AWS account ID."
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]

  default_tags {
    tags = {
      Project   = "ec2-technical-test"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

output "connected_account_id" {
  description = "Account authenticated by the Terraform AWS provider."
  value       = data.aws_caller_identity.current.account_id
}
