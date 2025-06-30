# User Pool Outputs
output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_name" {
  description = "Name of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.name
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "user_pool_domain" {
  description = "Domain of the Cognito User Pool"
  value       = var.create_domain ? aws_cognito_user_pool_domain.main[0].domain : null
}

output "user_pool_domain_cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for the user pool domain"
  value       = var.create_domain ? aws_cognito_user_pool_domain.main[0].cloudfront_distribution_arn : null
}

# Web Client Outputs
output "web_client_id" {
  description = "ID of the Cognito User Pool Web Client"
  value       = aws_cognito_user_pool_client.web_client.id
}

output "web_client_name" {
  description = "Name of the Cognito User Pool Web Client"
  value       = aws_cognito_user_pool_client.web_client.name
}

# API Client Outputs
output "api_client_id" {
  description = "ID of the Cognito User Pool API Client"
  value       = aws_cognito_user_pool_client.api_client.id
}

output "api_client_secret" {
  description = "Secret of the Cognito User Pool API Client"
  value       = aws_cognito_user_pool_client.api_client.client_secret
  sensitive   = true
}

output "api_client_name" {
  description = "Name of the Cognito User Pool API Client"
  value       = aws_cognito_user_pool_client.api_client.name
}

# Identity Pool Outputs
output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null
}

output "identity_pool_arn" {
  description = "ARN of the Cognito Identity Pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].arn : null
}

# IAM Role Outputs
output "authenticated_role_arn" {
  description = "ARN of the authenticated IAM role"
  value       = var.create_identity_pool ? aws_iam_role.authenticated[0].arn : null
}

# Application Configuration
output "auth_config" {
  description = "Authentication configuration for applications"
  value = {
    # Cognito User Pool
    user_pool_id     = aws_cognito_user_pool.main.id
    user_pool_region = data.aws_region.current.name

    # Web Client (for frontend apps)
    web_client_id = aws_cognito_user_pool_client.web_client.id

    # API Client (for backend services)
    api_client_id = aws_cognito_user_pool_client.api_client.id

    # Domain for hosted UI
    auth_domain = var.create_domain ? aws_cognito_user_pool_domain.main[0].domain : null

    # Identity Pool (if created)
    identity_pool_id = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null

    # OAuth Configuration
    oauth_flows = ["code", "implicit"]
    oauth_scopes = ["email", "openid", "profile"]

    # Token Configuration
    token_validity = {
      access_token  = var.access_token_validity_hours
      id_token      = var.id_token_validity_hours
      refresh_token = var.refresh_token_validity_days
    }
  }
  sensitive = false
}

# Data source for current region
data "aws_region" "current" {}