# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cache-subnet-group"
    Type = "elasticache-subnet-group"
  })
}

# Security Group for ElastiCache
resource "aws_security_group" "elasticache" {
  name_prefix = "${var.project_name}-${var.environment}-cache-"
  description = "Security group for ElastiCache cluster"
  vpc_id      = var.vpc_id

  # Allow Redis/Valkey traffic from allowed security groups
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  # Allow Redis/Valkey traffic from allowed CIDR blocks
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cache-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Parameter Group for Valkey
resource "aws_elasticache_parameter_group" "main" {
  family = var.family
  name   = "${var.project_name}-${var.environment}-cache-params"

  # Valkey-specific parameters
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cache-params"
    Type = "elasticache-parameter-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Replication Group (Valkey)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id         = "${var.project_name}-${var.environment}"
  description                  = "ElastiCache Valkey cluster for ${var.project_name} ${var.environment}"

  # Engine configuration
  engine               = "valkey"
  engine_version       = var.engine_version
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.main.name
  node_type            = var.node_type

  # Cluster configuration
  num_cache_clusters = var.num_cache_nodes

  # Network configuration
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.elasticache.id]

  # Security and backup configuration
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  # Auth token configuration (only if transit encryption is enabled and auth token is provided)
  auth_token = var.transit_encryption_enabled && var.auth_token != null ? var.auth_token : null

  # Backup configuration
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window

  # Maintenance
  maintenance_window          = var.maintenance_window
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.elasticache.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cache"
    Type = "elasticache-replication-group"
  })

  lifecycle {
    ignore_changes = [engine_version]
  }
}

# CloudWatch Log Group for ElastiCache
resource "aws_cloudwatch_log_group" "elasticache" {
  name              = "/elasticache/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cache-logs"
    Type = "cloudwatch-log-group"
  })
}