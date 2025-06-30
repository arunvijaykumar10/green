variable "aws_region" {
  description = "AWS region for global resources"
  type        = string
  default     = "us-east-1"
}

variable "trusted_cicd_principals" {
  description = "List of trusted principals that can assume the CI/CD role (e.g., GitHub Actions OIDC, Jenkins)"
  type        = list(string)
  default     = []
}