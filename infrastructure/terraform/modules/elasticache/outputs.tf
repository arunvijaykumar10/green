output "replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "replication_group_arn" {
  description = "ARN of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.arn
}

output "primary_endpoint_address" {
  description = "Address of the endpoint for the primary node in the replication group"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Address of the endpoint for the reader node in the replication group"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "Port of the ElastiCache cluster"
  value       = aws_elasticache_replication_group.main.port
}

output "security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

output "subnet_group_name" {
  description = "Name of the ElastiCache subnet group"
  value       = aws_elasticache_subnet_group.main.name
}

output "parameter_group_name" {
  description = "Name of the ElastiCache parameter group"
  value       = aws_elasticache_parameter_group.main.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ElastiCache"
  value       = aws_cloudwatch_log_group.elasticache.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for ElastiCache"
  value       = aws_cloudwatch_log_group.elasticache.arn
}

# Connection details for applications
output "connection_details" {
  description = "Connection details for applications"
  value = {
    host = aws_elasticache_replication_group.main.primary_endpoint_address
    port = aws_elasticache_replication_group.main.port
  }
  sensitive = false
}