# Test FAQ Chatbot
param(
    [string]$StackName = "faq-chatbot",
    [string]$Region = "eu-west-1",
    [string]$Message = "What is safer gambling?",
    [string]$Profile = "new"
)

Write-Host "Testing FAQ Chatbot..." -ForegroundColor Green

# Get bot details
$outputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region --profile $Profile --query "Stacks[0].Outputs" --output json | ConvertFrom-Json
$botId = ($outputs | Where-Object { $_.OutputKey -eq "BotId" }).OutputValue
$botAliasId = ($outputs | Where-Object { $_.OutputKey -eq "BotAliasId" }).OutputValue.Split('|')[0]

Write-Host "Message: $Message" -ForegroundColor Yellow

# Test the bot
$response = aws lexv2-runtime recognize-text `
    --bot-id $botId `
    --bot-alias-id $botAliasId `
    --locale-id "en_US" `
    --session-id "test-$(Get-Date -Format 'yyyyMMddHHmmss')" `
    --text "$Message" `
    --region $Region `
    --profile $Profile `
    --output json

if ($LASTEXITCODE -eq 0) {
    $result = $response | ConvertFrom-Json
    Write-Host "Bot Response:" -ForegroundColor Green
    Write-Host $result.messages[0].content -ForegroundColor Cyan
} else {
    Write-Host "Error testing bot" -ForegroundColor Red
}