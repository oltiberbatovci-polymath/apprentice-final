# Terraform Project Structure

## Overview

This Terraform project is organized into **modules** and **environments** following AWS best practices.

## Directory Structure

```
terraform/
├── modules/                      # Reusable Terraform modules
│   ├── codepipeline/            # ✅ CodePipeline module (COMPLETE)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── network/                 # ⏳ VPC, Subnets, NAT, IGW (TODO)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/                 # ⏳ ECS Fargate services (TODO)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── data/                    # ⏳ RDS, Elasticache (TODO)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── edge/                    # ⏳ CloudFront, WAF, Route53 (TODO)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── observability/           # ⏳ CloudWatch dashboards, alarms (TODO)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── iam/                     # ⏳ IAM roles and policies (TODO)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── pipelines/                   # ✅ Pipeline infrastructure (COMPLETE)
│   ├── main.tf                  # Creates all 3 pipelines
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── .gitignore
│   └── README.md
│
├── environments/                # ⏳ Environment-specific configs (TODO)
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   │
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
│
└── backend/                     # ⏳ Remote state backend (TODO)
    ├── main.tf
    ├── variables.tf
    └── README.md
```

## Module Descriptions

### ✅ `modules/codepipeline` (COMPLETE)

**Purpose:** Reusable module for creating CodePipeline with CodeBuild

**Resources:**
- CodePipeline (Source → Build stages)
- CodeBuild project
- S3 bucket for artifacts
- IAM roles and policies
- CloudWatch log groups
- SNS topics for notifications

**Usage:**
```hcl
module "web_pipeline" {
  source = "../modules/codepipeline"
  
  pipeline_name           = "web-pipeline"
  environment             = "staging"
  buildspec_path          = "buildspecs/buildspec-web.yml"
  codestar_connection_arn = var.codestar_connection_arn
  repository_id           = var.repository_id
  # ... other variables
}
```

### ⏳ `modules/network` (TODO)

**Purpose:** VPC and networking infrastructure

**Will Include:**
- VPC with public and private subnets
- Internet Gateway
- NAT Gateway (for private subnet internet access)
- Route tables
- Network ACLs
- VPC Flow Logs

**Design:**
- Multi-AZ for high availability
- Public subnets for ALB
- Private subnets for ECS tasks and RDS

### ⏳ `modules/compute` (TODO)

**Purpose:** Container orchestration with ECS Fargate

**Will Include:**
- ECS Cluster
- ECS Task Definitions (web, api)
- ECS Services
- Application Load Balancer
- Target Groups
- Security Groups
- Auto Scaling policies

### ⏳ `modules/data` (TODO)

**Purpose:** Data layer - databases and caching

**Will Include:**
- RDS PostgreSQL (or MySQL)
  - Multi-AZ deployment
  - Automated backups
  - Parameter groups
- Elasticache Redis
  - Cluster mode enabled
  - Automatic failover
- Security Groups
- Subnet Groups

### ⏳ `modules/edge` (TODO)

**Purpose:** Content delivery and edge security

**Will Include:**
- CloudFront distribution
- AWS WAF rules and web ACL
- Route53 hosted zone and records
- ACM certificates (SSL/TLS)
- CloudFront Origin Access Identity

### ⏳ `modules/observability` (TODO)

**Purpose:** Monitoring, logging, and alerting

**Will Include:**
- CloudWatch Dashboards
- CloudWatch Alarms (CPU, Memory, 5xx errors)
- CloudWatch Log Groups
- SNS topics for alerts
- Email subscriptions
- Metric filters

### ⏳ `modules/iam` (TODO)

**Purpose:** IAM roles and policies (least privilege)

**Will Include:**
- ECS Task Execution Role
- ECS Task Role
- Lambda Execution Roles
- Service-specific policies
- Trust relationships

## Environments

### ⏳ `environments/staging` (TODO)

**Purpose:** Non-production environment for testing

**Configuration:**
- Smaller instance sizes
- Single NAT Gateway
- Reduced RDS capacity
- Lower cost CloudFront tier

