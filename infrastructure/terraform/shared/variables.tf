# Shared variables across all environments and modules

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "greenroom"
}

variable "organization" {
  description = "Organization name"
  type        = string
  default     = "ttl"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project      = "greenroom"
    Organization = "ttl"
    ManagedBy    = "terraform"
  }
}

# Environment-specific variables
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the environment"
  type        = string
}

# Global settings
variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state storage"
  type        = string
  default     = "ttl-greenroom-terraform-state"
}

variable "terraform_state_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
  default     = "ttl-greenroom-terraform-locks"
}

# IAM settings
variable "cicd_role_name" {
  description = "Name of the CI/CD IAM role"
  type        = string
  default     = "terraform-cicd-role"
}

variable "developer_group_name" {
  description = "Name of the developer IAM group"
  type        = string
  default     = "developers"
}

# Networking defaults
variable "vpc_cidr_base" {
  description = "Base CIDR blocks for VPCs by environment"
  type        = map(string)
  default = {
    dev        = "10.0.0.0/16"
    staging    = "10.1.0.0/16"
    production = "10.2.0.0/16"
  }
}