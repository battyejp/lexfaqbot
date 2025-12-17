# Simple deployment using existing Knowledge Base
param(
    [string]$StackName = "faq-chatbot-simple",
    [string]$Region = "eu-west-1",
    [string]$KnowledgeBaseId = "IQWBNRBAPW",
    [string]$Profile = "new"
)

Write-Host "Deploying simple FAQ Chatbot..." -ForegroundColor Green

# Deploy infrastructure
aws cloudformation deploy `
    --template-file infrastructure.yaml `
    --stack-name $StackName `
    --capabilities CAPABILITY_IAM `
    --parameter-overrides KnowledgeBaseId=$KnowledgeBaseId `
    --region $Region `
    --profile $Profile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment Complete!" -ForegroundColor Green
    
    # Get outputs
    $outputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --profile $Profile --query "Stacks[0].Outputs" --output json | ConvertFrom-Json
    $botId = ($outputs | Where-Object { $_.OutputKey -eq "BotId" }).OutputValue
    $botAliasId = ($outputs | Where-Object { $_.OutputKey -eq "BotAliasId" }).OutputValue
    
    Write-Host "Bot ID: $botId" -ForegroundColor Cyan
    Write-Host "Bot Alias ID: $botAliasId" -ForegroundColor Cyan
    
    Write-Host "Building bot..." -ForegroundColor Yellow
    aws lexv2-models build-bot-locale --bot-id $botId --bot-version "DRAFT" --locale-id "en_US" --region $Region --profile $Profile
    
    Write-Host "Bot deployed and building. Wait 2-3 minutes before testing." -ForegroundColor Green
} else {
    Write-Host "Deployment failed!" -ForegroundColor Red
}