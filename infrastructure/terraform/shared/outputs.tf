output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "organization" {
  description = "Organization name"
  value       = var.organization
}

output "common_tags" {
  description = "Common tags to be applied to all resources"
  value       = var.common_tags
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "env_tags" {
  description = "Environment-specific tags"
  value       = local.env_tags
}

output "global_tags" {
  description = "Global tags"
  value       = local.global_tags
}

output "name_prefix" {
  description = "Common naming prefix"
  value       = local.name_prefix
}

output "env_name_prefix" {
  description = "Environment-specific naming prefix"
  value       = local.env_name_prefix
}