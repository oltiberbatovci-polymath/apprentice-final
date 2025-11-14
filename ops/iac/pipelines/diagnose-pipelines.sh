#!/bin/bash
# Pipeline Diagnostics Script

echo "🔍 Diagnosing CodePipeline Setup..."
echo ""

# Check if AWS CLI is configured
echo "1️⃣ Checking AWS CLI Configuration..."
aws sts get-caller-identity || { echo "❌ AWS CLI not configured"; exit 1; }
echo "✅ AWS CLI configured"
echo ""

# Check if pipelines exist
echo "2️⃣ Checking if pipelines exist..."
PIPELINES=$(aws codepipeline list-pipelines --query 'pipelines[*].name' --output text)
if [ -z "$PIPELINES" ]; then
    echo "❌ No pipelines found. Run 'terraform apply' first."
    exit 1
fi
echo "✅ Found pipelines:"
echo "$PIPELINES"
echo ""

# Check each pipeline
for PIPELINE in web-pipeline-staging api-pipeline-staging infrastructure-pipeline-staging; do
    echo "3️⃣ Checking $PIPELINE..."
    
    # Get pipeline state
    STATE=$(aws codepipeline get-pipeline-state --name $PIPELINE 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✅ $PIPELINE exists"
        
        # Check latest execution
        EXEC_STATUS=$(echo "$STATE" | jq -r '.stageStates[0].latestExecution.status // "Never run"')
        echo "   Status: $EXEC_STATUS"
        
        if [ "$EXEC_STATUS" = "Never run" ]; then
            echo "   ⚠️  Pipeline has never been executed. Trigger it manually:"
            echo "   aws codepipeline start-pipeline-execution --name $PIPELINE"
        fi
    else
        echo "❌ $PIPELINE not found"
    fi
    echo ""
done

# Check CodeStar Connection
echo "4️⃣ Checking CodeStar Connection..."
CONNECTION_ARN="arn:aws:codeconnections:us-east-1:522814722683:connection/877c6cb6-75f2-46e1-8510-b8e155aecc5b"
CONNECTION_STATUS=$(aws codeconnections get-connection --connection-arn "$CONNECTION_ARN" --query 'Connection.ConnectionStatus' --output text 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ "$CONNECTION_STATUS" = "AVAILABLE" ]; then
        echo "✅ CodeStar connection is AVAILABLE"
    else
        echo "❌ CodeStar connection status: $CONNECTION_STATUS"
        echo "   Fix: Go to AWS Console → Developer Tools → Connections → Complete authorization"
    fi
else
    echo "❌ Could not find CodeStar connection"
    echo "   Check the ARN in terraform.tfvars"
fi
echo ""

# Check repository
echo "5️⃣ Checking Repository Configuration..."
REPO_ID="oltiberbatovci-polymath/apprentice-final"
echo "   Repository: $REPO_ID"
echo "   Branch: main"
echo ""

# Provide manual trigger commands
echo "🚀 To manually trigger pipelines:"
echo "   aws codepipeline start-pipeline-execution --name web-pipeline-staging"
echo "   aws codepipeline start-pipeline-execution --name api-pipeline-staging"
echo "   aws codepipeline start-pipeline-execution --name infrastructure-pipeline-staging"
echo ""

# Check recent Git commits
echo "6️⃣ Checking local Git status..."
if [ -d ".git" ]; then
    echo "   Latest commit:"
    git log -1 --oneline
    echo ""
    echo "   Current branch:"
    git branch --show-current
else
    echo "   ⚠️  Not in a Git repository"
fi
echo ""

echo "✅ Diagnostics complete!"

