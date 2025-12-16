#!/bin/bash

# Test FAQ Chatbot
STACK_NAME=${1:-"faq-chatbot"}
REGION=${2:-"us-east-1"}
MESSAGE=${3:-"What time does the shop open?"}

echo "Testing FAQ Chatbot..."

# Get bot details
OUTPUTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].Outputs" --output json)
BOT_ID=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="BotId") | .OutputValue')
BOT_ALIAS_ID=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="BotAliasId") | .OutputValue' | cut -d'|' -f1)

echo "Message: $MESSAGE"

# Test the bot
RESPONSE=$(aws lexv2-runtime recognize-text \
    --bot-id $BOT_ID \
    --bot-alias-id $BOT_ALIAS_ID \
    --locale-id "en_US" \
    --session-id "test-$(date +%Y%m%d%H%M%S)" \
    --text "$MESSAGE" \
    --region $REGION \
    --output json 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Bot Response:"
    echo $RESPONSE | jq -r '.messages[0].content'
else
    echo "Error testing bot"
fi