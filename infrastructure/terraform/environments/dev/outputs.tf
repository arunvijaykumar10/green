output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.networking.database_subnet_ids
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.networking.web_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.networking.database_security_group_id
}

output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# RDS Outputs
output "db_instance_endpoint" {
  description = "RDS instance connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_identifier
}

output "db_instance_name" {
  description = "Database name"
  value       = module.rds.db_instance_name
}

output "db_instance_username" {
  description = "Master username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_instance_port" {
  description = "Database port"
  value       = module.rds.db_instance_port
}

output "db_instance_address" {
  description = "Database address (hostname)"
  value       = module.rds.db_instance_address
}

output "db_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = module.rds.db_security_group_id
}

output "master_user_secret_arn" {
  description = "ARN of the master user secret (AWS Secrets Manager)"
  value       = module.rds.master_user_secret_arn
  sensitive   = true
}

# Networking outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.networking.load_balancer_dns_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = module.networking.load_balancer_dns_name != null ? "http://${module.networking.load_balancer_dns_name}" : null
}

# ECR outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ECS outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs.task_definition_arn
}

# ElastiCache outputs
output "cache_replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = module.elasticache.replication_group_id
}

output "cache_primary_endpoint_address" {
  description = "Address of the primary cache endpoint"
  value       = module.elasticache.primary_endpoint_address
}

output "cache_port" {
  description = "Port of the ElastiCache cluster"
  value       = module.elasticache.port
}

output "cache_security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = module.elasticache.security_group_id
}

# Route 53 DNS outputs
output "public_zone_id" {
  description = "ID of the public hosted zone"
  value       = module.route53.public_zone_id
}

output "public_zone_name_servers" {
  description = "Name servers for the public hosted zone"
  value       = module.route53.public_zone_name_servers
}

output "private_zone_id" {
  description = "ID of the private hosted zone"
  value       = module.route53.private_zone_id
}

output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.route53.ssl_certificate_arn
}

# Public URLs
output "app_url" {
  description = "App URL"
  value       = module.route53.connection_endpoints.app_url
}

output "api_url" {
  description = "API URL"
  value       = module.route53.connection_endpoints.api_url
}

output "admin_url" {
  description = "Admin URL"
  value       = module.route53.connection_endpoints.admin_url
}

output "employee_url" {
  description = "Employee URL"
  value       = module.route53.connection_endpoints.employee_url
}

# Private endpoints
output "cache_internal_host" {
  description = "Internal cache hostname"
  value       = module.route53.connection_endpoints.cache_host
}

output "db_internal_host" {
  description = "Internal database hostname"
  value       = module.route53.connection_endpoints.db_host
}

# RDS outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Name of the database"
  value       = module.rds.db_instance_name
}

# Useful deployment information
output "deployment_info" {
  description = "Deployment information for the development environment"
  value = {
    environment = "dev"
    region      = var.aws_region

    # Public URLs
    app_url      = module.route53.connection_endpoints.app_url
    api_url      = module.route53.connection_endpoints.api_url
    admin_url    = module.route53.connection_endpoints.admin_url
    employee_url = module.route53.connection_endpoints.employee_url
    auth_url     = module.route53.connection_endpoints.auth_url

    # Load balancer direct access
    load_balancer_url = module.networking.load_balancer_dns_name != null ? "http://${module.networking.load_balancer_dns_name}" : null

    # Container deployment
    ecr_repository = module.ecr.repository_url
    ecs_cluster    = module.ecs.cluster_name
    ecs_service    = module.ecs.service_name

    # Database connection (internal DNS)
    database_host = module.route53.connection_endpoints.db_host
    database_name = module.rds.db_instance_name

    # Cache connection (internal DNS)
    cache_host = module.route53.connection_endpoints.cache_host
    cache_port = module.elasticache.port

    # DNS zones
    public_domain  = var.public_domain_name
    private_domain = var.private_domain_name

    # SSL certificate
    ssl_certificate_arn = module.route53.ssl_certificate_arn

    # Infrastructure IDs
    vpc_id                = module.networking.vpc_id
    private_subnet_ids    = module.networking.private_subnet_ids
    public_subnet_ids     = module.networking.public_subnet_ids
  }
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = module.cognito.user_pool_endpoint
}

output "cognito_user_pool_domain" {
  description = "Domain of the Cognito User Pool"
  value       = module.cognito.user_pool_domain
}

output "cognito_web_client_id" {
  description = "ID of the Cognito User Pool Web Client"
  value       = module.cognito.web_client_id
}

output "cognito_api_client_id" {
  description = "ID of the Cognito User Pool API Client"
  value       = module.cognito.api_client_id
}

output "cognito_auth_config" {
  description = "Complete authentication configuration for applications"
  value       = module.cognito.auth_config
  sensitive   = false
}