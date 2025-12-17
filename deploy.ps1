# Complete FAQ Chatbot Deployment Script
param(
    [string]$StackName = "faq-chatbot",
    [string]$Region = "us-east-1"
)

Write-Host "Deploying FAQ Chatbot..." -ForegroundColor Green

# 1. Deploy infrastructure
Write-Host "1. Deploying infrastructure..." -ForegroundColor Yellow
aws cloudformation deploy `
    --template-file infrastructure.yaml `
    --stack-name $StackName `
    --capabilities CAPABILITY_IAM `
    --region $Region

if ($LASTEXITCODE -ne 0) {
    Write-Host "Infrastructure deployment failed!" -ForegroundColor Red
    exit 1
}

# 2. Get outputs
Write-Host "2. Getting deployment outputs..." -ForegroundColor Yellow
$outputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query "Stacks[0].Outputs" --output json | ConvertFrom-Json

$bucketName = ($outputs | Where-Object { $_.OutputKey -eq "S3BucketName" }).OutputValue
$botId = ($outputs | Where-Object { $_.OutputKey -eq "BotId" }).OutputValue
$botAliasId = ($outputs | Where-Object { $_.OutputKey -eq "BotAliasId" }).OutputValue

# 3. Upload PDF file
Write-Host "3. Uploading PDF file..." -ForegroundColor Yellow
#aws s3 cp safer-gambling.pdf s3://$bucketName/safer-gambling.pdf --region $Region

# 4. Configure test bot alias
Write-Host "4. Configuring test bot alias..." -ForegroundColor Yellow
$lambdaArn = ($outputs | Where-Object { $_.OutputKey -eq "LambdaFunctionArn" }).OutputValue

# Create test alias config with proper encoding
@"
{
  "en_US": {
    "enabled": true,
    "codeHookSpecification": {
      "lambdaCodeHook": {
        "lambdaARN": "$lambdaArn",
        "codeHookInterfaceVersion": "1.0"
      }
    }
  }
}
"@ | Out-File -FilePath "test-config.json" -Encoding UTF8

aws lexv2-models update-bot-alias `
    --bot-id $botId `
    --bot-alias-id "TSTALIASID" `
    --bot-alias-name "TestBotAlias" `
    --bot-version "DRAFT" `
    --bot-alias-locale-settings file://test-config.json `
    --region $Region | Out-Null

Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Deployment Summary:" -ForegroundColor Cyan
Write-Host "S3 Bucket: $bucketName" -ForegroundColor White
Write-Host "Bot ID: $botId" -ForegroundColor White
Write-Host "Bot Alias ID: $botAliasId" -ForegroundColor White
Write-Host ""
Write-Host "Test Commands:" -ForegroundColor Cyan
Write-Host "aws lexv2-runtime recognize-text --bot-id `"$botId`" --bot-alias-id `"$botAliasId`" --locale-id `"en_US`" --session-id `"test-1`" --text `"What time does the shop open?`" --region $Region" -ForegroundColor Gray
Write-Host ""
Write-Host "Console Test: Go to Lex Console -> FAQ-Chatbot -> Test" -ForegroundColor Cyan