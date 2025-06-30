terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ttl-greenroom-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ttl-greenroom-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.global_tags
  }
}

# Include shared configurations
module "shared" {
  source = "../shared"

  # Override environment to "global" for global resources
  environment = "global"
  aws_region  = var.aws_region
}

# Global IAM setup
module "iam_global" {
  source = "../modules/iam-global"

  project_name                = module.shared.project_name
  organization               = module.shared.organization
  common_tags                = local.global_tags
  cicd_role_name            = local.cicd_role_name
  developer_group_name      = local.developer_group_name
  terraform_state_bucket    = local.state_bucket_name
  terraform_state_lock_table = local.state_lock_table
  environments              = local.environments
  trusted_cicd_principals   = var.trusted_cicd_principals
}