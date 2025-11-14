# CodePipeline Infrastructure

This directory contains Terraform configurations for three separate AWS CodePipelines:

1. **Web Pipeline** - Build and deploy the frontend application
2. **API Pipeline** - Build and deploy the backend API
3. **Infrastructure Pipeline** - Validate and deploy Terraform infrastructure

## Architecture

Each pipeline consists of:
- **Source Stage**: Pulls code from GitHub using CodeStar Connections
- **Build Stage**: Runs CodeBuild with specific buildspec files
- **Artifacts**: Stored in dedicated S3 buckets
- **Notifications**: SNS topics for pipeline events
- **Logging**: CloudWatch Logs for build output

## Prerequisites

Before deploying these pipelines, you need:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** (>= 1.5.0) installed
4. **GitHub Repository** with your code
5. **CodeStar Connection** to GitHub (see setup below)

## Initial Setup

### Step 1: Create CodeStar Connection

The pipelines need a connection to your GitHub repository. You must create this manually in the AWS Console first:

1. Go to AWS Console → **Developer Tools** → **Settings** → **Connections**
2. Click **Create connection**
3. Choose **GitHub**
4. Name it (e.g., `apprentice-github-connection`)
5. Complete the GitHub authorization flow
6. Copy the Connection ARN (you'll need this for terraform.tfvars)

The ARN will look like:
```
arn:aws:codestar-connections:us-east-1:123456789012:connection/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Step 2: Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   # AWS Configuration
   aws_region  = "us-east-1"
   environment = "staging"

   # Project Information
   project_name = "ApprenticeFinal"
   owner        = "YourName"

   # GitHub Configuration (from Step 1)
   codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:123456789012:connection/xxx"
   repository_id           = "your-github-username/apprentice-final"
   branch_name             = "main"
   ```

### Step 3: Initialize Terraform

```bash
cd terraform/pipelines
terraform init
```

### Step 4: Review the Plan

```bash
terraform plan
```

This will show you all the resources that will be created:
- 3 CodePipelines
- 3 CodeBuild Projects
- 3 S3 Buckets for artifacts
- IAM Roles and Policies
- CloudWatch Log Groups
- SNS Topics for notifications
- CloudWatch Event Rules

### Step 5: Deploy the Pipelines

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Pipeline Details

### Web Pipeline

- **Name**: `web-pipeline-staging`
- **Buildspec**: `buildspecs/buildspec-web.yml`
- **Purpose**: Build the React frontend application
- **Build Image**: `aws/codebuild/standard:7.0`
- **Timeout**: 30 minutes

### API Pipeline

- **Name**: `api-pipeline-staging`
- **Buildspec**: `buildspecs/buildspec-api.yml`
- **Purpose**: Build the Node.js/TypeScript API
- **Build Image**: `aws/codebuild/standard:7.0`
- **Timeout**: 30 minutes

### Infrastructure Pipeline

- **Name**: `infrastructure-pipeline-staging`
- **Buildspec**: `buildspecs/buildspec-infrastructure.yml`
- **Purpose**: Validate Terraform configurations
- **Build Image**: `hashicorp/terraform:1.6`
- **Timeout**: 45 minutes

## Monitoring & Notifications

### CloudWatch Logs

Each pipeline logs to its own CloudWatch Log Group:
- `/aws/codebuild/web-pipeline-staging`
- `/aws/codebuild/api-pipeline-staging`
- `/aws/codebuild/infrastructure-pipeline-staging`

Log retention is set to **7 days** by default.

### SNS Notifications

Each pipeline has an SNS topic that receives notifications for:
- Pipeline execution started
- Pipeline execution succeeded
- Pipeline execution failed

To receive email notifications:

1. Get the SNS topic ARN from Terraform outputs:
   ```bash
   terraform output web_sns_topic_arn
   ```

2. Subscribe to the topic:
   ```bash
   aws sns subscribe \
     --topic-arn <SNS_TOPIC_ARN> \
     --protocol email \
     --notification-endpoint your-email@example.com
   ```

3. Confirm the subscription via email

## Viewing Pipeline Status

### AWS Console

1. Go to **AWS Console** → **Developer Tools** → **CodePipeline**
2. You'll see three pipelines listed
3. Click on any pipeline to see execution history and logs

### AWS CLI

```bash
# List all pipelines
aws codepipeline list-pipelines

# Get pipeline status
aws codepipeline get-pipeline-state --name web-pipeline-staging

# View build logs
aws logs tail /aws/codebuild/web-pipeline-staging --follow
```

### Terraform Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output web_pipeline_name
```

## Manual Pipeline Execution

To manually trigger a pipeline:

```bash
aws codepipeline start-pipeline-execution --name web-pipeline-staging
```

Or use the AWS Console:
1. Go to CodePipeline
2. Select the pipeline
3. Click **Release change**

## Troubleshooting

### Pipeline Fails at Source Stage

**Issue**: CodeStar connection not authorized

**Solution**: 
1. Go to AWS Console → Developer Tools → Connections
2. Check connection status
3. Update connection if needed

### Pipeline Fails at Build Stage

**Issue**: Build errors

**Solution**:
1. Check CloudWatch Logs for detailed error messages
2. Verify buildspec.yml syntax
3. Ensure all dependencies are available

### Permission Issues

**Issue**: IAM permission denied

**Solution**:
1. Check IAM role policies in `modules/codepipeline/main.tf`
2. Ensure CodeBuild role has necessary permissions
3. Update policies and reapply Terraform

## Cost Considerations

**Estimated Monthly Cost (per environment):**

- CodePipeline: $1 per active pipeline/month = $3
- CodeBuild: $0.005/minute (BUILD_GENERAL1_SMALL)
  - Average: 10 builds/month × 5 minutes = $0.25
- S3 Storage: $0.023/GB (minimal for artifacts) = $0.50
- CloudWatch Logs: $0.50/GB ingested = $2
- **Total: ~$6/month for all three pipelines**

Actual costs vary based on:
- Build frequency
- Build duration
- Artifact storage
- Log volume

## Cleanup

To destroy all pipeline resources:

```bash
terraform destroy
```

**Note**: This will delete:
- All pipelines
- S3 buckets (must be empty first)
- IAM roles
- CloudWatch logs
- SNS topics

## Next Steps

After pipelines are running:

1. **Add Deploy Stage**: Extend pipelines to deploy to ECS/Lambda
2. **Add Approval Stage**: Manual approval before production deployment
3. **Integrate Testing**: Add automated testing stages
4. **Set up Backend**: Configure S3 backend for Terraform state
5. **Multi-Environment**: Create production pipelines

## Module Structure

```
terraform/
├── modules/
│   └── codepipeline/
│       ├── main.tf       # Main pipeline resources
│       ├── variables.tf  # Input variables
│       └── outputs.tf    # Output values
└── pipelines/
    ├── main.tf           # Instantiate all pipelines
    ├── variables.tf      # Pipeline-specific variables
    ├── outputs.tf        # Pipeline outputs
    ├── terraform.tfvars.example  # Example configuration
    └── README.md         # This file
```

## References

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [CodeStar Connections](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

