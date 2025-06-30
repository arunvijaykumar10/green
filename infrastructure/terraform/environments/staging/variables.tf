variable "aws_region" {
  description = "AWS region for staging environment"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false  # Multiple NAT gateways for better availability in staging
}

# DNS Configuration
variable "public_domain_name" {
  description = "Public domain name for the hosted zone"
  type        = string
  default     = "greenroom.tabletoplabs.studio"
}

variable "private_domain_name" {
  description = "Private domain name for the hosted zone"
  type        = string
  default     = "greenroom-stage.internal"
}

variable "create_public_zone" {
  description = "Whether to create the public hosted zone"
  type        = bool
  default     = true
}

variable "create_private_zone" {
  description = "Whether to create the private hosted zone"
  type        = bool
  default     = true
}

variable "dns_force_destroy" {
  description = "Allow destruction of hosted zones"
  type        = bool
  default     = false  # More protection for staging
}

variable "public_record_ttl" {
  description = "TTL for public DNS records"
  type        = number
  default     = 300
}

variable "private_record_ttl" {
  description = "TTL for private DNS records"
  type        = number
  default     = 60
}

variable "create_ssl_certificate" {
  description = "Whether to create SSL certificate for the public domain"
  type        = bool
  default     = true
}

# RDS Configuration (production-like for staging)
variable "db_instance_class" {
  description = "RDS instance class for staging"
  type        = string
  default     = "db.t4g.small"  # Larger than dev for performance testing
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 50  # More storage than dev
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 200
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7  # Production-like backup retention
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true  # Enabled for staging
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = false  # Take final snapshot in staging
}

variable "db_performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7  # Valid values are 7 (free) or 731 (paid)
}

# Load Balancer Configuration
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Port that the application listens on"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/health"
}

# ECR Configuration
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for the repository"
  type        = string
  default     = "IMMUTABLE"  # More strict for staging
}

variable "ecr_scan_on_push" {
  description = "Enable vulnerability scanning on image push"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to keep in the repository"
  type        = number
  default     = 20  # More images than dev
}

# ElastiCache Configuration (Valkey)
variable "cache_engine_version" {
  description = "Valkey engine version"
  type        = string
  default     = "7.2"
}

variable "cache_family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "valkey7"
}

variable "cache_node_type" {
  description = "Instance type for ElastiCache nodes"
  type        = string
  default     = "cache.t4g.small"  # Larger than dev for staging
}

variable "cache_port" {
  description = "Port for ElastiCache cluster"
  type        = number
  default     = 6379
}

variable "cache_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1  # Single node for staging as requested
}

variable "cache_at_rest_encryption_enabled" {
  description = "Enable encryption at rest for ElastiCache"
  type        = bool
  default     = true
}

variable "cache_transit_encryption_enabled" {
  description = "Enable encryption in transit for ElastiCache"
  type        = bool
  default     = true  # Enabled for staging
}

variable "cache_snapshot_retention_limit" {
  description = "Number of days for which ElastiCache retains automatic snapshots"
  type        = number
  default     = 3  # More retention than dev
}

variable "cache_snapshot_window" {
  description = "Daily time range for ElastiCache snapshots"
  type        = string
  default     = "03:00-05:00"
}

variable "cache_maintenance_window" {
  description = "Weekly time range for ElastiCache maintenance"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "cache_auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

# ECS Configuration (production-like for staging)
variable "ecs_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512  # More CPU than dev
}

variable "ecs_memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 1024  # More memory than dev
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2  # More instances for staging
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 6  # More scaling capacity for staging
}

variable "container_image" {
  description = "Docker image for the application container (will default to ECR repository if not specified)"
  type        = string
  default     = null
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "greenroom-app"
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {
    NODE_ENV = "staging"
    LOG_LEVEL = "info"
  }
}

variable "secrets" {
  description = "Secrets from AWS Secrets Manager for the container"
  type        = map(string)
  default     = {}
}

variable "health_check_grace_period_seconds" {
  description = "Grace period for health checks"
  type        = number
  default     = 60
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14  # Longer retention for staging
}

# Cognito Configuration
variable "cognito_password_minimum_length" {
  description = "Minimum length for user passwords"
  type        = number
  default     = 8
}

variable "cognito_password_require_lowercase" {
  description = "Require lowercase letters in passwords"
  type        = bool
  default     = true
}

variable "cognito_password_require_numbers" {
  description = "Require numbers in passwords"
  type        = bool
  default     = true
}

variable "cognito_password_require_symbols" {
  description = "Require symbols in passwords"
  type        = bool
  default     = true  # More secure for staging
}

variable "cognito_password_require_uppercase" {
  description = "Require uppercase letters in passwords"
  type        = bool
  default     = true
}

variable "cognito_temporary_password_validity_days" {
  description = "Number of days temporary passwords are valid"
  type        = number
  default     = 7
}

variable "cognito_mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "ON"  # More secure for staging
}

variable "cognito_advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "ENFORCED"  # More secure for staging
}

variable "cognito_refresh_token_validity_days" {
  description = "Refresh token validity in days"
  type        = number
  default     = 30
}

variable "cognito_access_token_validity_hours" {
  description = "Access token validity in hours"
  type        = number
  default     = 1
}

variable "cognito_id_token_validity_hours" {
  description = "ID token validity in hours"
  type        = number
  default     = 1
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = []
}

variable "cognito_create_domain" {
  description = "Whether to create a Cognito domain"
  type        = bool
  default     = true
}

variable "cognito_domain_name" {
  description = "Custom domain name for Cognito"
  type        = string
  default     = null
}

variable "cognito_create_identity_pool" {
  description = "Whether to create Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "cognito_allow_unauthenticated_identities" {
  description = "Whether to allow unauthenticated identities"
  type        = bool
  default     = false
}

variable "cognito_custom_attributes" {
  description = "List of custom user attributes"
  type = list(object({
    name          = string
    type          = string
    required      = optional(bool, false)
    mutable       = optional(bool, true)
    developer_only = optional(bool, false)
    min_length    = optional(number)
    max_length    = optional(number)
    min_value     = optional(number)
    max_value     = optional(number)
  }))
  default = []
}