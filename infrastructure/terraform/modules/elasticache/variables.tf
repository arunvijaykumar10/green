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
  description = "VPC ID where ElastiCache will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to connect to ElastiCache"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to ElastiCache"
  type        = list(string)
  default     = []
}

# Engine Configuration
variable "engine_version" {
  description = "Valkey engine version"
  type        = string
  default     = "7.2"
}

variable "family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "valkey7"
}

variable "node_type" {
  description = "Instance type for ElastiCache nodes"
  type        = string
  default     = "cache.t4g.micro"
}

variable "port" {
  description = "Port for ElastiCache cluster"
  type        = number
  default     = 6379
}

# Cluster Configuration
variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "parameters" {
  description = "List of ElastiCache parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Security Configuration
variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = false  # Disabled for simplicity in dev/staging
}

variable "auth_token" {
  description = "Auth token for ElastiCache (requires transit encryption)"
  type        = string
  default     = null
  sensitive   = true
}

# Backup Configuration
variable "snapshot_retention_limit" {
  description = "Number of days for which ElastiCache retains automatic snapshots"
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Daily time range for ElastiCache snapshots"
  type        = string
  default     = "03:00-05:00"
}

# Maintenance Configuration
variable "maintenance_window" {
  description = "Weekly time range for ElastiCache maintenance"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 7
}