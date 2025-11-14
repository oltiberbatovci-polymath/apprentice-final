# CodePipeline Setup Guide

This guide walks you through setting up three AWS CodePipelines for the Apprentice Final Project.

## Overview

We'll create three separate pipelines:

1. **Web Pipeline** - Builds the React frontend
2. **API Pipeline** - Builds the Node.js backend  
3. **Infrastructure Pipeline** - Validates Terraform code

## Prerequisites Checklist

- [ ] AWS Account with admin access
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.5.0 installed
- [ ] GitHub repository with your code
- [ ] Git configured locally

## Step-by-Step Setup

### Step 1: Create GitHub CodeStar Connection

This is a **one-time manual setup** that cannot be done via Terraform.

1. **Log into AWS Console**

2. **Navigate to CodeStar Connections**:
   - Go to: **Developer Tools** → **Settings** → **Connections**
   - Or search for "Connections" in the AWS Console search bar

3. **Create Connection**:
   - Click **"Create connection"**
   - Choose provider: **GitHub**
   - Connection name: `apprentice-github-connection`
   - Click **"Connect to GitHub"**

4. **Authorize GitHub**:
   - Click **"Install a new app"**
   - Select your GitHub account
   - Choose repository access:
     - Select **"Only select repositories"**
     - Choose `apprentice-final` repository
   - Click **"Install"**

5. **Complete Connection**:
   - Back in AWS Console, click **"Connect"**
   - Status should change to **"Available"**

