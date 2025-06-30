# Import shared locals by reading the shared module outputs
locals {
  # Global-specific overrides
  global_tags = {
    Project      = "greenroom"
    Client       = "track-c"
    Organization = "ttl"
    ManagedBy    = "terraform"
    Scope        = "global"
  }

  # Global IAM naming
  cicd_role_name        = "ttl-greenroom-terraform-cicd-role"
  developer_group_name  = "ttl-greenroom-developers"

  # State backend configuration
  state_bucket_name = "ttl-greenroom-terraform-state"
  state_lock_table  = "ttl-greenroom-terraform-locks"

  # Environment configuration
  environments = ["dev", "staging", "production"]
}