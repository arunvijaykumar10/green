terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  name_prefix = "ttl-greenroom"
}

# Create the IAM user (global)
resource "aws_iam_user" "developer" {
  name = var.username
  path = "/"

  tags = {
    Email = var.email
  }
}

# Add user to specified environment groups
resource "aws_iam_user_group_membership" "developer_groups" {
  for_each = toset(var.environments)
  user     = aws_iam_user.developer.name
  groups   = ["${local.name_prefix}-${each.key}-developer-group"]
}

# Create login profile with auto-generated password
resource "aws_iam_user_login_profile" "developer" {
  user                    = aws_iam_user.developer.name
  password_reset_required = true
  password_length        = 20
}

# Allow user to manage their own credentials
resource "aws_iam_user_policy" "self_management" {
  name = "SelfManagement"
  user = aws_iam_user.developer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:CreateVirtualMFADevice"
        ]
        Resource = "arn:aws:iam::*:user/${aws_iam_user.developer.name}"
      }
    ]
  })
}

# Write password to local file
resource "local_file" "password_file" {
  filename = "${path.module}/../../developers/${var.username}/credentials.txt"
  content  = "Username: ${aws_iam_user.developer.name}\nTemporary Password: ${aws_iam_user_login_profile.developer.password}\n\nPlease change your password on first login."
}