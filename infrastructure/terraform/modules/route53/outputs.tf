# Public Hosted Zone Outputs
output "public_zone_id" {
  description = "ID of the public hosted zone"
  value       = var.create_public_zone ? aws_route53_zone.public[0].zone_id : null
}

output "public_zone_name" {
  description = "Name of the public hosted zone"
  value       = var.create_public_zone ? aws_route53_zone.public[0].name : null
}

output "public_zone_name_servers" {
  description = "Name servers for the public hosted zone"
  value       = var.create_public_zone ? aws_route53_zone.public[0].name_servers : null
}

# Private Hosted Zone Outputs
output "private_zone_id" {
  description = "ID of the private hosted zone"
  value       = var.create_private_zone ? aws_route53_zone.private[0].zone_id : null
}

output "private_zone_name" {
  description = "Name of the private hosted zone"
  value       = var.create_private_zone ? aws_route53_zone.private[0].name : null
}

# Public DNS Records
output "app_public_fqdn" {
  description = "FQDN for the app subdomain"
  value       = var.create_public_zone && var.alb_dns_name != null ? aws_route53_record.app_public[0].fqdn : null
}

output "api_public_fqdn" {
  description = "FQDN for the api subdomain"
  value       = var.create_public_zone && var.alb_dns_name != null ? aws_route53_record.api_public[0].fqdn : null
}

output "admin_public_fqdn" {
  description = "FQDN for the admin subdomain"
  value       = var.create_public_zone && var.alb_dns_name != null ? aws_route53_record.admin_public[0].fqdn : null
}

output "employee_public_fqdn" {
  description = "FQDN for the employee subdomain"
  value       = var.create_public_zone && var.alb_dns_name != null ? aws_route53_record.employee_public[0].fqdn : null
}

# Private DNS Records
output "cache_private_fqdn" {
  description = "FQDN for the cache internal endpoint"
  value       = var.create_private_zone && var.cache_endpoint != null ? aws_route53_record.cache_private[0].fqdn : null
}

output "db_private_fqdn" {
  description = "FQDN for the database internal endpoint"
  value       = var.create_private_zone && var.db_endpoint != null ? aws_route53_record.db_private[0].fqdn : null
}

output "alb_private_fqdn" {
  description = "FQDN for the ALB internal endpoint"
  value       = var.create_private_zone && var.alb_dns_name != null ? aws_route53_record.alb_private[0].fqdn : null
}

# SSL Certificate Outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.create_ssl_certificate && var.create_public_zone ? aws_acm_certificate.public[0].arn : null
}

output "ssl_certificate_status" {
  description = "Status of the SSL certificate"
  value       = var.create_ssl_certificate && var.create_public_zone ? aws_acm_certificate.public[0].status : null
}

output "ssl_certificate_domain_name" {
  description = "Domain name of the SSL certificate"
  value       = var.create_ssl_certificate && var.create_public_zone ? aws_acm_certificate.public[0].domain_name : null
}

# Connection strings for applications
output "connection_endpoints" {
  description = "Connection endpoints for applications"
  value = {
    # Public endpoints (HTTPS if SSL cert exists, HTTP otherwise)
    app_url      = var.create_public_zone && var.alb_dns_name != null ? (var.create_ssl_certificate ? "https://app.${var.public_domain_name}" : "http://app.${var.public_domain_name}") : null
    api_url      = var.create_public_zone && var.alb_dns_name != null ? (var.create_ssl_certificate ? "https://api.${var.public_domain_name}" : "http://api.${var.public_domain_name}") : null
    admin_url    = var.create_public_zone && var.alb_dns_name != null ? (var.create_ssl_certificate ? "https://admin.${var.public_domain_name}" : "http://admin.${var.public_domain_name}") : null
    employee_url = var.create_public_zone && var.alb_dns_name != null ? (var.create_ssl_certificate ? "https://employee.${var.public_domain_name}" : "http://employee.${var.public_domain_name}") : null
    auth_url     = var.create_public_zone && var.cognito_domain != null ? "https://auth.${var.public_domain_name}" : null

    # Private hostnames (internal DNS)
    cache_host = var.create_private_zone && var.cache_endpoint != null ? "cache.${var.private_domain_name}" : null
    db_host    = var.create_private_zone && var.db_endpoint != null ? "db.${var.private_domain_name}" : null
    alb_host   = var.create_private_zone && var.alb_dns_name != null ? "alb.${var.private_domain_name}" : null
  }
}