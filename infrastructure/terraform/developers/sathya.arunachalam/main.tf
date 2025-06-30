module "developer" {
  source = "/Users/mps/git/ttl/greenroom/infrastructure/terraform/modules/iam-developers"

  email       = var.email
  username    = var.username
  environments = var.environments
}
