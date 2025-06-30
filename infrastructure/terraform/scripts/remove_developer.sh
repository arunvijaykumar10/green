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

# Destroy the developer's resources
echo "Destroying resources for developer: $USERNAME"
terraform destroy -auto-approve

# Go back to scripts directory
cd "$SCRIPT_DIR" > /dev/null

# Remove the developer directory
echo "Removing developer directory: $DEV_DIR"
rm -rf "$DEV_DIR"

echo "Developer $USERNAME has been removed successfully!"