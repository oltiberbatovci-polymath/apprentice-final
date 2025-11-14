# How to Fix the CodeStar Connection Error

## Current Problem

Your `terraform.tfvars` file contains placeholder values that need to be replaced with real values.

## Step-by-Step Fix

### 1. Create CodeStar Connection (AWS Console)

⚠️ **This must be done in AWS Console - cannot be automated!**

1. Go to: https://console.aws.amazon.com/codesuite/settings/connections
2. Click **"Create connection"**
3. Provider: **GitHub**
4. Connection name: `apprentice-github-connection`
5. Click **"Connect to GitHub"**
6. Authorize AWS access to your GitHub
7. Select your `apprentice-final` repository
8. Click **"Connect"**
9. Wait for status to be **"Available"**
10. **Copy the Connection ARN** - it will look like:
    ```
    arn:aws:codestar-connections:us-east-1:522814722683:connection/a1b2c3d4-...
    ```

### 2. Get Your GitHub Username

You need your GitHub username. For example:
- GitHub URL: `https://github.com/johndoe/apprentice-final`
- Username: `johndoe`

### 3. Update terraform.tfvars

Edit `ops/iac/pipelines/terraform.tfvars` and replace:

**Current (WRONG - placeholders):**
```hcl
owner        = "YourName"
codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:123456789012:connection/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
repository_id = "your-github-username/apprentice-final"
```

**New (CORRECT - your actual values):**
```hcl
owner        = "Olti"  # Replace with your actual name
codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:522814722683:connection/PASTE-YOUR-REAL-CONNECTION-ID-HERE"
repository_id = "YOUR-GITHUB-USERNAME/apprentice-final"  # e.g., "johndoe/apprentice-final"
```

### 4. Verify Your Changes

Your complete `terraform.tfvars` should look like:

```hcl
# AWS Configuration
aws_region  = "us-east-1"
environment = "staging"

# Project Information
project_name = "ApprenticeFinal"
owner        = "Olti"  # ← Your name

# GitHub Configuration
codestar_connection_arn = "arn:aws:codestar-connections:us-east-1:522814722683:connection/YOUR-REAL-ID"  # ← Real ARN
repository_id           = "johndoe/apprentice-final"  # ← Your GitHub username/repo
branch_name             = "main"
```

### 5. Re-run Terraform

After updating the file:

```bash
cd ops/iac/pipelines
terraform apply
```

## Quick Checklist

- [ ] Created CodeStar connection in AWS Console
- [ ] Connection status is "Available"
- [ ] Copied the real Connection ARN
- [ ] Updated `codestar_connection_arn` in terraform.tfvars
- [ ] Updated `owner` with your name
- [ ] Updated `repository_id` with your GitHub username
- [ ] Saved the file
- [ ] Re-run `terraform apply`

## How to Tell if ARN is Real

❌ **Fake/Example ARN:**
```
arn:aws:codestar-connections:us-east-1:123456789012:connection/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                                        ^^^^^^^^^^^^              ^^^^^^^^
                                        Wrong account              Placeholder
```

✅ **Real ARN:**
```
arn:aws:codestar-connections:us-east-1:522814722683:connection/a1b2c3d4-5678-90ab-cdef-1234567890ab
                                        ^^^^^^^^^^^^              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                        Your account ID           Real connection ID (UUID)
```

## Still Getting Errors?

### Error: "Connection not found"
- **Cause:** Using placeholder ARN or wrong ARN
- **Fix:** Copy ARN from AWS Console → Connections

### Error: "Connection not available"
- **Cause:** Connection not fully authorized
- **Fix:** Go to Connections in AWS Console, complete authorization

### Error: "Access denied to repository"
- **Cause:** GitHub didn't grant access to your repo
- **Fix:** Re-authorize and ensure `apprentice-final` is selected

