# Monitor Pipeline Execution Status
# Run this to check all three pipelines

Write-Host "🔍 Monitoring CodePipeline Status..." -ForegroundColor Cyan
Write-Host ""

$pipelines = @(
    "web-pipeline-staging",
    "api-pipeline-staging", 
    "infrastructure-pipeline-staging"
)

foreach ($pipeline in $pipelines) {
    Write-Host "📊 $pipeline" -ForegroundColor Yellow
    
    try {
        $state = aws codepipeline get-pipeline-state --name $pipeline | ConvertFrom-Json
        
        foreach ($stage in $state.stageStates) {
            $stageName = $stage.stageName
            $status = $stage.latestExecution.status
            
            $color = switch ($status) {
                "Succeeded" { "Green" }
                "Failed" { "Red" }
                "InProgress" { "Cyan" }
                default { "Yellow" }
            }
            
            $icon = switch ($status) {
                "Succeeded" { "✅" }
                "Failed" { "❌" }
                "InProgress" { "🔵" }
                default { "⏸️" }
            }
            
            Write-Host "   $icon $stageName : $status" -ForegroundColor $color
        }
        
    } catch {
        Write-Host "   ❌ Error checking pipeline" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 To watch live logs:" -ForegroundColor Cyan
Write-Host "   aws logs tail /aws/codebuild/web-pipeline-staging --follow" -ForegroundColor White
Write-Host "   aws logs tail /aws/codebuild/api-pipeline-staging --follow" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Or view in AWS Console:" -ForegroundColor Cyan
Write-Host "   https://console.aws.amazon.com/codesuite/codepipeline/pipelines" -ForegroundColor White

