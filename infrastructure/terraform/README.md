# Terraform Infrastructure

This repository contains the Terraform infrastructure code for our AWS-based application across multiple environments.

## Project Structure

```
infrastructure/terraform/
├── global/                   # Global AWS resources (IAM, etc.)
├── environments/
│   ├── dev/                 # Development environment
│   ├── staging/             # Staging environment
│   └── production/          # Production environment
├── modules/
│   ├── iam-global/          # Global IAM users, roles, groups
│   ├── networking/          # VPC, subnets, security groups
│   ├── compute/             # EC2, ECS, Lambda resources
│   └── storage/             # S3, RDS, ElastiCache resources
└── shared/                  # Shared configurations and variables
```

## Environments

- **Development**: For feature development and testing
- **Staging**: Pre-production environment for integration testing
- **Production**: Live production environment

Each environment is deployed to a configurable AWS region and maintains separate state files.

## Global Resources

Global resources include:

- IAM users, roles, and groups
- CI/CD IAM roles for Terraform automation
- Cross-environment shared resources

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0
3. Access to AWS account with appropriate permissions

## Usage

### Initial Setup

1. **Bootstrap Global Resources**:

   ```bash
   cd global/
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Environment**:

   ```bash
   cd environments/dev/  # or staging/production
   terraform init
   terraform plan
   terraform apply
   ```

### CI/CD

The project includes IAM roles specifically designed for CI/CD pipelines:

- `terraform-cicd-role`: For automated Terraform operations
- Environment-specific roles with least privilege access

## State Management

- Remote state storage using S3
- State locking with DynamoDB
- Separate state files per environment
- Encrypted state files

## Security Best Practices

- Least privilege IAM policies
- No hardcoded credentials
- Encrypted resources where applicable
- Regular security reviews

## Contributing

1. Create feature branch
2. Test changes in development environment
3. Submit pull request for review
4. Deploy through staging before production
