# Track C Payroll ("Greenroom")

## Project Overview

Greenroom is a specialized payroll processing solution designed for theatrical productions, with plans to expand into similar entertainment verticals. The platform handles the complex requirements of theatrical payroll, including multi-union management, various payment types, and specialized reporting needs.

## Tech Stack

### Backend

- Ruby on Rails 8.0.2 (API-only mode)
- GraphQL Ruby for API queries
- Active Job with Sidekiq for background processing
- PostgreSQL (RDS) for primary database
- Redis (ElastiCache) for caching and background jobs

### Frontend

- React Router v7 (Remix)
- Express backend for Remix applications
- WebSocket capabilities via Socket.io or WS library
- MUI and MUI X for UI components and theming
- React Context API for state management

### Infrastructure

- AWS as the cloud provider
  - ECS/Fargate for containerized services
  - RDS for PostgreSQL
  - ElastiCache for Redis (separate instances for API, workers, and apps)
  - S3 for file storage
  - CloudFront for CDN
  - ALB for load balancing and routing
  - Cognito for authentication
  - Route53 for DNS management
- Docker for containerization
- Terraform for Infrastructure as Code
- GitHub Actions for CI/CD

## Service Architecture

The application is split into two primary service categories:

### Frontend Service

- Contains the React applications with Express backends
- Deployed to ECS/Fargate
- Exposed via Application Load Balancer

### Backend Service

- Contains the Rails API application with integrated workers
- Leverages Rails Active Job with Sidekiq for background processing
- Deployed to ECS/Fargate
- API endpoints exposed via ALB, worker processes not directly exposed

## Real-time Features

The application leverages WebSockets for real-time features:

### WebSocket Implementation

- Express backend for each Remix application
- Socket.io or WS library for WebSocket capabilities
- Centralized socket-client package for shared connection logic

### Real-time Use Cases

- Live payroll processing status updates
- Immediate timesheet approval notifications
- Real-time collaboration on documents
- Instant chat for support and notifications
- Live dashboard metrics updates

### WebSocket Architecture

- Connection management through dedicated socket server
- Authentication and authorization for secure connections
- Channel-based communication for topic isolation
- Fallback mechanisms for clients without WebSocket support

## Project Organization (Monorepo Structure)

```
track-c-monorepo/
├── .github/                    # GitHub configuration
│   └── workflows/              # GitHub Actions workflows
├── apps/                       # Frontend applications
│   ├── admin/                  # Internal admin panel
│   │   ├── app/                # Remix app code
│   │   ├── server/             # Express server
│   │   │   └── socket.js       # WebSocket configuration
│   │   └── ...                 # Other app files
│   ├── client-portal/          # Client-facing portal
│   │   ├── app/                # Remix app code
│   │   ├── server/             # Express server
│   │   │   └── socket.js       # WebSocket configuration
│   │   └── ...                 # Other app files
│   └── employee-portal/        # Employee-facing portal
│       ├── app/                # Remix app code
│       ├── server/             # Express server
│       │   └── socket.js       # WebSocket configuration
│       └── ...                 # Other app files
├── packages/                   # Shared packages/libraries
│   ├── ui-components/          # Shared UI components
│   ├── api-client/             # API client library
│   ├── socket-client/          # WebSocket client library
│   └── utils/                  # Shared utilities
├── services/                   # Backend services
│   └── api/                    # Rails API with integrated workers
│       ├── app/                # Rails application
│       │   ├── controllers/    # API controllers
│       │   ├── jobs/           # Active Job worker definitions
│       │   ├── models/         # Data models
│       │   ├── graphql/        # GraphQL schema and resolvers
│       │   └── ...             # Other app directories
│       ├── config/             # Rails configuration
│       │   ├── initializers/   # Including Sidekiq configuration
│       │   └── ...             # Other config files
│       ├── db/                 # Database migrations/schema
│       ├── Dockerfile          # API Dockerfile
│       └── ...                 # Other Rails directories
├── infrastructure/             # Infrastructure configuration
│   ├── terraform/              # Terraform IaC
│   │   ├── modules/            # Reusable Terraform modules
│   │   ├── environments/       # Environment-specific configs
│   │   └── ...                 # Other Terraform files
│   └── scripts/                # Infrastructure scripts
├── docs/                       # Documentation
│   ├── architecture/           # Architecture docs
│   ├── api/                    # API documentation
│   └── processes/              # Process documentation
├── scripts/                    # Development and build scripts
├── .editorconfig               # Editor configuration
├── .gitignore                  # Git ignore file
├── docker-compose.yml          # Local development setup
└── README.md                   # Main README file
```

