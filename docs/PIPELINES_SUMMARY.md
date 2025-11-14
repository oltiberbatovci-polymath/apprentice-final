# CodePipeline Implementation Summary

## Overview

Three AWS CodePipelines have been successfully configured using Terraform:

1. **Web Pipeline** - Frontend (React) build pipeline
2. **API Pipeline** - Backend (Node.js/TypeScript) build pipeline
3. **Infrastructure Pipeline** - Terraform validation pipeline

## Architecture

```
                                    GitHub Repository
                                    (apprentice-final)
                                           |
                                    CodeStar Connection
                                           |
                    +----------------------+----------------------+
                    |                      |                      |
              Web Pipeline            API Pipeline         Infra Pipeline
                    |                      |                      |
         +----------+----------+  +--------+--------+   +---------+---------+
         |                    |  |                 |   |                   |
    Source Stage        Build     Source      Build    Source         Validate
    (GitHub)            Stage     (GitHub)    Stage    (GitHub)        Stage
         |              |         |           |        |               |
         v              v         v           v        v               v
    CodeBuild       S3 Bucket  CodeBuild   S3 Bucket  CodeBuild    S3 Bucket
    (Node 18)       (Artifacts)(Node 18)   (Artifacts)(Terraform)  (Artifacts)
         |              |         |           |        |               |
         |              |         |           |        |               |
         v              v         v           v        v               v
    CloudWatch       CloudWatch  CloudWatch CloudWatch CloudWatch   CloudWatch
    Logs             Logs        Logs       Logs      Logs          Logs
         |              |         |           |        |               |
         +------+-------+         +-----+-----+        +-------+-------+
                |                       |                      |
                v                       v                      v
           SNS Topic               SNS Topic              SNS Topic
         (Notifications)         (Notifications)        (Notifications)
                |                       |                      |
                +------------+----------+----------------------+
                             |
                             v
                      Email / Monitoring
```

## Components Created

### Per Pipeline (×3)

Each pipeline includes:

| Component | Resource Type | Purpose |
|-----------|---------------|---------|
| **Pipeline** | `aws_codepipeline` | Orchestrates CI/CD workflow |
| **Build Project** | `aws_codebuild_project` | Executes build commands |
| **Artifact Bucket** | `aws_s3_bucket` | Stores build artifacts |
| **Pipeline IAM Role** | `aws_iam_role` | Permissions for pipeline operations |
| **CodeBuild IAM Role** | `aws_iam_role` | Permissions for build operations |
| **Log Group** | `aws_cloudwatch_log_group` | Stores build logs |
| **SNS Topic** | `aws_sns_topic` | Pipeline notifications |
| **Event Rule** | `aws_cloudwatch_event_rule` | Triggers notifications |

### Total Resources

- **3 CodePipelines**
- **3 CodeBuild Projects**
- **3 S3 Buckets**
- **6 IAM Roles** (2 per pipeline)
- **6 IAM Policies**
- **3 CloudWatch Log Groups**
- **3 SNS Topics**
- **3 CloudWatch Event Rules**

**Total: ~30 AWS Resources**

## Pipeline Details

### 1. Web Pipeline

**Name:** `web-pipeline-staging`

**Purpose:** Build React frontend application

**Buildspec:** `buildspecs/buildspec-web.yml`

**Build Steps:**
1. Install Node.js dependencies
2. Run build script (`npm run build`)
3. Generate production-optimized static files
4. Store artifacts in S3

**Build Environment:**
- **Image:** `aws/codebuild/standard:7.0`
- **Compute:** `BUILD_GENERAL1_SMALL` (3 GB RAM, 2 vCPUs)
- **Timeout:** 30 minutes

**Environment Variables:**
- `ENVIRONMENT=staging`
- `NODE_ENV=production`

**Outputs:**
- Build artifacts: `packages/web/dist/`
- CloudWatch logs: `/aws/codebuild/web-pipeline-staging`

### 2. API Pipeline

**Name:** `api-pipeline-staging`

**Purpose:** Build Node.js/TypeScript backend API

**Buildspec:** `buildspecs/buildspec-api.yml`

**Build Steps:**
1. Install Node.js dependencies
2. Run TypeScript compiler (`npm run build`)
3. Generate Prisma client
4. Store compiled JavaScript in S3

**Build Environment:**
- **Image:** `aws/codebuild/standard:7.0`
- **Compute:** `BUILD_GENERAL1_SMALL`
- **Timeout:** 30 minutes

**Environment Variables:**
- `ENVIRONMENT=staging`
- `NODE_ENV=production`

**Outputs:**
- Build artifacts: `packages/api/dist/`
- CloudWatch logs: `/aws/codebuild/api-pipeline-staging`

