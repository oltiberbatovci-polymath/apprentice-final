# PowerShell script to manually trigger CodePipeline executions
# This allows you to trigger pipelines without pushing to Git

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("web", "api", "infrastructure", "all")]
    [string]$Pipeline = "all"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Triggering CodePipeline(s)..." -ForegroundColor Cyan
Write-Host ""

$pipelines = @{
    "web" = "web-pipeline-staging"
    "api" = "api-pipeline-staging"
    "infrastructure" = "infrastructure-pipeline-staging"
}

$pipelinesToTrigger = @()

if ($Pipeline -eq "all") {
    $pipelinesToTrigger = $pipelines.Values
} else {
    $pipelinesToTrigger = @($pipelines[$Pipeline])
}

foreach ($pipelineName in $pipelinesToTrigger) {
    Write-Host "📦 Triggering: $pipelineName" -ForegroundColor Yellow
    
    try {
        $result = aws codepipeline start-pipeline-execution --name $pipelineName | ConvertFrom-Json
        
        if ($result.pipelineExecutionId) {
            Write-Host "   ✅ Successfully triggered!" -ForegroundColor Green
            Write-Host "   📋 Execution ID: $($result.pipelineExecutionId)" -ForegroundColor Cyan
            Write-Host "   🔗 View in Console: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/$pipelineName/view" -ForegroundColor White
        } else {
            Write-Host "   ⚠️  Triggered but no execution ID returned" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Error triggering pipeline: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Usage Examples:" -ForegroundColor Cyan
Write-Host "   .\trigger-pipelines.ps1                    # Trigger all pipelines" -ForegroundColor White
Write-Host "   .\trigger-pipelines.ps1 -Pipeline web      # Trigger web pipeline only" -ForegroundColor White
Write-Host "   .\trigger-pipelines.ps1 -Pipeline api       # Trigger API pipeline only" -ForegroundColor White
Write-Host "   .\trigger-pipelines.ps1 -Pipeline infrastructure  # Trigger infrastructure pipeline only" -ForegroundColor White
Write-Host ""
Write-Host "📊 Monitor pipelines:" -ForegroundColor Cyan
Write-Host "   .\monitor-pipelines.ps1" -ForegroundColor White
Write-Host ""

