locals {
  name_prefix = "${var.organization}-${var.project_name}"
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current AWS partition
data "aws_partition" "current" {}

# ==============================================================================
# State Backend Resources (S3 and DynamoDB)
# ==============================================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket

  tags = merge(var.common_tags, {
    Name        = var.terraform_state_bucket
    Description = "Terraform state storage"
    Purpose     = "terraform-backend"
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.terraform_state_lock_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name        = var.terraform_state_lock_table
    Description = "Terraform state locking"
    Purpose     = "terraform-backend"
  })
}

# ==============================================================================
# CI/CD IAM Role and Policies
# ==============================================================================

# Trust policy for CI/CD role
data "aws_iam_policy_document" "cicd_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  # Allow trusted CI/CD principals (like GitHub Actions) if provided
  dynamic "statement" {
    for_each = length(var.trusted_cicd_principals) > 0 ? [1] : []
    content {
      effect = "Allow"
      principals {
        type        = "Federated"
        identifiers = var.trusted_cicd_principals
      }
      actions = ["sts:AssumeRoleWithWebIdentity"]
    }
  }
}

resource "aws_iam_role" "cicd_role" {
  name               = var.cicd_role_name
  assume_role_policy = data.aws_iam_policy_document.cicd_trust_policy.json

  tags = merge(var.common_tags, {
    Name        = var.cicd_role_name
    Description = "Role for CI/CD Terraform operations"
    Purpose     = "cicd"
  })
}

# CI/CD policy for Terraform operations
data "aws_iam_policy_document" "cicd_policy" {
  # Full access to manage infrastructure
  statement {
    sid = "TerraformOperations"
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cicd_policy" {
  name        = "${local.name_prefix}-cicd-policy"
  description = "Policy for CI/CD Terraform operations"
  policy      = data.aws_iam_policy_document.cicd_policy.json

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "cicd_role" {
  role       = aws_iam_role.cicd_role.name
  policy_arn = aws_iam_policy.cicd_policy.arn
}

# ==============================================================================
# Environment-specific Developer Roles
# ==============================================================================

# Create developer roles for each environment
resource "aws_iam_role" "environment_developer_roles" {
  for_each = toset(var.environments)

  name = "${local.name_prefix}-${each.key}-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "aws:PrincipalType" = "User"
          }
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name        = "${local.name_prefix}-${each.key}-developer-role"
    Environment = each.key
    Description = "Developer role for ${each.key} environment"
    Purpose     = "development"
  })
}

# Environment-specific developer policies
data "aws_iam_policy_document" "environment_developer_policy" {
  for_each = toset(var.environments)

  # Full access to environment-specific resources
  statement {
    sid = "EnvironmentResourceAccess"
    effect = "Allow"
    actions = [
      "ec2:*",
      "s3:*",
      "rds:*",
      "cloudwatch:*",
      "logs:*",
      "lambda:*",
      "ecs:*",
      "secretsmanager:*",
      "ssm:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:RequestedRegion"
      values   = ["*"]
    }
  }

  # Limited IAM access for environment-specific roles
  statement {
    sid = "LimitedIAMAccess"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:PassRole"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-${each.key}-*"
    ]
  }

  # Deny access to production resources for non-production environments
  dynamic "statement" {
    for_each = each.key != "production" ? [1] : []
    content {
      sid = "DenyProductionAccess"
      effect = "Deny"
      actions = ["*"]
      resources = ["*"]
      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/Environment"
        values   = ["production"]
      }
    }
  }
}

resource "aws_iam_policy" "environment_developer_policies" {
  for_each = toset(var.environments)

  name        = "${local.name_prefix}-${each.key}-developer-policy"
  description = "Policy for developers in ${each.key} environment"
  policy      = data.aws_iam_policy_document.environment_developer_policy[each.key].json

  tags = merge(var.common_tags, {
    Environment = each.key
  })
}

resource "aws_iam_role_policy_attachment" "environment_developer_roles" {
  for_each = toset(var.environments)

  role       = aws_iam_role.environment_developer_roles[each.key].name
  policy_arn = aws_iam_policy.environment_developer_policies[each.key].arn
}