### 3. Infrastructure Pipeline

**Name:** `infrastructure-pipeline-staging`

**Purpose:** Validate Terraform configurations

**Buildspec:** `buildspecs/buildspec-infrastructure.yml`

**Build Steps:**
1. Check Terraform version
2. Format check (`terraform fmt -check`)
3. Initialize Terraform
4. Validate syntax (`terraform validate`)

**Build Environment:**
- **Image:** `hashicorp/terraform:1.6`
- **Compute:** `BUILD_GENERAL1_SMALL`
- **Timeout:** 45 minutes

**Environment Variables:**
- `ENVIRONMENT=staging`
- `TF_VERSION=1.6.0`
- `TF_IN_AUTOMATION=true`

**Outputs:**
- Validation results
- CloudWatch logs: `/aws/codebuild/infrastructure-pipeline-staging`

## Terraform Module Structure

### Reusable Module

```
terraform/modules/codepipeline/
├── main.tf          # Pipeline, CodeBuild, IAM, SNS resources
├── variables.tf     # 13 configurable variables
└── outputs.tf       # 9 output values
```

**Module Features:**
- ✅ Fully parameterized (no hard-coded values)
- ✅ Supports custom buildspec paths
- ✅ Configurable compute types and build images
- ✅ Optional SNS notifications
- ✅ CloudWatch logging with configurable retention
- ✅ Support for environment variables
- ✅ Privileged mode for Docker builds
- ✅ Artifact encryption by default

### Pipeline Configuration

```
terraform/pipelines/
├── main.tf                    # Instantiates 3 pipelines
├── variables.tf               # Global variables
├── outputs.tf                 # All pipeline outputs
├── terraform.tfvars.example   # Configuration template
└── .gitignore                 # Protects sensitive files
```

## Security Features

### IAM Least Privilege

Each pipeline has **two separate IAM roles**:

1. **CodePipeline Role** - Can only:
   - Read/write to its own S3 bucket
   - Trigger CodeBuild projects
   - Use CodeStar connection

2. **CodeBuild Role** - Can only:
   - Write logs to CloudWatch
   - Read/write to its artifact bucket
   - Pull/push to ECR (for future Docker builds)

### Data Protection

- ✅ **S3 Encryption:** All artifact buckets use AES-256 encryption
- ✅ **S3 Versioning:** Enabled on all artifact buckets
- ✅ **CloudWatch Logs:** Retained for 7 days (configurable)
- ✅ **Secrets:** No credentials in code (use AWS Secrets Manager)

### Network Security

- ✅ **CodeStar Connections:** Secure OAuth integration with GitHub
- ✅ **No Webhooks:** Uses AWS's managed connection (no exposed endpoints)

## Monitoring & Observability

### CloudWatch Logs

Each pipeline writes detailed logs:

```
/aws/codebuild/web-pipeline-staging
/aws/codebuild/api-pipeline-staging
/aws/codebuild/infrastructure-pipeline-staging
```

**Log Contents:**
- Build commands and output
- Error messages and stack traces
- Timing information
- Resource usage (CPU, memory)

**Retention:** 7 days (configurable via `log_retention_days` variable)

### CloudWatch Events

Event rules capture:
- Pipeline execution started
- Pipeline execution succeeded
- Pipeline execution failed
- Pipeline execution stopped

### SNS Notifications

Each pipeline has an SNS topic that publishes:

**Event Details:**
- Pipeline name
- Execution ID
- State (STARTED, SUCCEEDED, FAILED)
- Timestamp
- Detailed event JSON

**Subscribers:** Email, SMS, Lambda, or other AWS services

## Cost Analysis

### Monthly Cost Estimate (Staging Environment)

| Service | Unit Cost | Usage | Monthly Cost |
|---------|-----------|-------|--------------|
| **CodePipeline** | $1/pipeline | 3 pipelines | $3.00 |
| **CodeBuild** | $0.005/min | 50 build-min | $0.25 |
| **S3 Storage** | $0.023/GB | 5 GB | $0.12 |
| **S3 Requests** | $0.0004/1K | ~5K | $0.00 |
| **CloudWatch Logs** | $0.50/GB | 1 GB | $0.50 |
| **SNS** | $0.50/million | ~100 | $0.00 |
| **CloudWatch Events** | Free | Unlimited | $0.00 |
| **Total** | | | **~$3.87/month** |

### Cost Variables

Actual costs depend on:
- **Build frequency:** More commits = more builds
- **Build duration:** Longer builds cost more
- **Artifact size:** Larger artifacts increase storage
- **Log volume:** More verbose logging costs more

### Cost Optimization Tips

