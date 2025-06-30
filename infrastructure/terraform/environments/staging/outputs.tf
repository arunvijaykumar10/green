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