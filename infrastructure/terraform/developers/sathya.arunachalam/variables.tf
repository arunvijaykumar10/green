variable "email" {
  description = "Developer's email address"
  type        = string
  default     = "sathya.arunachalam@drylogics.com"
}

variable "username" {
  description = "Developer's username"
  type        = string
  default     = "sathya.arunachalam"
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