## Project Management

- **Notion** for documentation, collaboration, and knowledge management
  - Team wiki and documentation
  - Meeting notes and decisions
  - Reference materials and specifications
  - Onboarding resources
   [Notion Documentation Page](https://www.notion.so/Track-C-Greenroom-Payroll-196f92d5321f80299660fbad784c742b?source=copy_link)

- **Linear** for product development management
  - Product roadmap visualization
  - Sprint planning and ticket management
  - Feature prioritization
  - Bug tracking and resolution
  - Team velocity metrics

## Development Environment Setup

### Prerequisites

- Docker and Docker Compose
- [mise](https://mise.jdx.dev/) for Ruby and Node.js version management
- [pnpm](https://pnpm.io/) for Node.js package management (preferred over npm/yarn)
- AWS CLI
- Terraform CLI

### Version Management with mise

This project uses `mise` for managing Ruby and Node.js versions. After installing mise:

1. Install the required versions:

   ```bash
   mise install
   ```

2. Activate the environment (mise will automatically load versions from `.mise.toml`):

   ```bash
   mise activate
   ```

### Package Management

We use **pnpm** for all Node.js package management due to its efficiency and workspace support:

- **Install pnpm globally** (if not already installed):

  ```bash
  npm install -g pnpm
  ```

- **Why pnpm?**
  - Faster installations with shared dependency storage
  - Better monorepo workspace support
  - Stricter dependency resolution
  - Smaller `node_modules` footprint

### Frontend Tooling

We encourage the use of **Vite** over Webpack for frontend builds due to:

- Faster development server startup
- Hot Module Replacement (HMR) performance
- Better ESM support
- Simpler configuration
- Native TypeScript support

### Local Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/track-c/greenroom.git
   cd greenroom
   ```

2. Set up development environment with mise:

   ```bash
   # Install and activate Ruby and Node.js versions
   mise install
   mise activate
   ```

3. Install dependencies using pnpm:

   ```bash
   # Install shared package dependencies
   cd packages/ui-components && pnpm install && cd ../..
   cd packages/api-client && pnpm install && cd ../..
   cd packages/socket-client && pnpm install && cd ../..
   cd packages/utils && pnpm install && cd ../..

   # Install app dependencies
   cd apps/admin && pnpm install && cd ../..
   cd apps/client-portal && pnpm install && cd ../..
   cd apps/employee-portal && pnpm install && cd ../..

   # Install Rails API dependencies
   cd services/api && bundle install && cd ../..
   ```

4. Set up your environment variables:

   ```bash
   cp .env.example .env
   # Edit .env file with your local configuration
   ```

5. Start the development environment:

   ```bash
   docker-compose up
   ```

6. Set up the database:

   ```bash
   docker-compose exec api rails db:create db:migrate db:seed
   ```

7. Access the applications:
   - Admin Panel: <http://localhost:3001>
   - Client Portal: <http://localhost:3002>
   - Employee Portal: <http://localhost:3003>
   - API: <http://localhost:3000>

## Testing

### Running Tests

```bash
# Run backend tests
docker-compose exec api rails test

# Run frontend tests
cd apps/admin && pnpm test
cd apps/client-portal && pnpm test
cd apps/employee-portal && pnpm test
```

### Test Coverage

```bash
# Generate backend test coverage
docker-compose exec api rails test:coverage

# Generate frontend test coverage
cd apps/admin && pnpm run test:coverage
```

## Git Workflow

We follow a trunk-based development approach with short-lived feature branches:

1. Create a feature branch from `main`:

   ```bash
   git checkout main
   git pull
   git checkout -b feature/description-of-feature
   ```

2. Make your changes and commit regularly:

   ```bash
   git add .
   git commit -m "Descriptive commit message"
   ```

3. Keep your branch up to date with `main`:

   ```bash
   git fetch origin
   git rebase origin/main
   ```

4. Push your branch and create a Pull Request:

   ```bash
   git push -u origin feature/description-of-feature
   ```

5. After code review and CI passes, merge to `main`

### Branch Naming Convention

- `feature/short-description` - For new features
- `fix/short-description` - For bug fixes
- `chore/short-description` - For tasks like dependency updates
- `refactor/short-description` - For code refactoring
- `docs/short-description` - For documentation changes

## CI/CD Pipeline

Our CI/CD pipeline is implemented using GitHub Actions:

### Continuous Integration

- Triggered on every push to a branch and PR to `main`
- Runs linting and code style checks
- Runs automated tests
- Builds Docker images for verification

### Continuous Deployment

- Triggered on merges to `main`
- Builds and tags Docker images
- Pushes images to AWS ECR
- Updates ECS services with new images
- Runs database migrations

### Environment Deployments

- `dev` - Automatic deployment from `main`
- `staging` - Manual trigger from GitHub Actions
- `production` - Manual trigger from GitHub Actions

## Infrastructure and Deployment

### AWS Resources

The application uses the following AWS services:

- **ECS/Fargate** for containerized applications
- **RDS** for PostgreSQL database
- **ElastiCache** for Redis (separate instances for API, workers, and apps)
- **S3** for file storage
- **CloudFront** for CDN
- **ALB** for load balancing and routing
- **Cognito** for authentication
- **Route53** for DNS management (detailed below)

### DNS and Domain Strategy

The application uses Route 53 for DNS management following this domain structure:

#### Development and Staging Environments

- **Development TLD**: `greenroom-dev.tabletoplabs.studio`
- **Staging TLD**: `greenroom.tabletoplabs.studio`
- Each environment has its own dedicated Route 53 zone, VPC, and resources

#### Subdomains Pattern

- API: `api.greenroom.tabletoplabs.studio`
- Admin Portal: `admin.greenroom.tabletoplabs.studio`
- Client Portal: `app.greenroom.tabletoplabs.studio`
- Employee Portal: `employee.greenroom.tabletoplabs.studio`

#### Account Management

- TabletopLabs will create and manage AWS sub-accounts for development and staging environments
- These accounts can later be transferred to Track C or rebuilt in their own cloud environment
- Production TLD is TBD and will be configured in collaboration with Track C

### Terraform

All infrastructure is managed as code using Terraform:

```bash
# Initialize Terraform
cd infrastructure/terraform/environments/dev
terraform init

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### Deployment Process

1. Code is merged to `main`
2. GitHub Actions builds Docker images and pushes to ECR
3. GitHub Actions updates ECS services with new images
4. ECS performs a rolling deployment of new containers
5. Health checks verify successful deployment

## Authentication and Authorization

- AWS Cognito is used for user authentication
- Google Auth is integrated via Cognito for SSO
- JWT tokens are used for API authentication
- Role-based access control is implemented for authorization

## Monitoring and Analytics

- **New Relic** for application performance monitoring (APM) and synthetic SLA monitoring
- **Mixpanel** for user behavior analytics and engagement tracking
- **AWS CloudWatch** for infrastructure monitoring, operational dashboards, and centralized logging
- **Sentry** for error tracking and aggregation

## Additional Resources

- [API Documentation](./docs/api/README.md)
- [Architecture Overview](./docs/architecture/README.md)
- [Development Guidelines](./docs/processes/development-guidelines.md)
- [Production Deployment Checklist](./docs/processes/production-deployment.md)
- [Database Schema](./docs/architecture/database-schema.md)

## License

This project is proprietary and confidential. Unauthorized copying, transferring, or reproduction of the contents of this project, via any medium is strictly prohibited.

© 2025 Track C Payroll
# green
# green
