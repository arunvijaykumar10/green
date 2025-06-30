#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

# Check if username is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <username>"
    echo "Example: $0 john.doe"
    exit 1
fi

USERNAME=$1
DEV_DIR="${TERRAFORM_DIR}/developers/${USERNAME}"

# Check if developer directory exists
if [ ! -d "$DEV_DIR" ]; then
    echo "Error: Developer directory not found: $DEV_DIR"
    exit 1
fi

# Change to developer directory
cd "$DEV_DIR" || exit 1

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Import IAM user
echo "Importing IAM user: $USERNAME"
terraform import module.developer.aws_iam_user.developer "$USERNAME"

# Import login profile if it exists
if aws iam get-login-profile --user-name "$USERNAME" &>/dev/null; then
    echo "Importing login profile for: $USERNAME"
    terraform import module.developer.aws_iam_user_login_profile.developer "$USERNAME"
fi

# Import self-management policy
echo "Importing self-management policy for: $USERNAME"
terraform import module.developer.aws_iam_user_policy.self_management "$USERNAME:SelfManagement"

# Import groups and group memberships
for env in "dev" "staging" "prod"; do
    GROUP_NAME="ttl-greenroom-${env}-developer-group"
    if aws iam get-group --group-name "$GROUP_NAME" &>/dev/null; then
        echo "Importing group: $GROUP_NAME"
        terraform import "module.developer.aws_iam_group.developer_groups[\"${env}\"]" "$GROUP_NAME"

        echo "Importing group membership for: $GROUP_NAME"
        terraform import "module.developer.aws_iam_user_group_membership.developer_groups[\"${env}\"]" "$USERNAME/$GROUP_NAME"

        # Import group policy attachments
        echo "Importing group policy attachment for: $GROUP_NAME"
        terraform import "module.developer.aws_iam_group_policy_attachment.developer_policies[\"${env}\"]" "$GROUP_NAME/arn:aws:iam::aws:policy/PowerUserAccess"
    fi
done

echo "Import completed for developer: $USERNAME"
echo "Run 'terraform plan' to verify the import and check for any differences"