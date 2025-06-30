# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-${var.environment}"

  # User attributes
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  # Username configuration
  username_configuration {
    case_sensitive = false
  }

  # Password policy
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = var.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_only_remembered_on_user_prompt
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Verification message template
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your Greenroom account"
    email_message        = "Your Greenroom verification code is {####}"
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Lambda triggers (if provided)
  dynamic "lambda_config" {
    for_each = length(var.lambda_triggers) > 0 ? [1] : []
    content {
      create_auth_challenge          = lookup(var.lambda_triggers, "create_auth_challenge", null)
      custom_message                 = lookup(var.lambda_triggers, "custom_message", null)
      define_auth_challenge          = lookup(var.lambda_triggers, "define_auth_challenge", null)
      post_authentication            = lookup(var.lambda_triggers, "post_authentication", null)
      post_confirmation              = lookup(var.lambda_triggers, "post_confirmation", null)
      pre_authentication             = lookup(var.lambda_triggers, "pre_authentication", null)
      pre_sign_up                    = lookup(var.lambda_triggers, "pre_sign_up", null)
      pre_token_generation           = lookup(var.lambda_triggers, "pre_token_generation", null)
      user_migration                 = lookup(var.lambda_triggers, "user_migration", null)
      verify_auth_challenge_response = lookup(var.lambda_triggers, "verify_auth_challenge_response", null)
    }
  }

  # Schema for custom attributes
  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.type
      required                 = lookup(schema.value, "required", false)
      mutable                  = lookup(schema.value, "mutable", true)
      developer_only_attribute = lookup(schema.value, "developer_only", false)

      dynamic "string_attribute_constraints" {
        for_each = schema.value.type == "String" ? [1] : []
        content {
          min_length = lookup(schema.value, "min_length", null)
          max_length = lookup(schema.value, "max_length", null)
        }
      }

      dynamic "number_attribute_constraints" {
        for_each = schema.value.type == "Number" ? [1] : []
        content {
          min_value = lookup(schema.value, "min_value", null)
          max_value = lookup(schema.value, "max_value", null)
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-user-pool"
    Type = "cognito-user-pool"
  })
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  count = var.create_domain ? 1 : 0

  domain       = var.domain_name != null ? var.domain_name : "${var.project_name}-${var.environment}-auth"
  user_pool_id = aws_cognito_user_pool.main.id

  # Use custom domain if certificate ARN is provided
  certificate_arn = var.certificate_arn
}

# Cognito User Pool Clients
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.project_name}-${var.environment}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Client configuration
  generate_secret                      = false  # For web/mobile apps
  refresh_token_validity               = var.refresh_token_validity_days
  access_token_validity                = var.access_token_validity_hours
  id_token_validity                    = var.id_token_validity_hours
  prevent_user_existence_errors        = "ENABLED"
  enable_token_revocation              = true
  enable_propagate_additional_user_context_data = false

  # Flows
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  # OAuth configuration (only if callback URLs are provided)
  supported_identity_providers = length(var.callback_urls) > 0 ? ["COGNITO"] : null

  callback_urls = length(var.callback_urls) > 0 ? var.callback_urls : null
  logout_urls   = length(var.logout_urls) > 0 ? var.logout_urls : null

  allowed_oauth_flows                  = length(var.callback_urls) > 0 ? ["code", "implicit"] : null
  allowed_oauth_scopes                 = length(var.callback_urls) > 0 ? ["email", "openid", "profile"] : null
  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0 ? true : false

  # Read and write attributes
  read_attributes  = var.read_attributes
  write_attributes = var.write_attributes

  # Token validity units
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# Additional client for server-to-server communication (API services)
resource "aws_cognito_user_pool_client" "api_client" {
  name         = "${var.project_name}-${var.environment}-api-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Client configuration for server-to-server
  generate_secret                      = true   # For server-to-server
  refresh_token_validity               = var.refresh_token_validity_days
  access_token_validity                = var.access_token_validity_hours
  id_token_validity                    = var.id_token_validity_hours
  prevent_user_existence_errors        = "ENABLED"
  enable_token_revocation              = true

  # Flows for server applications
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # No OAuth flows for server-to-server authentication
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = false

  # All attributes for API access
  read_attributes  = var.read_attributes
  write_attributes = var.write_attributes

  # Token validity units
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# Cognito Identity Pool for AWS service access
resource "aws_cognito_identity_pool" "main" {
  count = var.create_identity_pool ? 1 : 0

  identity_pool_name               = "${var.project_name}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web_client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-identity-pool"
    Type = "cognito-identity-pool"
  })
}

# IAM role for authenticated users
resource "aws_iam_role" "authenticated" {
  count = var.create_identity_pool ? 1 : 0

  name = "${var.project_name}-${var.environment}-cognito-authenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-cognito-authenticated-role"
    Type = "iam-role"
  })
}

# IAM policy for authenticated users to write to S3 uploads bucket
resource "aws_iam_role_policy" "authenticated_s3" {
  count = var.create_identity_pool ? 1 : 0

  name = "${var.project_name}-${var.environment}-cognito-authenticated-s3-policy"
  role = aws_iam_role.authenticated[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::uploads.${var.environment}.greenroom",
          "arn:aws:s3:::uploads.${var.environment}.greenroom/*"
        ]
      }
    ]
  })
}

# Attach identity pool roles
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count = var.create_identity_pool ? 1 : 0

  identity_pool_id = aws_cognito_identity_pool.main[0].id

  roles = {
    "authenticated" = aws_iam_role.authenticated[0].arn
  }
}