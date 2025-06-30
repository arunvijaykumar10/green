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

# Password Policy
variable "password_minimum_length" {
  description = "Minimum length for user passwords"
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Require lowercase letters in passwords"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Require numbers in passwords"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Require symbols in passwords"
  type        = bool
  default     = false
}

variable "password_require_uppercase" {
  description = "Require uppercase letters in passwords"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days temporary passwords are valid"
  type        = number
  default     = 7
}

# MFA Configuration
variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

# Device Configuration
variable "challenge_required_on_new_device" {
  description = "Challenge required on new device"
  type        = bool
  default     = false
}

variable "device_only_remembered_on_user_prompt" {
  description = "Device only remembered on user prompt"
  type        = bool
  default     = false
}

# Security
variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

# Token Validity
variable "refresh_token_validity_days" {
  description = "Refresh token validity in days"
  type        = number
  default     = 30
}

variable "access_token_validity_hours" {
  description = "Access token validity in hours"
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "ID token validity in hours"
  type        = number
  default     = 1
}

# OAuth Configuration
variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = []
}

# Attributes
variable "read_attributes" {
  description = "List of user pool attributes that can be read"
  type        = list(string)
  default = [
    "email",
    "email_verified",
    "preferred_username",
    "name",
    "family_name",
    "given_name",
    "phone_number",
    "phone_number_verified"
  ]
}

variable "write_attributes" {
  description = "List of user pool attributes that can be written"
  type        = list(string)
  default = [
    "email",
    "preferred_username",
    "name",
    "family_name",
    "given_name",
    "phone_number"
  ]
}

# Domain Configuration
variable "create_domain" {
  description = "Whether to create a Cognito domain"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Custom domain name for Cognito (if null, will use auto-generated)"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (required for custom domains)"
  type        = string
  default     = null
}

# Identity Pool
variable "create_identity_pool" {
  description = "Whether to create Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "allow_unauthenticated_identities" {
  description = "Whether to allow unauthenticated identities"
  type        = bool
  default     = false
}

# Lambda Triggers
variable "lambda_triggers" {
  description = "Map of Lambda trigger configurations"
  type        = map(string)
  default     = {}
}

# Custom Attributes
variable "custom_attributes" {
  description = "List of custom user attributes"
  type = list(object({
    name          = string
    type          = string  # String, Number, DateTime, Boolean
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