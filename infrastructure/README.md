# Greenroom Infrastructure

This directory contains Terraform configurations for the Greenroom project infrastructure using a modular, environment-based approach optimized for containerized applications with full DNS management and authentication.

## Architecture Overview

The infrastructure follows a container-first architecture with comprehensive DNS and authentication:

- **Networking**: VPC with public/private subnets, Application Load Balancer (ALB)
- **DNS Management**: Route 53 with public/private hosted zones and SSL certificates
- **Authentication**: AWS Cognito for centralized user management across all applications
- **Container Registry**: AWS ECR for private container images
- **Compute**: ECS Fargate for serverless container orchestration
- **Database**: Amazon RDS PostgreSQL with automated backups and private DNS
- **Caching**: ElastiCache with Valkey for high-performance caching and private DNS
- **Load Balancing**: Application Load Balancer with SSL termination
- **Monitoring**: CloudWatch for logs and metrics
- **Security**: IAM roles, security groups, and encryption at rest/in transit

## Public Endpoints

Each environment provides these public HTTPS endpoints:

### Development

- **App**: `https://app.greenroom-dev.tabletoplabs.studio`
- **API**: `https://api.greenroom-dev.tabletoplabs.studio`
- **Admin**: `https://admin.greenroom-dev.tabletoplabs.studio`
- **Employee**: `https://employee.greenroom-dev.tabletoplabs.studio`
- **Auth**: `https://auth.greenroom-dev.tabletoplabs.studio`

### Staging

- **App**: `https://app.greenroom.tabletoplabs.studio`
- **API**: `https://api.greenroom.tabletoplabs.studio`
- **Admin**: `https://admin.greenroom.tabletoplabs.studio`
- **Employee**: `https://employee.greenroom.tabletoplabs.studio`
- **Auth**: `https://auth.greenroom.tabletoplabs.studio`

## Internal DNS Resolution

Private services use internal DNS for secure, high-performance connectivity:

- **Database**: `db.greenroom-dev.internal` / `db.greenroom-stage.internal`
- **Cache**: `cache.greenroom-dev.internal` / `cache.greenroom-stage.internal`
- **Load Balancer**: `alb.greenroom-dev.internal` / `alb.greenroom-stage.internal`

## Directory Structure

```
infrastructure/
├── terraform/
│   ├── global/           # Global resources (S3, DynamoDB)
│   ├── shared/           # Shared configurations and data
│   ├── modules/          # Reusable Terraform modules
│   │   ├── networking/   # VPC, subnets, ALB, security groups
│   │   ├── route53/      # DNS management, SSL certificates
│   │   ├── cognito/      # User authentication and authorization
│   │   ├── rds/         # PostgreSQL database
│   │   ├── ecr/         # Container registry
│   │   ├── ecs/         # ECS Fargate cluster and services
│   │   └── elasticache/ # Valkey cache cluster
│   └── environments/    # Environment-specific configurations
│       ├── dev/         # Development environment
│       └── staging/     # Staging environment
└── README.md
```

## Modules

### Networking Module (`modules/networking/`)

Creates the foundational networking infrastructure:

- **VPC**: Virtual Private Cloud with configurable CIDR
- **Subnets**: Public, private, and database subnets across AZs
- **Gateways**: Internet Gateway and NAT Gateway(s) for outbound connectivity
- **Application Load Balancer**: HTTP/HTTPS traffic distribution with SSL termination
- **Security Groups**: Web, database, and default security groups
- **Route Tables**: Proper routing for public and private subnets

Key features:

- Configurable single or multiple NAT gateways
- ALB with health checks and SSL support
- Auto-scaling target groups for ECS integration
- SSL termination at the load balancer level

### Route 53 Module (`modules/route53/`)

Comprehensive DNS management with SSL certificates:

- **Public Hosted Zone**: External DNS resolution for public endpoints
- **Private Hosted Zone**: Internal DNS resolution within VPC
- **SSL Certificates**: Automated ACM certificate creation and validation
- **DNS Records**: CNAME records for all application and service endpoints
- **Auth Integration**: CNAME mapping for Cognito authentication domain

Key features:

- Automatic SSL certificate creation with DNS validation
- Public CNAMEs for app/api/admin/employee subdomains → ALB
- Private CNAMEs for cache/database → direct service endpoints
- Auth subdomain → Cognito hosted UI
- Configurable TTL settings for different record types

### Cognito Module (`modules/cognito/`)

Centralized authentication and user management:

- **User Pool**: Email-based authentication with configurable security policies
- **App Clients**: Separate clients for web applications and API services
- **Hosted UI**: Auto-generated authentication domain with custom branding
- **Security Features**: MFA, advanced security monitoring, password policies
- **OAuth Support**: Full OAuth 2.0/OIDC flows with callback/logout URLs

