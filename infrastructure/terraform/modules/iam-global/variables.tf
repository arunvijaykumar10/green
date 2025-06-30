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

variable "cicd_role_name" {
  description = "Name of the CI/CD IAM role"
  type        = string
}

variable "developer_group_name" {
  description = "Name of the developer IAM group"
  type        = string
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state storage"
  type        = string
}

variable "terraform_state_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
}

variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["dev", "staging", "production"]
}

variable "trusted_cicd_principals" {
  description = "List of trusted principals that can assume the CI/CD role (e.g., GitHub Actions, Jenkins)"
  type        = list(string)
  default     = []
}