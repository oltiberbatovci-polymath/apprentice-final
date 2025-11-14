# 🚀 CodePipeline Quick Start Guide

Get your three AWS CodePipelines up and running in **15 minutes**!

## What You'll Get

- ✅ **Web Pipeline** - Automatically builds your React frontend
- ✅ **API Pipeline** - Automatically builds your Node.js backend
- ✅ **Infrastructure Pipeline** - Validates your Terraform code
- ✅ **Automated notifications** via SNS
- ✅ **CloudWatch logging** for all builds
- ✅ **Artifact storage** in S3

## Prerequisites (5 minutes)

### 1. Check Your Tools

```bash
# Check AWS CLI
aws --version
# Should show: aws-cli/2.x.x or higher

# Check Terraform
terraform --version
# Should show: Terraform v1.5.0 or higher

# Check you're logged into AWS
aws sts get-caller-identity
# Should show your AWS account details
```

### 2. Get Your GitHub Username

You'll need your GitHub username and repository name.

## Setup Steps

### Step 1: Create CodeStar Connection (3 minutes)

**⚠️ This MUST be done manually in AWS Console (cannot be automated)**

1. Open AWS Console → Search for "**Connections**"
2. Click **"Create connection"**
3. Choose **GitHub**
4. Name: `apprentice-github-connection`
5. Click **"Connect to GitHub"**
6. Authorize AWS to access your repository
7. ✅ **Copy the Connection ARN** - you'll need this!

```
arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123...
                                          ^^^^^^^^^^^^               ^^^^^^
                                          Region                     ID
```

### Step 2: Configure Terraform (2 minutes)

```bash
# Navigate to pipelines directory
cd terraform/pipelines

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Edit the file (Windows)
notepad terraform.tfvars

# Or (Linux/Mac)
nano terraform.tfvars
```

**Update these 3 values:**

```hcl
owner = "YourName"                    # Your name
codestar_connection_arn = "arn:..."  # From Step 1
repository_id = "username/repo"      # Your GitHub username/repo
```

### Step 3: Deploy (5 minutes)

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

☕ **Wait 2-3 minutes while AWS creates ~30 resources**

### Step 4: Verify (2 minutes)

1. **Check AWS Console:**
   - Go to **CodePipeline** in AWS Console
   - You should see 3 pipelines! 🎉

2. **Check Terraform outputs:**
   ```bash
   terraform output
   ```

3. **Trigger a test build:**
   ```bash
   aws codepipeline start-pipeline-execution --name web-pipeline-staging
   ```

## What Just Happened?

You created:

```
┌─────────────────────┐
│  Your GitHub Repo   │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌─────────┐   ┌─────────┐   ┌─────────────┐
│   Web   │   │   API   │   │    Infra    │
│Pipeline │   │Pipeline │   │  Pipeline   │
└─────────┘   └─────────┘   └─────────────┘
    │             │              │
    └─────────────┴──────────────┘
                  │
                  ▼
         ┌─────────────────┐
         │  Notifications  │
         │   (Email/SNS)   │
         └─────────────────┘
```

**Each pipeline:**
- ✅ Monitors your GitHub repo
- ✅ Automatically triggers on push
- ✅ Runs build/validation
- ✅ Stores artifacts in S3
- ✅ Sends notifications
- ✅ Logs everything to CloudWatch

## View Your Pipelines

### Option 1: AWS Console (Visual)

1. AWS Console → **CodePipeline**
2. Click any pipeline name
3. See execution history, logs, and status

### Option 2: AWS CLI (Terminal)

```bash
# List all pipelines
aws codepipeline list-pipelines

# View specific pipeline status
aws codepipeline get-pipeline-state --name web-pipeline-staging

# Watch build logs in real-time
aws logs tail /aws/codebuild/web-pipeline-staging --follow
```

### Option 3: Terraform (Info)

```bash
# Show all pipeline info
terraform output

# Show specific output
terraform output web_pipeline_name
```

