# Resources Removed from Compute Module

## Summary
Migrated web application from ECS (containerized) to S3 (static hosting). The following resources were **REMOVED**:

---

## 🗑️ Removed Resources

### 1. **Web ECS Service**
- **Resource Type:** `aws_ecs_service.web`
- **Name:** `ApprenticeFinal-web-service-staging`
- **Purpose:** Was running web container on ECS Fargate
- **Replacement:** S3 static website hosting

### 2. **Web ECS Task Definition**
- **Resource Type:** `aws_ecs_task_definition.web`
- **Name:** `ApprenticeFinal-web-staging`
- **Purpose:** Defined web container configuration (CPU, memory, port mappings, health checks)
- **Replacement:** Not needed (static files in S3)

### 3. **Web ECR Repository**
- **Resource Type:** `aws_ecr_repository.web`
- **Name:** `apprenticefinal-web-staging`
- **Purpose:** Stored Docker images for web application
- **Replacement:** Not needed (no Docker images for static site)

### 4. **Web Target Group**
- **Resource Type:** `aws_lb_target_group.web`
- **Name:** `ApprenticeFinal-web-tg-staging`
- **Purpose:** ALB target group routing traffic to web ECS tasks
- **Replacement:** CloudFront distribution serving from S3

### 5. **Web Auto Scaling Target**
- **Resource Type:** `aws_appautoscaling_target.web`
- **Purpose:** Auto-scaling configuration for web ECS service
- **Replacement:** Not needed (S3 scales automatically)

### 6. **Web Auto Scaling Policies**
- **Resource Types:** 
  - `aws_appautoscaling_policy.web_cpu`
  - `aws_appautoscaling_policy.web_memory`
- **Purpose:** CPU and memory-based auto-scaling policies
- **Replacement:** Not needed

### 7. **Web CloudWatch Log Group**
- **Resource Type:** `aws_cloudwatch_log_group.web`
- **Name:** `/aws/ecs/ApprenticeFinal-web-staging`
- **Purpose:** Container logs for web service
- **Replacement:** Not needed (no containers)

---

## ✅ Added Resources

### 1. **S3 Bucket for Web**
- **Resource Type:** `aws_s3_bucket.web`
- **Name:** `ApprenticeFinal-web-staging-{account-id}`
- **Purpose:** Static website hosting

### 2. **S3 Bucket Versioning**
- **Resource Type:** `aws_s3_bucket_versioning.web`
- **Purpose:** Enable versioning for rollback capability

### 3. **S3 Bucket Encryption**
- **Resource Type:** `aws_s3_bucket_server_side_encryption_configuration.web`
- **Purpose:** AES256 encryption at rest

### 4. **S3 Bucket Public Access Block**
- **Resource Type:** `aws_s3_bucket_public_access_block.web`
- **Purpose:** Configure public access for website hosting

### 5. **S3 Bucket Policy**
- **Resource Type:** `aws_s3_bucket_policy.web`
- **Purpose:** Allow public read access for CloudFront

### 6. **S3 Website Configuration**
- **Resource Type:** `aws_s3_bucket_website_configuration.web`
- **Purpose:** Configure index and error documents

---

## 📊 Resource Count Comparison

### Before (ECS-based):
- **ECS Services:** 2 (API + Web)
- **ECS Task Definitions:** 2
- **ECR Repositories:** 2
- **Target Groups:** 2
- **Auto Scaling Targets:** 2
- **Auto Scaling Policies:** 4 (2 CPU + 2 Memory)
- **CloudWatch Log Groups:** 2

### After (S3-based):
- **ECS Services:** 1 (API only)
- **ECS Task Definitions:** 1
- **ECR Repositories:** 1
- **Target Groups:** 1
- **Auto Scaling Targets:** 1
- **Auto Scaling Policies:** 2 (1 CPU + 1 Memory)
- **CloudWatch Log Groups:** 1
- **S3 Buckets:** 1 (new)
- **S3 Configurations:** 5 (new)

---

## 🔄 Architecture Changes

### Before:
```
Internet → CloudFront → ALB → [API Target Group → ECS API] + [Web Target Group → ECS Web]
```

### After:
```
Internet → CloudFront → [S3 (Web)] + [ALB → API Target Group → ECS API]
```

---

## 💰 Cost Impact

### Removed Costs:
- Web ECS Fargate tasks (CPU + Memory)
- Web ECR storage (Docker images)
- Web CloudWatch logs
- Web auto-scaling overhead

### Added Costs:
- S3 storage (very low)
- S3 requests (very low)
- CloudFront data transfer (same as before)

### Net Result:
**Significant cost reduction** - Static hosting is much cheaper than running containers.

---

## 📝 Configuration Changes

### Files Modified:
1. `ops/iac/modules/compute/main.tf` - Removed web ECS resources, added S3
2. `ops/iac/modules/compute/outputs.tf` - Removed web ECS outputs, added S3 outputs
3. `ops/iac/modules/edge/main.tf` - Added S3 origin to CloudFront
4. `ops/iac/main.tf` - Removed web ECS configuration
5. `ops/iac/outputs.tf` - Updated outputs
6. `cicd/web/buildspec-deploy.yml` - Changed from ECS deploy to S3 sync
7. `cicd/web/buildspec-test.yml` - Updated to test S3/CloudFront

### Variables Removed:
- `web_port`
- `web_cpu`
- `web_memory`
- `web_desired_count`
- `web_min_capacity`
- `web_max_capacity`
- `web_health_check_path`
- `web_health_check_command`
- `web_environment_variables`

### Variables Added:
- `web_s3_bucket_name` (output)

---

## ⚠️ Migration Notes

1. **No downtime expected** - CloudFront will serve from S3 once deployed
2. **Old web ECS service will be destroyed** during `terraform apply`
3. **Web pipeline now deploys to S3** instead of ECR/ECS
4. **API service remains unchanged** - still running on ECS

---

## 🚀 Deployment Process

1. **Build Stage:** Builds web app (unchanged)
2. **Deploy Stage:** Syncs `dist/` folder to S3 bucket (changed)
3. **Test Stage:** Tests CloudFront/S3 endpoint (changed)

---

## ✅ Benefits

1. **Lower Cost:** No container compute costs for web
2. **Better Performance:** S3 + CloudFront is faster than ECS
3. **Simpler Architecture:** Fewer moving parts
4. **Easier Scaling:** S3 scales automatically
5. **Better Caching:** CloudFront caching is more effective

