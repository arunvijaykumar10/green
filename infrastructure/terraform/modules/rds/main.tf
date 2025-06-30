locals {
  name_prefix = "${var.organization}-${var.project_name}-${var.environment}"
}

# ==============================================================================
# RDS Security Group
# ==============================================================================

resource "aws_security_group" "rds" {
  name_prefix = "${local.name_prefix}-rds-"
  vpc_id      = var.vpc_id

  # PostgreSQL port from allowed security groups
  dynamic "ingress" {
    for_each = var.allowed_security_groups
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  # PostgreSQL port from allowed CIDR blocks
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # No outbound rules needed for RDS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
    Type = "database"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# RDS Parameter Group
# ==============================================================================

resource "aws_db_parameter_group" "main" {
  family = "postgres17"
  name   = "${local.name_prefix}-postgres17"

  # Dynamic parameters only (can be applied immediately)
  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # Log queries taking longer than 1 second
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  # Note: shared_preload_libraries is a static parameter that requires restart
  # It will be enabled manually after the database is created if needed

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-postgres17-params"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# RDS Instance
# ==============================================================================

resource "aws_db_instance" "main" {
  # Instance identification
  identifier = "${local.name_prefix}-postgres"

  # Engine configuration
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  parameter_group_name = aws_db_parameter_group.main.name

  # Database configuration
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  # Use AWS Secrets Manager for password management (recommended)
  manage_master_user_password = var.manage_master_user_password

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  # IOPS only supported for storage >= 400GB for PostgreSQL
  iops = var.storage_type == "gp3" && var.allocated_storage >= 400 ? var.storage_iops : null

  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot

  # Deletion protection
  deletion_protection   = var.deletion_protection
  skip_final_snapshot   = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Monitoring and logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn            = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Auto minor version updates
  auto_minor_version_upgrade = true

  # Apply changes immediately in non-production environments
  apply_immediately = var.environment != "production"

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-postgres"
    Type = "database"
  })

  depends_on = [aws_db_parameter_group.main]
}

# ==============================================================================
# Enhanced Monitoring IAM Role (if monitoring is enabled)
# ==============================================================================

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${local.name_prefix}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}