## Set Up Email Notifications (Optional - 3 minutes)

Get emails when pipelines succeed or fail:

```bash
# Get SNS topic ARN
TOPIC_ARN=$(terraform output -raw web_sns_topic_arn)

# Subscribe your email
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint your-email@example.com

# Check your email and confirm the subscription!
```

Repeat for other pipelines if desired.

## Common Issues

### ❌ "Source stage failed"

**Problem:** CodeStar connection not authorized

**Fix:**
1. Go to AWS Console → Connections
2. Check status is "Available" (not "Pending")
3. Re-authorize if needed

### ❌ "Build stage failed"

**Problem:** Build errors in your code

**Fix:**
1. Check CloudWatch Logs for error details
2. Fix the issue in your code
3. Push to GitHub (pipeline will auto-trigger)

### ❌ "Permission denied"

**Problem:** Missing IAM permissions

**Fix:**
1. Ensure you have admin access to AWS
2. Check IAM roles were created
3. Review `modules/codepipeline/main.tf`

## What's Next?

Now that your pipelines are running, you can:

### Immediate Next Steps:
1. ✅ **Push a change** to GitHub and watch pipeline trigger
2. ✅ **Check CloudWatch logs** to see build output
3. ✅ **Subscribe to notifications** (email alerts)

### Future Enhancements:
1. 🔄 **Add Docker builds** to create container images
2. 🚀 **Add Deploy stage** to push to ECS/Lambda
3. ✋ **Add manual approval** for production deployments
4. 🧪 **Add test stage** for automated testing
5. 🌍 **Create production pipelines** (separate from staging)

## File Structure Created

```
apprentice-final/
├── buildspecs/
│   ├── buildspec-web.yml              ← Web build instructions
│   ├── buildspec-api.yml              ← API build instructions
│   └── buildspec-infrastructure.yml   ← Terraform validation
│
├── terraform/
│   ├── modules/
│   │   └── codepipeline/
│   │       ├── main.tf                ← Reusable pipeline module
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   └── pipelines/
│       ├── main.tf                    ← Creates all 3 pipelines
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars           ← YOUR CONFIG (gitignored)
│       └── terraform.tfvars.example
│
└── docs/
    └── PIPELINES_SETUP.md             ← Detailed setup guide
```

## Cost

**~$4-6 per month** for all three pipelines (staging environment)

- CodePipeline: $1/pipeline = $3/month
- CodeBuild: ~$0.25/month (depends on build frequency)
- S3 Storage: ~$0.50/month
- CloudWatch Logs: ~$2/month

## Useful Commands Cheat Sheet

```bash
# Terraform
terraform init              # Initialize
terraform plan              # Preview
terraform apply             # Deploy
terraform output            # Show info
terraform destroy           # Delete all

# AWS CLI - Pipelines
aws codepipeline list-pipelines
aws codepipeline start-pipeline-execution --name PIPELINE-NAME
aws codepipeline get-pipeline-state --name PIPELINE-NAME

# AWS CLI - Logs
aws logs tail /aws/codebuild/PIPELINE-NAME --follow

# AWS CLI - SNS Subscribe
aws sns subscribe --topic-arn ARN --protocol email --notification-endpoint EMAIL
```

## Support

- 📖 **Detailed Guide:** `docs/PIPELINES_SETUP.md`
- 📖 **Module README:** `terraform/pipelines/README.md`
- 🔍 **AWS Logs:** CloudWatch → Log Groups → `/aws/codebuild/`
- 🌐 **AWS Console:** CodePipeline dashboard

## Cleanup

To delete everything:

```bash
cd terraform/pipelines
terraform destroy
```

Type `yes` to confirm. All resources will be deleted.

---

**🎉 Congratulations!** Your CI/CD pipelines are now running!

Next: Start implementing your Terraform modules for ECS, RDS, and other AWS services step by step.