1. **Use S3 Lifecycle Policies** - Delete old artifacts after 30 days
2. **Reduce Log Retention** - 3-7 days for non-production
3. **Right-size Compute** - Use SMALL for simple builds
4. **Cache Dependencies** - Reduce build time with caching

## Deployment Instructions

### Prerequisites

- AWS account with admin permissions
- AWS CLI configured
- Terraform >= 1.5.0
- GitHub repository

### Quick Deploy

```bash
# 1. Create CodeStar connection (AWS Console - manual step)

# 2. Configure variables
cd terraform/pipelines
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Deploy
terraform init
terraform plan
terraform apply

# 4. Verify
terraform output
```

**Deploy time:** ~3 minutes

### Detailed Instructions

See: [`docs/PIPELINES_SETUP.md`](./PIPELINES_SETUP.md)

## Verification Checklist

After deployment, verify:

- [ ] All three pipelines appear in AWS Console
- [ ] Each pipeline has "Source" and "Build" stages
- [ ] S3 buckets created with encryption enabled
- [ ] IAM roles created with appropriate policies
- [ ] CloudWatch log groups created
- [ ] SNS topics created
- [ ] First pipeline execution triggered (may fail - that's okay)
- [ ] Terraform outputs display correctly

## Testing

### Test 1: Manual Trigger

```bash
aws codepipeline start-pipeline-execution --name web-pipeline-staging
```

Expected: Pipeline executes successfully

### Test 2: GitHub Push

```bash
git commit --allow-empty -m "Test pipeline"
git push origin main
```

Expected: All three pipelines trigger automatically

### Test 3: Check Logs

```bash
aws logs tail /aws/codebuild/web-pipeline-staging --follow
```

Expected: See real-time build logs

### Test 4: SNS Notification

Subscribe to SNS topic:
```bash
aws sns subscribe \
  --topic-arn $(terraform output -raw web_sns_topic_arn) \
  --protocol email \
  --notification-endpoint your@email.com
```

Expected: Receive email on next pipeline execution

## Troubleshooting

### Issue: Source Stage Fails

**Symptoms:** Pipeline fails immediately at Source stage

**Causes:**
- CodeStar connection not authorized
- Wrong repository ID
- Branch doesn't exist

**Solutions:**
1. Check connection status in AWS Console
2. Verify `repository_id` format: `owner/repo`
3. Confirm branch name matches

### Issue: Build Stage Fails

**Symptoms:** Build stage shows errors

**Causes:**
- Buildspec syntax error
- Missing dependencies
- Wrong Node version
- Path issues

**Solutions:**
1. Check CloudWatch Logs for details
2. Validate buildspec YAML syntax
3. Test build locally first
4. Verify paths in buildspec

### Issue: Permission Denied

**Symptoms:** IAM errors in logs

**Causes:**
- Missing IAM permissions
- Incorrect trust relationships

**Solutions:**
1. Review IAM role policies
2. Check trust policy allows CodeBuild/CodePipeline
3. Add missing permissions to policy

## Next Steps

Now that pipelines are running, extend them with:

### Phase 1: Docker Support
- Update buildspecs to build Docker images
- Create ECR repositories
- Push images to ECR

### Phase 2: Deploy Stage
- Add deploy stage to pipelines
- Deploy to ECS Fargate
- Update task definitions

### Phase 3: Testing
- Add test stage
- Run unit tests
- Run integration tests

### Phase 4: Approval
- Add manual approval stage
- Configure SNS for approvals
- Set up approval timeout

### Phase 5: Multi-Environment
- Create production pipelines
- Add environment-specific configs
- Implement promotion strategy

## Files Created

```
apprentice-final/
├── buildspecs/
│   ├── buildspec-web.yml
│   ├── buildspec-api.yml
│   └── buildspec-infrastructure.yml
│
├── terraform/
│   ├── modules/
│   │   └── codepipeline/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── pipelines/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.example
│   │   ├── .gitignore
│   │   └── README.md
│   │
│   └── STRUCTURE.md
│
├── docs/
│   ├── PIPELINES_SETUP.md
│   └── PIPELINES_SUMMARY.md
│
└── PIPELINES_QUICKSTART.md
```

## References

- [AWS CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/latest/userguide/)
- [AWS CodeBuild User Guide](https://docs.aws.amazon.com/codebuild/latest/userguide/)
- [Buildspec Reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [CodeStar Connections](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections.html)

## Support

For issues or questions:
1. Check CloudWatch Logs first
2. Review Terraform plan/apply output
3. Consult AWS documentation
4. Check GitHub Issues

---

**Status:** ✅ **COMPLETE** - All three pipelines configured and ready to deploy

**Next:** Implement Terraform modules for AWS infrastructure (VPC, ECS, RDS, etc.)

