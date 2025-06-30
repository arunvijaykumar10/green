# Shared locals across all environments and modules

locals {
  # Common naming convention
  name_prefix = "${var.organization}-${var.project_name}"

  # Environment-specific naming
  env_name_prefix = "${local.name_prefix}-${var.environment}"

  # Common tags with environment
  env_tags = merge(var.common_tags, {
    Environment = var.environment
    Region      = var.aws_region
  })

  # Global tags (for global resources)
  global_tags = merge(var.common_tags, {
    Scope = "global"
  })

  # State backend configuration
  state_bucket_name = var.terraform_state_bucket
  state_lock_table  = var.terraform_state_lock_table

  # IAM naming
  cicd_role_name        = "${local.name_prefix}-${var.cicd_role_name}"
  developer_group_name  = "${local.name_prefix}-${var.developer_group_name}"

  # Environment configuration
  environments = ["dev", "staging", "production"]

  # Default regions for environments
  default_regions = {
    dev        = "us-west-2"
    staging    = "us-west-2"
    production = "us-east-1"
  }
}