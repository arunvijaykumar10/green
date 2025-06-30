variable "username" {
  description = "The username for the IAM user"
  type        = string
}

variable "email" {
  description = "The email address for the IAM user"
  type        = string
}

variable "environments" {
  description = "List of environments the developer should have access to (dev, staging, prod)"
  type        = list(string)
  default     = ["dev"]  # Default to dev access only
  validation {
    condition     = alltrue([for env in var.environments : contains(["dev", "staging", "prod"], env)])
    error_message = "Each environment must be one of: dev, staging, prod"
  }
}