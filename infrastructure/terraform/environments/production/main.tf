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
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ttl-greenroom-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.env_tags
  }
}

# Data source to get global resources
data "terraform_remote_state" "global" {
  backend = "s3"

  config = {
    bucket = "ttl-greenroom-terraform-state"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
  }
}

# Include shared configurations
module "shared" {
  source = "../../shared"

  environment = "production"
  aws_region  = var.aws_region
}

# Local values for this environment
locals {
  environment = "production"
  env_tags = merge(module.shared.common_tags, {
    Environment = local.environment
    Region      = var.aws_region
  })
}

# Networking module
module "networking" {
  source = "../../modules/networking"

  environment     = local.environment
  aws_region      = var.aws_region
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  vpc_cidr               = var.vpc_cidr
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
}