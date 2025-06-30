output "terraform_state_bucket" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = module.iam_global.terraform_state_bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state"
  value       = module.iam_global.terraform_state_bucket_arn
}

output "terraform_lock_table" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = module.iam_global.terraform_lock_table
}

output "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking"
  value       = module.iam_global.terraform_lock_table_arn
}

output "cicd_role_name" {
  description = "Name of the CI/CD IAM role"
  value       = module.iam_global.cicd_role_name
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD IAM role"
  value       = module.iam_global.cicd_role_arn
}

output "environment_developer_roles" {
  description = "Map of environment names to developer role ARNs"
  value       = module.iam_global.environment_developer_roles
}