6. **Copy Connection ARN**:
   - Click on the connection name
   - Copy the **Connection ARN** (you'll need this next)
   - Example: `arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123...`

### Step 2: Configure Terraform Variables

1. **Navigate to pipelines directory**:
   ```bash
   cd terraform/pipelines
   ```

2. **Create terraform.tfvars from example**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars** (use your favorite editor):
   ```bash
   notepad terraform.tfvars  # Windows
   # or
   nano terraform.tfvars     # Linux/Mac
   ```

4. **Update values**:
   ```hcl
   # AWS Configuration
   aws_region  = "us-east-1"        # Your preferred region
   environment = "staging"           # Start with staging

   # Project Information
   project_name = "ApprenticeFinal"
   owner        = "YourName"         # Your name

   # GitHub Configuration
   codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:123456789012:connection/xxx"
   repository_id           = "your-username/apprentice-final"  # Your GitHub username/repo
   branch_name             = "main"  # Or "master" if that's your default branch
   ```

### Step 3: Initialize Terraform

1. **Initialize Terraform** (downloads providers and modules):
   ```bash
   terraform init
   ```

   You should see:
   ```
   Initializing modules...
   Initializing the backend...
   Initializing provider plugins...
   Terraform has been successfully initialized!
   ```

### Step 4: Validate Configuration

1. **Check for syntax errors**:
   ```bash
   terraform validate
   ```

   Should output: `Success! The configuration is valid.`

2. **Format code** (optional but recommended):
   ```bash
   terraform fmt -recursive
   ```

### Step 5: Review Execution Plan

1. **Generate and review plan**:
   ```bash
   terraform plan
   ```

2. **Review what will be created**:
   - 3 × CodePipeline
   - 3 × CodeBuild Projects
   - 3 × S3 Buckets (for artifacts)
   - 6+ × IAM Roles & Policies
   - 3 × CloudWatch Log Groups
   - 3 × SNS Topics
   - 3 × CloudWatch Event Rules

   **Total: ~30 resources**

3. **Check for errors**:
   - No errors? Proceed to apply
   - Errors? Review variables and connection ARN

### Step 6: Deploy Pipelines

1. **Apply configuration**:
   ```bash
   terraform apply
   ```

2. **Review changes**:
   - Terraform shows what will be created
   - Read through the plan

3. **Confirm deployment**:
   - Type `yes` when prompted
   - Wait for deployment (usually 2-3 minutes)

4. **Note the outputs**:
   ```
   Outputs:

   api_pipeline_name = "api-pipeline-staging"
   infrastructure_pipeline_name = "infrastructure-pipeline-staging"
   web_pipeline_name = "web-pipeline-staging"
   ...
   ```

### Step 7: Verify Deployment

1. **Check AWS Console**:
   - Go to **AWS Console** → **CodePipeline**
   - You should see 3 pipelines

2. **Check initial execution**:
   - Each pipeline should start automatically
   - May fail first time (that's okay - we'll fix buildspecs)

3. **View Terraform outputs**:
   ```bash
   terraform output
   ```

### Step 8: Set Up Email Notifications (Optional)

1. **Get SNS topic ARNs**:
   ```bash
   terraform output web_sns_topic_arn
   terraform output api_sns_topic_arn
   terraform output infrastructure_sns_topic_arn
   ```

2. **Subscribe to notifications** (replace with your email):
   ```bash
   aws sns subscribe \
     --topic-arn $(terraform output -raw web_sns_topic_arn) \
     --protocol email \
     --notification-endpoint your-email@example.com
   ```

3. **Confirm subscription**:
   - Check your email
   - Click confirmation link

4. **Repeat for other pipelines** if desired

## Verify Everything Works

### Test 1: View Pipelines in Console

1. Go to AWS Console → CodePipeline
2. Click on `web-pipeline-staging`
3. View execution history

### Test 2: Check Build Logs

1. Go to CodeBuild in AWS Console
2. Click on `web-pipeline-build-staging`
3. View build history and logs

### Test 3: Trigger Manual Execution

```bash
aws codepipeline start-pipeline-execution --name web-pipeline-staging
```

### Test 4: View CloudWatch Logs

```bash
# Tail logs in real-time
aws logs tail /aws/codebuild/web-pipeline-staging --follow
```

## Common Issues & Solutions

### Issue 1: CodeStar Connection Not Authorized

**Error**: `Pipeline failed at Source stage`

**Solution**:
1. Go to AWS Console → Connections
2. Find your connection
3. Status should be "Available"
4. If "Pending", complete authorization
5. Re-run pipeline

### Issue 2: Build Fails

**Error**: `Build failed in CodeBuild`

**Solution**:
1. Check CloudWatch Logs for details
2. Common causes:
   - Missing dependencies in buildspec
   - Wrong Node version
   - Path issues
3. Fix buildspec.yml and push changes

### Issue 3: Permission Denied

**Error**: `AccessDenied when accessing S3`

**Solution**:
1. Check IAM role has correct permissions
2. Review `modules/codepipeline/main.tf` policies
3. May need to add additional permissions

### Issue 4: Terraform State Lock

**Error**: `Error acquiring the state lock`

**Solution**:
```bash
# If you're sure no other Terraform is running:
terraform force-unlock <LOCK_ID>
```

## Next Steps

Now that your pipelines are running:

1. ✅ **Monitor first build** - Check if buildspecs work
2. ✅ **Fix any build errors** - Update buildspecs as needed
3. ⏭️ **Add Docker builds** - Update buildspecs to build containers
4. ⏭️ **Create ECR repositories** - Store Docker images
5. ⏭️ **Add Deploy stage** - Deploy to ECS or Lambda
6. ⏭️ **Add manual approval** - For production deployments
7. ⏭️ **Set up remote state** - S3 backend for Terraform

## Pipeline Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                        │
│                  (apprentice-final)                          │
└────────────────────┬────────────────────────────────────────┘
                     │ CodeStar Connection
                     │
        ┌────────────┴────────────┬───────────────────┐
        │                         │                   │
        ▼                         ▼                   ▼
┌───────────────┐         ┌───────────────┐  ┌──────────────────┐
│ Web Pipeline  │         │ API Pipeline  │  │ Infra Pipeline   │
├───────────────┤         ├───────────────┤  ├──────────────────┤
│ Source Stage  │         │ Source Stage  │  │ Source Stage     │
│      ↓        │         │      ↓        │  │      ↓           │
│ Build Stage   │         │ Build Stage   │  │ Validate Stage   │
│  (CodeBuild)  │         │  (CodeBuild)  │  │  (CodeBuild)     │
│      ↓        │         │      ↓        │  │      ↓           │
│  S3 Artifacts │         │  S3 Artifacts │  │  S3 Artifacts    │
└───────┬───────┘         └───────┬───────┘  └────────┬─────────┘
        │                         │                   │
        └─────────────────────────┴───────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   SNS Topics    │
                    │ (Notifications) │
                    └─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Email / Slack   │
                    └─────────────────┘
```

## Resources Created

| Resource Type | Count | Purpose |
|--------------|-------|---------|
| CodePipeline | 3 | Web, API, Infrastructure pipelines |
| CodeBuild Project | 3 | Build jobs for each pipeline |
| S3 Bucket | 3 | Artifact storage |
| IAM Role | 6 | CodePipeline (3) + CodeBuild (3) |
| IAM Policy | 6 | Permissions for roles |
| CloudWatch Log Group | 3 | Build logs |
| SNS Topic | 3 | Pipeline notifications |
| CloudWatch Event Rule | 3 | Trigger notifications |

## Cost Estimate

**Monthly cost for all 3 pipelines (staging environment):**

| Service | Usage | Cost |
|---------|-------|------|
| CodePipeline | 3 pipelines | $3.00 |
| CodeBuild | ~50 build-minutes/month | $0.25 |
| S3 Storage | ~5 GB artifacts | $0.12 |
| CloudWatch Logs | ~1 GB logs | $0.50 |
| SNS | ~100 notifications | $0.00 |
| **TOTAL** | | **~$4/month** |

## Useful Commands Reference

```bash
# Terraform commands
terraform init          # Initialize
terraform plan          # Preview changes
terraform apply         # Deploy
terraform destroy       # Delete everything
terraform output        # Show outputs
terraform fmt           # Format code
terraform validate      # Check syntax

# AWS CLI - Pipeline commands
aws codepipeline list-pipelines
aws codepipeline get-pipeline-state --name PIPELINE_NAME
aws codepipeline start-pipeline-execution --name PIPELINE_NAME

# AWS CLI - Build commands  
aws codebuild list-projects
aws codebuild batch-get-builds --ids BUILD_ID

# AWS CLI - Logs
aws logs tail /aws/codebuild/PIPELINE_NAME --follow

# AWS CLI - SNS
aws sns subscribe --topic-arn ARN --protocol email --notification-endpoint EMAIL
```

## Support & Documentation

- **Project README**: `README.md`
- **Pipeline Module**: `terraform/modules/codepipeline/`
- **Buildspecs**: `buildspecs/` directory
- **AWS Docs**: [CodePipeline](https://docs.aws.amazon.com/codepipeline/)

---

**Questions or Issues?** Check the troubleshooting section or review AWS CloudWatch Logs for detailed error messages.

