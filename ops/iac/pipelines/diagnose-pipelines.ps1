# Pipeline Diagnostics Script (PowerShell)

Write-Host "🔍 Diagnosing CodePipeline Setup..." -ForegroundColor Cyan
Write-Host ""

# Check AWS CLI
Write-Host "1️⃣ Checking AWS CLI Configuration..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity | ConvertFrom-Json
    Write-Host "✅ AWS CLI configured" -ForegroundColor Green
    Write-Host "   Account: $($identity.Account)" -ForegroundColor Gray
    Write-Host "   User: $($identity.Arn)" -ForegroundColor Gray
} catch {
    Write-Host "❌ AWS CLI not configured" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check pipelines
Write-Host "2️⃣ Checking if pipelines exist..." -ForegroundColor Yellow
$pipelines = aws codepipeline list-pipelines --query 'pipelines[*].name' --output text
if ([string]::IsNullOrWhiteSpace($pipelines)) {
    Write-Host "❌ No pipelines found. Run 'terraform apply' first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Found pipelines:" -ForegroundColor Green
Write-Host "   $pipelines" -ForegroundColor Gray
Write-Host ""

# Check each pipeline
$pipelineNames = @("web-pipeline-staging", "api-pipeline-staging", "infrastructure-pipeline-staging")
foreach ($pipeline in $pipelineNames) {
    Write-Host "3️⃣ Checking $pipeline..." -ForegroundColor Yellow
    
    try {
        $state = aws codepipeline get-pipeline-state --name $pipeline 2>$null | ConvertFrom-Json
        Write-Host "✅ $pipeline exists" -ForegroundColor Green
        
        # Check if it has ever run
        $lastExecution = $state.stageStates[0].latestExecution
        if ($null -eq $lastExecution) {
            Write-Host "   ⚠️  Pipeline has never been executed" -ForegroundColor Yellow
            Write-Host "   Run: aws codepipeline start-pipeline-execution --name $pipeline" -ForegroundColor Cyan
        } else {
            $status = $lastExecution.status
            Write-Host "   Status: $status" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ $pipeline not found" -ForegroundColor Red
    }
    Write-Host ""
}

# Check CodeStar Connection
Write-Host "4️⃣ Checking CodeStar Connection..." -ForegroundColor Yellow
$connectionArn = "arn:aws:codeconnections:us-east-1:522814722683:connection/877c6cb6-75f2-46e1-8510-b8e155aecc5b"
try {
    $connection = aws codeconnections get-connection --connection-arn $connectionArn 2>$null | ConvertFrom-Json
    $status = $connection.Connection.ConnectionStatus
    
    if ($status -eq "AVAILABLE") {
        Write-Host "✅ CodeStar connection is AVAILABLE" -ForegroundColor Green
    } else {
        Write-Host "❌ CodeStar connection status: $status" -ForegroundColor Red
        Write-Host "   Fix: Go to AWS Console → Developer Tools → Connections → Complete authorization" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not find CodeStar connection" -ForegroundColor Red
    Write-Host "   Check the ARN in terraform.tfvars" -ForegroundColor Yellow
}
Write-Host ""

# Repository info
Write-Host "5️⃣ Repository Configuration..." -ForegroundColor Yellow
Write-Host "   Repository: oltiberbatovci-polymath/apprentice-final" -ForegroundColor Gray
Write-Host "   Branch: main" -ForegroundColor Gray
Write-Host ""

# Manual trigger commands
Write-Host "🚀 To manually trigger pipelines:" -ForegroundColor Cyan
Write-Host "   aws codepipeline start-pipeline-execution --name web-pipeline-staging" -ForegroundColor White
Write-Host "   aws codepipeline start-pipeline-execution --name api-pipeline-staging" -ForegroundColor White
Write-Host "   aws codepipeline start-pipeline-execution --name infrastructure-pipeline-staging" -ForegroundColor White
Write-Host ""

# Git status
Write-Host "6️⃣ Checking local Git status..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "   Latest commit:" -ForegroundColor Gray
    git log -1 --oneline
    Write-Host "   Current branch:" -ForegroundColor Gray
    git branch --show-current
} else {
    Write-Host "   ⚠️  Not in a Git repository" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "✅ Diagnostics complete!" -ForegroundColor Green

