# Pipeline Setup Verification Script
# Run this to verify all required files are in place

Write-Host "🔍 Verifying Pipeline Setup..." -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

function Test-FileExists {
    param($Path, $Description)
    if (Test-Path $Path) {
        Write-Host "✅ $Description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $Description - NOT FOUND" -ForegroundColor Red
        Write-Host "   Expected: $Path" -ForegroundColor Yellow
        $script:errors++
        return $false
    }
}

# Check Buildspec Files
Write-Host "📦 Checking Buildspec Files..." -ForegroundColor Yellow
Test-FileExists "cicd\buildspec-web.yml" "Web buildspec"
Test-FileExists "cicd\buildspec-api.yml" "API buildspec"
Test-FileExists "cicd\buildspec-infrastructure.yml" "Infrastructure buildspec"
Write-Host ""

# Check Terraform Module
Write-Host "🏗️  Checking CodePipeline Module..." -ForegroundColor Yellow
Test-FileExists "ops\iac\modules\codepipeline\main.tf" "Module main.tf"
Test-FileExists "ops\iac\modules\codepipeline\variables.tf" "Module variables.tf"
Test-FileExists "ops\iac\modules\codepipeline\outputs.tf" "Module outputs.tf"
Write-Host ""

# Check Pipeline Configuration
Write-Host "⚙️  Checking Pipeline Configuration..." -ForegroundColor Yellow
Test-FileExists "ops\iac\pipelines\main.tf" "Pipeline main.tf"
Test-FileExists "ops\iac\pipelines\variables.tf" "Pipeline variables.tf"
Test-FileExists "ops\iac\pipelines\outputs.tf" "Pipeline outputs.tf"
Test-FileExists "ops\iac\pipelines\terraform.tfvars.example" "Config example"
Test-FileExists "ops\iac\pipelines\.gitignore" "Gitignore"
Test-FileExists "ops\iac\pipelines\README.md" "Pipeline README"
Write-Host ""

# Check if terraform.tfvars exists (should be created by user)
Write-Host "🔐 Checking User Configuration..." -ForegroundColor Yellow
if (Test-Path "ops\iac\pipelines\terraform.tfvars") {
    Write-Host "✅ terraform.tfvars exists" -ForegroundColor Green
} else {
    Write-Host "⚠️  terraform.tfvars NOT FOUND (you need to create this)" -ForegroundColor Yellow
    Write-Host "   Run: cd ops\iac\pipelines; cp terraform.tfvars.example terraform.tfvars" -ForegroundColor Cyan
    $script:warnings++
}
Write-Host ""

# Check Documentation
Write-Host "📚 Checking Documentation..." -ForegroundColor Yellow
Test-FileExists "docs\PIPELINES_SETUP.md" "Setup guide"
Test-FileExists "docs\PIPELINES_SUMMARY.md" "Summary doc"
Test-FileExists "PIPELINES_QUICKSTART.md" "Quick start guide"
Test-FileExists "PIPELINES_STATUS.md" "Status report"
Write-Host ""

# Check Application Code
Write-Host "💻 Checking Application Code..." -ForegroundColor Yellow
Test-FileExists "packages\web\package.json" "Web package.json"
Test-FileExists "packages\api\package.json" "API package.json"
Write-Host ""

# Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 SUCCESS! All required files are in place!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Create CodeStar connection in AWS Console" -ForegroundColor White
    Write-Host "2. cd ops\iac\pipelines" -ForegroundColor White
    Write-Host "3. cp terraform.tfvars.example terraform.tfvars" -ForegroundColor White
    Write-Host "4. Edit terraform.tfvars with your values" -ForegroundColor White
    Write-Host "5. terraform init" -ForegroundColor White
    Write-Host "6. terraform plan" -ForegroundColor White
    Write-Host "7. terraform apply" -ForegroundColor White
} elseif ($errors -eq 0) {
    Write-Host "⚠️  Setup is mostly complete with $warnings warning(s)" -ForegroundColor Yellow
    Write-Host "Review warnings above before proceeding" -ForegroundColor Yellow
} else {
    Write-Host "❌ Found $errors error(s) and $warnings warning(s)" -ForegroundColor Red
    Write-Host "Please fix the missing files before deploying" -ForegroundColor Red
}
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

