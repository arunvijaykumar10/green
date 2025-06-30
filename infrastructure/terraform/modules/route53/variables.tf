variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "organization" {
  description = "Organization name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
}

# Domain Configuration
variable "public_domain_name" {
  description = "Public domain name for the hosted zone"
  type        = string
}

variable "private_domain_name" {
  description = "Private domain name for the hosted zone"
  type        = string
}

# Zone Creation Flags
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

variable "force_destroy" {
  description = "Allow destruction of hosted zones"
  type        = bool
  default     = false
}

# DNS Record Configuration
variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
  default     = null
}

variable "cache_endpoint" {
  description = "ElastiCache endpoint"
  type        = string
  default     = null
}

variable "db_endpoint" {
  description = "RDS database endpoint"
  type        = string
  default     = null
}

# TTL Settings
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

# SSL Certificate
variable "create_ssl_certificate" {
  description = "Whether to create SSL certificate for the public domain"
  type        = bool
  default     = true
}

variable "cognito_domain" {
  description = "Cognito user pool domain for auth CNAME record"
  type        = string
  default     = null
}