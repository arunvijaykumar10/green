output "terraform_state_bucket" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_lock_table" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "cicd_role_name" {
  description = "Name of the CI/CD IAM role"
  value       = aws_iam_role.cicd_role.name
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD IAM role"
  value       = aws_iam_role.cicd_role.arn
}

output "environment_developer_roles" {
  description = "Map of environment names to developer role ARNs"
  value       = { for env, role in aws_iam_role.environment_developer_roles : env => role.arn }
}