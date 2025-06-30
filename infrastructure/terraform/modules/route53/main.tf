# Public Hosted Zone
resource "aws_route53_zone" "public" {
  count = var.create_public_zone ? 1 : 0

  name          = var.public_domain_name
  comment       = "Public hosted zone for ${var.project_name} ${var.environment}"
  force_destroy = var.force_destroy

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-public-zone"
    Type = "route53-public-zone"
  })
}

# Private Hosted Zone
resource "aws_route53_zone" "private" {
  count = var.create_private_zone ? 1 : 0

  name    = var.private_domain_name
  comment = "Private hosted zone for ${var.project_name} ${var.environment}"

  vpc {
    vpc_id = var.vpc_id
  }

  force_destroy = var.force_destroy

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-private-zone"
    Type = "route53-private-zone"
  })
}

# Public DNS Records - ALB for app and api subdomains
resource "aws_route53_record" "app_public" {
  count = var.create_public_zone && var.alb_dns_name != null ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "app.${var.public_domain_name}"
  type    = "CNAME"
  ttl     = var.public_record_ttl

  records = [var.alb_dns_name]
}

resource "aws_route53_record" "api_public" {
  count = var.create_public_zone && var.alb_dns_name != null ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "api.${var.public_domain_name}"
  type    = "CNAME"
  ttl     = var.public_record_ttl

  records = [var.alb_dns_name]
}

# Additional public subdomains (admin, employee)
resource "aws_route53_record" "admin_public" {
  count = var.create_public_zone && var.alb_dns_name != null ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "admin.${var.public_domain_name}"
  type    = "CNAME"
  ttl     = var.public_record_ttl

  records = [var.alb_dns_name]
}

resource "aws_route53_record" "employee_public" {
  count = var.create_public_zone && var.alb_dns_name != null ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "employee.${var.public_domain_name}"
  type    = "CNAME"
  ttl     = var.public_record_ttl

  records = [var.alb_dns_name]
}

# Auth subdomain pointing to Cognito domain
resource "aws_route53_record" "auth_public" {
  count = var.create_public_zone && var.cognito_domain != null ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "auth.${var.public_domain_name}"
  type    = "CNAME"
  ttl     = var.public_record_ttl

  records = ["${var.cognito_domain}.auth.${data.aws_region.current.name}.amazoncognito.com"]
}

# Private DNS Records - Internal services
resource "aws_route53_record" "cache_private" {
  count = var.create_private_zone && var.cache_endpoint != null ? 1 : 0

  zone_id = aws_route53_zone.private[0].zone_id
  name    = "cache.${var.private_domain_name}"
  type    = "CNAME"
  ttl     = var.private_record_ttl

  records = [var.cache_endpoint]
}

resource "aws_route53_record" "db_private" {
  count = var.create_private_zone && var.db_endpoint != null ? 1 : 0

  zone_id = aws_route53_zone.private[0].zone_id
  name    = "db.${var.private_domain_name}"
  type    = "CNAME"
  ttl     = var.private_record_ttl

  records = [var.db_endpoint]
}

# Private DNS Record - ALB for internal services
resource "aws_route53_record" "alb_private" {
  count = var.create_private_zone && var.alb_dns_name != null ? 1 : 0

  zone_id = aws_route53_zone.private[0].zone_id
  name    = "alb.${var.private_domain_name}"
  type    = "CNAME"
  ttl     = var.private_record_ttl

  records = [var.alb_dns_name]
}

# Optional: Create wildcard certificate for the public domain
resource "aws_acm_certificate" "public" {
  count = var.create_ssl_certificate && var.create_public_zone ? 1 : 0

  domain_name               = var.public_domain_name
  subject_alternative_names = ["*.${var.public_domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ssl-cert"
    Type = "acm-certificate"
  })
}

# DNS validation records for SSL certificate
resource "aws_route53_record" "cert_validation" {
  for_each = var.create_ssl_certificate && var.create_public_zone ? {
    for dvo in aws_acm_certificate.public[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.public[0].zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "public" {
  count = var.create_ssl_certificate && var.create_public_zone ? 1 : 0

  certificate_arn         = aws_acm_certificate.public[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "15m"  # Increased timeout to 15 minutes
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Get current AWS region
data "aws_region" "current" {}