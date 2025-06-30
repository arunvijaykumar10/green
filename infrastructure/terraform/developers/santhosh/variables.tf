variable "email" {
  description = "Developer's email address"
  type        = string
  default     = "santhosh@drylogics.com"
}

variable "username" {
  description = "Developer's username"
  type        = string
  default     = "santhosh"
}

variable "environments" {
  description = "List of environments the developer should have access to"
  type        = list(string)
  default     = ["dev"]

  validation {
    condition     = alltrue([for env in var.environments : contains(["dev", "staging", "prod"], env)])
    error_message = "Environments must be one of: dev, staging, prod"
  }
}