Key features:

- Environment-specific user pools for isolation
- Configurable password policies and MFA settings
- Web client for frontend applications (no client secret)
- API client for backend services (with client secret)
- Integration with Route 53 for branded auth subdomain
- Automatic environment variable injection into ECS containers

### RDS Module (`modules/rds/`)

Manages PostgreSQL database infrastructure:

- **Instance**: Configurable PostgreSQL instance with auto-scaling storage
- **Security**: Security groups and parameter groups
- **Backup**: Automated backups with configurable retention
- **Monitoring**: CloudWatch logs and Performance Insights
- **High Availability**: Multi-AZ deployment options
- **DNS Integration**: Private DNS record for internal connectivity

Key features:

- AWS Secrets Manager integration for password management
- GP3 storage with unlimited autoscaling
- Configurable backup and maintenance windows
- Internal DNS resolution via `db.{environment}.internal`

### ECR Module (`modules/ecr/`)

Container registry for application images:

- **Repository**: Private ECR repository with encryption
- **Lifecycle**: Automated image cleanup policies
- **Security**: Vulnerability scanning on push
- **Access Control**: IAM-based repository policies

Key features:

- Configurable image mutability (MUTABLE/IMMUTABLE)
- Lifecycle policies for cost optimization
- Integration with ECS for seamless deployments

### ElastiCache Module (`modules/elasticache/`)

High-performance caching with Valkey (Redis-compatible):

- **Cache Cluster**: Valkey cluster configuration with VPC integration
- **Security**: Encryption at rest and in transit with security groups
- **Monitoring**: CloudWatch logs and metrics
- **Backup**: Automated snapshots with configurable retention
- **DNS Integration**: Private DNS record for internal connectivity

Key features:

- Single-node or clustered configurations
- Parameter groups for performance tuning
- Subnet groups for VPC placement
- CloudWatch integration for monitoring
- Internal DNS resolution via `cache.{environment}.internal`

### ECS Module (`modules/ecs/`)

Container orchestration with ECS Fargate:

- **Cluster**: ECS cluster with Container Insights
- **Service**: Auto-scaling ECS service with rolling deployments
- **Task Definition**: Container specifications with comprehensive environment variables
- **IAM**: Execution and task roles with appropriate permissions
- **Auto Scaling**: CPU and memory-based auto-scaling policies
- **Integration**: Full integration with Cognito, RDS, and ElastiCache

Key features:

- Serverless Fargate compute for cost efficiency
- Integration with ALB for load balancing
- Auto-scaling based on CloudWatch metrics
- Secrets Manager integration for sensitive data
- Automatic injection of all service connection details

## Environments

### Development (`environments/dev/`)

Optimized for development and cost efficiency:

- **RDS**: `db.t4g.micro` instance with minimal storage and 1-day backups
- **ECS**: 256 CPU, 512MB memory, single task (1-3 scaling)
- **Cache**: `cache.t4g.micro` single node with minimal snapshots
- **Networking**: Single NAT gateway for cost optimization
- **Cognito**: MFA disabled, audit security mode for easier development
- **DNS**: Short TTL for quick testing iterations

### Staging (`environments/staging/`)

Production-like configuration for testing:

- **RDS**: `db.t4g.small` instance with 7-day backups and deletion protection
- **ECS**: 512 CPU, 1024MB memory, 2 tasks (1-6 scaling)
- **Cache**: `cache.t4g.small` single node with encryption in transit
- **Networking**: Multiple NAT gateways for high availability
- **Cognito**: MFA required, enforced security mode for production-like testing
- **DNS**: Standard TTL for realistic performance testing

## Application Integration

### Environment Variables

ECS containers automatically receive comprehensive environment variables:

```bash
# Database Connection (via internal DNS)
DB_HOST=db.greenroom-dev.internal
DB_PORT=5432

# Cache Connection (via internal DNS)
CACHE_HOST=cache.greenroom-dev.internal
CACHE_PORT=6379

# Cognito Authentication
COGNITO_USER_POOL_ID=us-east-2_xxxxxxxxx
COGNITO_WEB_CLIENT_ID=xxxxxxxxxxxxxxxxx
COGNITO_API_CLIENT_ID=xxxxxxxxxxxxxxxxx
COGNITO_REGION=us-east-2
COGNITO_DOMAIN=greenroom-dev-auth
AUTH_BASE_URL=https://greenroom-dev-auth.auth.us-east-2.amazoncognito.com

# Custom application variables
NODE_ENV=development
LOG_LEVEL=debug
PORT=3000
```

