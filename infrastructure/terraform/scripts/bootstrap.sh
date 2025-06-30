#!/bin/bash

# Bootstrap script for TTL Greenroom Terraform Infrastructure
# This script helps initialize the Terraform infrastructure

set -e

echo "🚀 TTL Greenroom Infrastructure Bootstrap"
echo "========================================"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
echo "🔍 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
echo "✅ Connected to AWS Account: $AWS_ACCOUNT_ID in region: $AWS_REGION"

# Navigate to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo ""
echo "📁 Working directory: $PROJECT_ROOT"

# Function to deploy global resources with backend migration
deploy_global() {
    echo ""
    echo "🌍 Deploying Global Resources (IAM, S3, DynamoDB)..."
    echo "=================================================="

    cd "$PROJECT_ROOT/global"

    # Check if S3 bucket already exists
    BUCKET_NAME="ttl-greenroom-terraform-state"
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "✅ S3 bucket $BUCKET_NAME already exists. Initializing with remote backend..."
        terraform init
    else
        echo "📦 S3 bucket doesn't exist yet. Creating with local backend first..."

        # Temporarily comment out the backend configuration for initial creation
        if grep -q "backend \"s3\"" main.tf; then
            echo "🔧 Temporarily disabling S3 backend for initial bootstrap..."
            sed -i.bak '/backend "s3"/,/^  }$/s/^/# /' main.tf
        fi

        echo "Initializing Terraform with local backend..."
        terraform init

        echo "Planning deployment..."
        terraform plan

        echo ""
        read -p "Do you want to apply these changes to create the S3 bucket and DynamoDB table? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo "Applying changes..."
            terraform apply -auto-approve
            echo "✅ S3 bucket and DynamoDB table created!"

            # Restore the backend configuration
            echo "🔄 Enabling S3 backend configuration..."
            mv main.tf.bak main.tf 2>/dev/null || true
            sed -i.bak '/backend "s3"/,/^  }$/s/^# //' main.tf
            rm -f main.tf.bak

            # Migrate state to S3
            echo "📦 Migrating state to S3 backend..."
            terraform init -migrate-state -force-copy
            echo "✅ State successfully migrated to S3!"
        else
            echo "❌ Deployment cancelled."
            # Restore the original file
            mv main.tf.bak main.tf 2>/dev/null || true
            exit 1
        fi
    fi

    # Final plan and apply with S3 backend
    echo "Planning final deployment with S3 backend..."
    terraform plan

    echo ""
    read -p "Do you want to apply any remaining changes? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo "Applying changes..."
        terraform apply -auto-approve
        echo "✅ Global resources deployed successfully!"
    else
        echo "✅ Global resources are up to date!"
    fi
}

# Function to deploy environment
deploy_environment() {
    local env=$1
    echo ""
    echo "🏗️  Deploying $env Environment..."
    echo "================================="

    cd "$PROJECT_ROOT/environments/$env"

    echo "Initializing Terraform..."
    terraform init

    echo "Planning deployment..."
    terraform plan

    echo ""
    read -p "Do you want to apply these changes? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo "Applying changes..."
        terraform apply -auto-approve
        echo "✅ $env environment deployed successfully!"
    else
        echo "❌ Deployment cancelled."
        exit 1
    fi
}

# Main execution
echo ""
echo "Select what you want to deploy:"
echo "1) Global resources only"
echo "2) Development environment only (requires global resources)"
echo "3) Staging environment only (requires global resources)"
echo "4) Production environment only (requires global resources)"
echo "5) All environments (global + dev + staging + production)"
echo "6) Everything except production (global + dev + staging)"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        deploy_global
        ;;
    2)
        deploy_environment "dev"
        ;;
    3)
        deploy_environment "staging"
        ;;
    4)
        deploy_environment "production"
        ;;
    5)
        deploy_global
        deploy_environment "dev"
        deploy_environment "staging"
        deploy_environment "production"
        ;;
    6)
        deploy_global
        deploy_environment "dev"
        deploy_environment "staging"
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "🎉 Bootstrap completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Add users to the IAM group: ttl-greenroom-developers"
echo "  2. Configure CI/CD to use the role: ttl-greenroom-terraform-cicd-role"
echo "  3. Review and customize the infrastructure as needed"
echo ""
echo "📚 For more information, see the README.md file"