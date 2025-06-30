#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

# Check if required arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <email> <username> <environments...>"
    echo "Example: $0 john.doe@example.com john.doe dev staging"
    exit 1
fi

EMAIL=$1
USERNAME=$2
shift 2
ENVIRONMENTS=("$@")

# Validate environments
VALID_ENVS=("dev" "staging" "prod")
for env in "${ENVIRONMENTS[@]}"; do
    if [[ ! " ${VALID_ENVS[@]} " =~ " ${env} " ]]; then
        echo "Error: Invalid environment '$env'. Must be one of: ${VALID_ENVS[*]}"
        exit 1
    fi
done

# Create developer directory
DEV_DIR="${TERRAFORM_DIR}/developers/${USERNAME}"
mkdir -p "$DEV_DIR"

# Format environments list for Terraform
ENVIRONMENTS_LIST="["
for env in "${ENVIRONMENTS[@]}"; do
    if [ "$ENVIRONMENTS_LIST" != "[" ]; then
        ENVIRONMENTS_LIST="${ENVIRONMENTS_LIST}, "
    fi
    ENVIRONMENTS_LIST="${ENVIRONMENTS_LIST}\"${env}\""
done
ENVIRONMENTS_LIST="${ENVIRONMENTS_LIST}]"

# Create variables.tf
cat > "$DEV_DIR/variables.tf" << EOF
variable "email" {
  description = "Developer's email address"
  type        = string
  default     = "${EMAIL}"
}

variable "username" {
  description = "Developer's username"
  type        = string
  default     = "${USERNAME}"
}

variable "environments" {
  description = "List of environments the developer should have access to"
  type        = list(string)
  default     = ${ENVIRONMENTS_LIST}

  validation {
    condition     = alltrue([for env in var.environments : contains(["dev", "staging", "prod"], env)])
    error_message = "Environments must be one of: dev, staging, prod"
  }
}
EOF

# Create main.tf
cat > "$DEV_DIR/main.tf" << EOF
module "developer" {
  source = "${TERRAFORM_DIR}/modules/iam-developers"

  email       = var.email
  username    = var.username
  environments = var.environments
}
EOF

# Create terraform.tfvars
cat > "$DEV_DIR/terraform.tfvars" << EOF
email       = "${EMAIL}"
username    = "${USERNAME}"
environments = ${ENVIRONMENTS_LIST}
EOF

# Create .gitignore
cat > "$DEV_DIR/.gitignore" << EOF
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
credentials.txt
EOF

echo "Created developer configuration in $DEV_DIR"
echo "To apply the configuration:"
echo "cd $DEV_DIR"
echo "terraform init"
echo "terraform plan"
echo "terraform apply"