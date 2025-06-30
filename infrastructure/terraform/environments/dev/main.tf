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
    key            = "environments/dev/terraform.tfstate"
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

  environment = "dev"
  aws_region  = var.aws_region
}

# Local values for this environment
locals {
  environment = "dev"
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

  # Load balancer configuration
  enable_load_balancer    = var.enable_load_balancer
  enable_deletion_protection = false  # Disabled for dev
  app_port                = var.app_port
  health_check_path       = var.health_check_path
}

# ECR Repository
module "ecr" {
  source = "../../modules/ecr"

  environment     = local.environment
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  max_image_count      = var.ecr_max_image_count
}

# RDS PostgreSQL module
module "rds" {
  source = "../../modules/rds"

  environment     = local.environment
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  # Network configuration
  vpc_id                = module.networking.vpc_id
  db_subnet_group_name  = module.networking.db_subnet_group_name

  # Allow connections from web security group (which includes app servers)
  allowed_security_groups = [
    module.networking.web_security_group_id,
    module.networking.default_security_group_id
  ]

  # Database configuration
  database_name = "greenroom"
  master_username = "postgres"

  # Use AWS Secrets Manager for password management
  manage_master_user_password = true

  # Instance configuration
  instance_class        = var.db_instance_class
  engine_version        = "17.2"
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  # GP3 storage with unlimited mode (autoscaling)
  storage_type       = "gp3"
  storage_iops       = 3000

  # Backup and maintenance (minimal for dev)
  backup_retention_period = var.db_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Development-friendly settings
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot

  # Monitoring and logging
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
}

# ElastiCache Valkey module
module "elasticache" {
  source = "../../modules/elasticache"

  environment     = local.environment
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  # Network configuration
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids

  # Allow connections from ECS tasks and web security group
  allowed_security_groups = [
    module.networking.web_security_group_id,
    module.networking.default_security_group_id
  ]

  # Engine configuration
  engine_version = var.cache_engine_version
  family         = var.cache_family
  node_type      = var.cache_node_type
  port           = var.cache_port

  # Cluster configuration (single node for dev)
  num_cache_nodes = var.cache_num_nodes

  # Security configuration (minimal for dev)
  at_rest_encryption_enabled = var.cache_at_rest_encryption_enabled
  transit_encryption_enabled = var.cache_transit_encryption_enabled

  # Backup configuration (minimal for dev)
  snapshot_retention_limit = var.cache_snapshot_retention_limit
  snapshot_window         = var.cache_snapshot_window

  # Maintenance configuration
  maintenance_window          = var.cache_maintenance_window
  auto_minor_version_upgrade  = var.cache_auto_minor_version_upgrade

  # Monitoring
  log_retention_days = var.log_retention_days
}

# Route 53 DNS module
module "route53" {
  source = "../../modules/route53"

  environment     = local.environment
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  # VPC configuration
  vpc_id = module.networking.vpc_id

  # Domain configuration
  public_domain_name  = var.public_domain_name
  private_domain_name = var.private_domain_name

  # Zone creation flags
  create_public_zone  = var.create_public_zone
  create_private_zone = var.create_private_zone
  force_destroy       = var.dns_force_destroy

  # DNS record configuration
  alb_dns_name   = module.networking.load_balancer_dns_name
  cache_endpoint = module.elasticache.primary_endpoint_address
  db_endpoint    = module.rds.db_instance_endpoint
  cognito_domain = module.cognito.user_pool_domain

  # TTL settings
  public_record_ttl  = var.public_record_ttl
  private_record_ttl = var.private_record_ttl

  # SSL certificate
  create_ssl_certificate = var.create_ssl_certificate

  depends_on = [module.networking, module.rds, module.elasticache, module.cognito]
}

# ECS Fargate Cluster and Service
module "ecs" {
  source = "../../modules/ecs"

  environment     = local.environment
  aws_region      = var.aws_region
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  # Network configuration
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  target_group_arn    = module.networking.target_group_arn

  # Allow connections from ALB and cache access
  allowed_security_groups = [
    module.networking.alb_security_group_id,
    module.elasticache.security_group_id
  ]

  # ECR integration
  ecr_repository_name = module.ecr.repository_name

  # Container configuration
  container_image = var.container_image != null ? var.container_image : "${module.ecr.repository_url}:latest"
  container_name  = var.container_name
  container_port  = var.app_port

  # Task configuration (dev-optimized)
  cpu           = var.ecs_cpu
  memory        = var.ecs_memory
  desired_count = var.ecs_desired_count
  min_capacity  = var.ecs_min_capacity
  max_capacity  = var.ecs_max_capacity

  # Environment variables (including cache and db connection via private DNS)
  environment_variables = merge(var.environment_variables, {
    CACHE_HOST = module.route53.connection_endpoints.cache_host != null ? module.route53.connection_endpoints.cache_host : module.elasticache.primary_endpoint_address
    CACHE_PORT = tostring(module.elasticache.port)
    DB_HOST    = module.route53.connection_endpoints.db_host != null ? module.route53.connection_endpoints.db_host : module.rds.db_instance_address
    DB_PORT    = tostring(module.rds.db_instance_port)

    # Cognito Authentication Configuration
    COGNITO_USER_POOL_ID     = module.cognito.user_pool_id
    COGNITO_WEB_CLIENT_ID    = module.cognito.web_client_id
    COGNITO_API_CLIENT_ID    = module.cognito.api_client_id
    COGNITO_REGION           = var.aws_region
    COGNITO_DOMAIN           = module.cognito.user_pool_domain

    # Auth endpoint URLs for apps
    AUTH_BASE_URL = module.cognito.user_pool_domain != null ? "https://${module.cognito.user_pool_domain}.auth.${var.aws_region}.amazoncognito.com" : ""
  })
  secrets              = var.secrets

  # Health check configuration
  health_check_path                    = var.health_check_path
  health_check_grace_period_seconds   = var.health_check_grace_period_seconds

  # Monitoring
  enable_container_insights = var.enable_container_insights
  log_retention_days       = var.log_retention_days

  depends_on = [module.networking, module.ecr, module.elasticache, module.route53, module.cognito]
}

# S3 Uploads Bucket
module "s3" {
  source = "../../modules/s3"

  environment     = local.environment
  common_tags     = local.env_tags
}

# Cognito User Pool and Identity Pool
module "cognito" {
  source = "../../modules/cognito"

  environment     = local.environment
  project_name    = module.shared.project_name
  organization    = module.shared.organization
  common_tags     = local.env_tags

  # Password Policy
  password_minimum_length      = var.cognito_password_minimum_length
  password_require_lowercase   = var.cognito_password_require_lowercase
  password_require_numbers     = var.cognito_password_require_numbers
  password_require_symbols     = var.cognito_password_require_symbols
  password_require_uppercase   = var.cognito_password_require_uppercase
  temporary_password_validity_days = var.cognito_temporary_password_validity_days

  # Security Configuration
  mfa_configuration        = var.cognito_mfa_configuration
  advanced_security_mode   = var.cognito_advanced_security_mode

  # Token Configuration
  refresh_token_validity_days    = var.cognito_refresh_token_validity_days
  access_token_validity_hours    = var.cognito_access_token_validity_hours
  id_token_validity_hours        = var.cognito_id_token_validity_hours

  # OAuth Configuration
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  # Domain Configuration
  create_domain = var.cognito_create_domain

  # Identity Pool Configuration
  create_identity_pool             = true
  allow_unauthenticated_identities = false

  # Custom Attributes
  custom_attributes = var.cognito_custom_attributes
}