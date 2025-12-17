#!/bin/bash

# Simple deployment using existing Knowledge Base
STACK_NAME="${1:-faq-chatbot-simple}"
REGION="${2:-eu-west-1}"
KNOWLEDGE_BASE_ID="${3:-IQWBNRBAPW}"
PROFILE="${4:-new}"

echo "Deploying simple FAQ Chatbot..."

# Deploy infrastructure
aws cloudformation deploy \
    --template-file infrastructure.yaml \
    --stack-name "$STACK_NAME" \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides KnowledgeBaseId="$KNOWLEDGE_BASE_ID" \
    --region "$REGION" \
    --profile "$PROFILE"

if [ $? -eq 0 ]; then
    echo "Deployment Complete!"
    
    # Get outputs
    BOT_ID=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --profile "$PROFILE" --query "Stacks[0].Outputs[?OutputKey=='BotId'].OutputValue" --output text)
    BOT_ALIAS_ID=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --profile "$PROFILE" --query "Stacks[0].Outputs[?OutputKey=='BotAliasId'].OutputValue" --output text)
    
    echo "Bot ID: $BOT_ID"
    echo "Bot Alias ID: $BOT_ALIAS_ID"
    
    echo "Building bot..."
    aws lexv2-models build-bot-locale --bot-id "$BOT_ID" --bot-version "DRAFT" --locale-id "en_US" --region "$REGION" --profile "$PROFILE"
    
    echo "Bot deployed and building. Wait 2-3 minutes before testing."
else
    echo "Deployment failed!"
fi