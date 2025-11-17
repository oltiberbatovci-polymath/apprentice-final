# Event Planner Application

A full-stack event planning application with a React frontend, Node.js/Express backend, PostgreSQL database, and Redis caching. The application is containerized with Docker and includes comprehensive CI/CD pipelines.

## Project Structure

```
apprentice-final/
├── packages/
│   ├── api/                    # Backend API (Node.js/Express)
│   │   ├── src/
│   │   ├── prisma/
│   │   ├── Dockerfile
│   │   ├── Dockerfile.dev
│   │   └── package.json
│   └── web/                    # Frontend (React/Vite)
│       ├── src/
│       ├── Dockerfile
│       ├── Dockerfile.dev
│       └── package.json
├── terraform/                  # Infrastructure as Code
│   ├── modules/
│   ├── main.tf
│   └── variables.tf
├── .github/workflows/          # CI/CD Pipelines
│   ├── api-pipeline.yml
│   ├── web-pipeline.yml
│   └── terraform-pipeline.yml
├── docker-compose.yml          # Production compose
└── docker-compose.dev.yml      # Development compose
```

## Features

- **Event Management**: Create, view, and manage events
- **RSVP System**: Allow users to respond to events
- **Real-time Updates**: Redis caching for improved performance
- **Rate Limiting**: API rate limiting for security
- **Health Checks**: Built-in health monitoring
- **Responsive UI**: Modern, mobile-friendly interface

## Tech Stack

### Backend
- Node.js with Express
- TypeScript
- PostgreSQL (via Prisma ORM)
- Redis for caching
- Zod for validation
- Express Rate Limit

### Frontend
- React 18
- TypeScript
- Vite
- React Router
- TanStack Query
- Tailwind CSS
- Axios

### Infrastructure
- Docker & Docker Compose
- AWS ECS Fargate
- AWS RDS PostgreSQL
- AWS ElastiCache Redis
- Application Load Balancer
- Terraform for IaC

### CI/CD
- GitHub Actions
- Automated testing
- Security scanning (Trivy, tfsec, Checkov)
- Docker image building and publishing
- Automated deployments

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 20+ (for local development)
- Git

### Running Locally with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd apprentice-final
   ```

2. **Create environment file** (optional)
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run with Docker Compose**

   For production build:
   ```bash
   docker compose up --build
   ```

   For development with hot reload:
   ```bash
   docker compose -f docker-compose.dev.yml up --build
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - API: http://localhost:5000/api
   - Health Check: http://localhost:5000/api/health

### Local Development (without Docker)

#### Backend Setup
```bash
cd packages/api
npm install
cp .env.example .env
# Edit .env with your local PostgreSQL and Redis configuration

# Run migrations
npx prisma migrate dev

# Start development server
npm run dev
```

#### Frontend Setup
```bash
cd packages/web
npm install
cp .env.example .env
# Edit .env with API URL

# Start development server
npm run dev
```

## CI/CD Pipelines

The project includes three automated CI/CD pipelines:

### 1. API Pipeline (`.github/workflows/api-pipeline.yml`)
- Runs on changes to `packages/api/**`
- Lints and tests code
- Security scanning
- Builds and pushes Docker image
- Deploys to environment

### 2. Web Pipeline (`.github/workflows/web-pipeline.yml`)
- Runs on changes to `packages/web/**`
- Lints and type-checks code
- Security scanning
- Builds and pushes Docker image
- Deploys to environment

### 3. Terraform Pipeline (`.github/workflows/terraform-pipeline.yml`)
- Runs on changes to `terraform/**`
- Validates Terraform configuration
- Security scanning with tfsec and Checkov
- Plans infrastructure changes
- Applies changes to AWS

### Required GitHub Secrets

Configure these secrets in your repository settings:

```
AWS_ACCESS_KEY_ID           # AWS credentials
AWS_SECRET_ACCESS_KEY       # AWS credentials
TF_STATE_BUCKET            # S3 bucket for Terraform state
TF_STATE_LOCK_TABLE        # DynamoDB table for state locking
GHCR_REGISTRY              # GitHub Container Registry path
DEPLOY_KEY                 # Deployment credentials
VITE_API_URL               # API URL for frontend (optional)
```

## Infrastructure Deployment

### Using Terraform

1. **Navigate to terraform directory**
   ```bash
   cd terraform
   ```

2. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

3. **Initialize and apply**
   ```bash
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

See [terraform/README.md](terraform/README.md) for detailed instructions.

## API Endpoints

### Health
- `GET /api/health` - Health check endpoint

### Events
- `GET /api/events` - List all events
- `POST /api/events` - Create new event
- `GET /api/events/:id` - Get event by ID
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

### RSVPs
- `POST /api/events/:id/rsvp` - RSVP to event
- `GET /api/events/:id/rsvps` - Get event RSVPs

## Development

### Database Migrations

```bash
cd packages/api

# Create a new migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Open Prisma Studio
npx prisma studio
```

### Building for Production

```bash
# Build API
cd packages/api
npm run build

# Build Web
cd packages/web
npm run build
```

### Running Tests

```bash
# API tests (when implemented)
cd packages/api
npm test

# Web tests (when implemented)
cd packages/web
npm test
```

## Docker Commands

### Production
```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Remove volumes (⚠️ destroys data)
docker compose down -v
```

### Development
```bash
# Start with hot reload
docker compose -f docker-compose.dev.yml up

# Rebuild specific service
docker compose -f docker-compose.dev.yml up --build api

# Execute commands in container
docker compose exec api npx prisma migrate dev
docker compose exec api npx prisma studio
```

## Monitoring and Logs

### CloudWatch (AWS)
- API logs: `/ecs/event-planner-{env}-api`
- Web logs: `/ecs/event-planner-{env}-web`

### Local Docker Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f web
```

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check `DATABASE_URL` in environment variables
- Verify network connectivity between containers

### Redis Connection Issues
- Ensure Redis is running
- Check `REDIS_HOST` and `REDIS_PORT` configuration
- Verify Redis container is healthy

### Docker Build Issues
- Clear Docker cache: `docker system prune -a`
- Remove volumes: `docker volume prune`
- Rebuild without cache: `docker compose build --no-cache`

### Port Already in Use
```bash
# Find process using port
lsof -i :5000  # or :3000, :5432, :6379

# Kill process
kill -9 <PID>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review existing documentation
- Check CI/CD pipeline logs


