#!/bin/bash

# Test FAQ Chatbot
STACK_NAME="${1:-faq-chatbot}"
REGION="${2:-eu-west-1}"
MESSAGE="${3:-What is safer gambling?}"
PROFILE="${4:-new}"

echo "Testing FAQ Chatbot..."

# Get bot details
BOT_ID=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --profile "$PROFILE" --query "Stacks[0].Outputs[?OutputKey=='BotId'].OutputValue" --output text)
BOT_ALIAS_ID=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --profile "$PROFILE" --query "Stacks[0].Outputs[?OutputKey=='BotAliasId'].OutputValue" --output text | cut -d'|' -f1)

echo "Message: $MESSAGE"

# Test the bot
RESPONSE=$(aws lexv2-runtime recognize-text \
    --bot-id "$BOT_ID" \
    --bot-alias-id "$BOT_ALIAS_ID" \
    --locale-id "en_US" \
    --session-id "test-$(date +%Y%m%d%H%M%S)" \
    --text "$MESSAGE" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --output json)

if [ $? -eq 0 ]; then
    echo "Bot Response:"
    echo "$RESPONSE" | jq -r '.messages[0].content'
else
    echo "Error testing bot"
fi