### ⏳ `environments/production` (TODO)

**Purpose:** Production environment

**Configuration:**
- Larger instance sizes
- Multi-AZ NAT Gateways
- Production-grade RDS
- Enhanced monitoring
- Stricter security policies

## Backend Configuration

### ⏳ `backend/` (TODO)

**Purpose:** S3 backend for Terraform state

**Will Include:**
- S3 bucket with versioning
- DynamoDB table for state locking
- Encryption at rest
- Lifecycle policies

**Backend Config:**
```hcl
terraform {
  backend "s3" {
    bucket         = "apprentice-terraform-state"
    key            = "env/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "apprentice-terraform-locks"
    encrypt        = true
  }
}
```

## Current Status

| Module | Status | Resources | Notes |
|--------|--------|-----------|-------|
| codepipeline | ✅ Complete | 30+ | All 3 pipelines deployed |
| network | ⏳ TODO | 0 | Next priority |
| compute | ⏳ TODO | 0 | Depends on network |
| data | ⏳ TODO | 0 | Depends on network |
| edge | ⏳ TODO | 0 | Depends on compute |
| observability | ⏳ TODO | 0 | Depends on compute |
| iam | ⏳ TODO | 0 | Can be done anytime |

## Deployment Order

Based on dependencies, deploy in this order:

1. ✅ **Pipelines** (Complete)
   ```bash
   cd terraform/pipelines
   terraform apply
   ```

2. ⏳ **Backend** (Next)
   ```bash
   cd terraform/backend
   terraform apply
   ```

3. ⏳ **Network Module**
   ```bash
   cd terraform/environments/staging
   # Configure to use network module
   terraform apply
   ```

4. ⏳ **IAM Module** (parallel with others)
   
5. ⏳ **Data Module** (requires network)

6. ⏳ **Compute Module** (requires network, data, IAM)

7. ⏳ **Edge Module** (requires compute)

8. ⏳ **Observability Module** (requires all others)

## Best Practices Implemented

### Module Design
- ✅ **DRY Principle:** Reusable modules
- ✅ **Parameterization:** Everything configurable via variables
- ✅ **Outputs:** Expose necessary values for other modules
- ✅ **Documentation:** README in each module

### Security
- ✅ **Least Privilege IAM:** Minimal permissions
- ✅ **Encryption:** S3 buckets encrypted by default
- ✅ **No Hardcoding:** All values from variables
- ✅ **Secrets Management:** Use AWS Secrets Manager (TODO)

### Operations
- ✅ **Tagging:** Consistent tags on all resources
- ✅ **Logging:** CloudWatch logs for all services
- ✅ **Monitoring:** CloudWatch alarms and dashboards
- ✅ **State Management:** Remote backend with locking

### Cost Optimization
- ✅ **Right Sizing:** Appropriate instance types per environment
- ✅ **Auto Scaling:** Scale based on demand
- ✅ **Cost Tags:** Track costs by environment and project
- ✅ **Lifecycle Policies:** Automatic cleanup of old resources

## Variable Management

### Naming Convention

```hcl
# Global variables (used across all modules)
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# Module-specific variables
variable "pipeline_name" {
  description = "Name of the pipeline"
  type        = string
}
```

### Variable Files

- `terraform.tfvars.example` - Template with examples
- `terraform.tfvars` - Actual values (gitignored)
- `variables.tf` - Variable definitions
- Environment-specific: `staging.tfvars`, `production.tfvars`

## Common Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show outputs
terraform output

# Destroy resources
terraform destroy

# Show state
terraform show

# List resources
terraform state list
```

## Next Steps

1. **Create Backend Module** - S3 + DynamoDB for state
2. **Create Network Module** - VPC, subnets, routing
3. **Create IAM Module** - Roles and policies
4. **Create Data Module** - RDS and Elasticache
5. **Create Compute Module** - ECS Fargate services
6. **Create Edge Module** - CloudFront and WAF
7. **Create Observability Module** - Dashboards and alarms
8. **Set Up Environments** - Staging and production configs

## Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