### Authentication Integration

Applications can integrate with Cognito using the provided configuration:

```javascript
// Frontend (Web Client)
const cognitoConfig = {
  userPoolId: process.env.COGNITO_USER_POOL_ID,
  userPoolWebClientId: process.env.COGNITO_WEB_CLIENT_ID,
  region: process.env.COGNITO_REGION,
  authDomain: process.env.AUTH_BASE_URL
};

// Backend (API Client)
const cognitoApiConfig = {
  userPoolId: process.env.COGNITO_USER_POOL_ID,
  clientId: process.env.COGNITO_API_CLIENT_ID,
  region: process.env.COGNITO_REGION
};
```

### Database Connection

Access PostgreSQL using internal DNS:

```javascript
const dbConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: 'greenroom',
  // Credentials from AWS Secrets Manager
};
```

### Cache Connection

Connect to Valkey cache using internal DNS:

```javascript
const redisConfig = {
  host: process.env.CACHE_HOST,
  port: process.env.CACHE_PORT,
  // Redis-compatible commands
};
```

## Security

- **Network Isolation**: Private subnets for application and database tiers
- **DNS Security**: Private hosted zone for internal service discovery
- **Authentication**: Centralized user management with configurable security policies
- **Encryption**: At-rest and in-transit encryption for all data stores
- **IAM**: Role-based access with minimal permissions
- **Secrets Management**: AWS Secrets Manager for sensitive data
- **SSL/TLS**: End-to-end encryption with automated certificate management

## Monitoring

- **CloudWatch Logs**: Centralized logging for all services
- **Container Insights**: ECS cluster and service metrics
- **Performance Insights**: Database query performance monitoring
- **Auto Scaling Metrics**: CPU and memory utilization tracking
- **DNS Monitoring**: Route 53 health checks and query logging
- **Authentication Monitoring**: Cognito user activity and security events

## Deployment Workflow

1. **Build Container**:

   ```bash
   docker build -t greenroom-app .
   ```

2. **Push to ECR**:

   ```bash
   aws ecr get-login-password --region us-east-2 | \
     docker login --username AWS --password-stdin <ecr_repository_url>
   docker tag greenroom-app:latest <ecr_repository_url>:latest
   docker push <ecr_repository_url>:latest
   ```

3. **Update ECS Service**:

   ```bash
   aws ecs update-service --cluster <cluster_name> --service <service_name> --force-new-deployment
   ```

4. **Access Applications**:
   - **Public URLs**: Use the branded domain endpoints
   - **Authentication**: Direct users to the auth subdomain
   - **APIs**: Use internal DNS for service-to-service communication

## Cost Optimization

- **Development**: Minimal instance sizes and single-node configurations
- **Staging**: Balanced performance and cost with right-sized instances
- **Auto Scaling**: Dynamic resource allocation based on demand
- **Storage**: GP3 with unlimited autoscaling for cost-effective growth
- **DNS**: Efficient TTL settings to minimize query costs
- **NAT Gateways**: Single gateway in dev, multiple in staging for HA

## Getting Started

1. **Initialize Global Resources**:

   ```bash
   cd terraform/global
   terraform init
   terraform apply
   ```

2. **Deploy Environment**:

   ```bash
   cd ../environments/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars as needed
   terraform init
   terraform apply
   ```

3. **Configure DNS** (if using external domain):
   - Update your domain's nameservers to use Route 53
   - Or create CNAME records pointing to the provided endpoints

4. **Build and Deploy Container**:

   ```bash
   # Get ECR repository URL from Terraform outputs
   ECR_URL=$(terraform output -raw ecr_repository_url)

   # Login and push
   aws ecr get-login-password --region us-east-2 | \
     docker login --username AWS --password-stdin $ECR_URL
   docker build -t greenroom-app .
   docker tag greenroom-app:latest $ECR_URL:latest
   docker push $ECR_URL:latest
   ```

5. **Access Your Application**:

   ```bash
   # Get all endpoints
   terraform output deployment_info
   ```

## Authentication Setup

1. **Access Cognito Console**: Use the provided auth URL or AWS Console
2. **Create Test Users**: Add users for testing via Cognito User Pool
3. **Configure Applications**: Use the provided client IDs and endpoints
4. **Test Authentication**: Verify login flows work across all applications

## Next Steps

- Configure application-specific monitoring and alerting
- Set up CI/CD pipeline for automated deployments
- Implement blue-green deployment strategies
- Add WAF and additional security layers for production
- Configure custom Cognito triggers for advanced authentication flows
- Set up DNS health checks and failover routing
