#!/bin/bash

# Complete FAQ Chatbot Deployment Script
STACK_NAME=${1:-"faq-chatbot"}
REGION=${2:-"us-east-1"}

echo "Deploying FAQ Chatbot..."

# 1. Deploy infrastructure
echo "1. Deploying infrastructure..."
aws cloudformation deploy \
    --template-file infrastructure.yaml \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_IAM \
    --region $REGION

if [ $? -ne 0 ]; then
    echo "Infrastructure deployment failed!"
    exit 1
fi

# 2. Get outputs
echo "2. Getting deployment outputs..."
OUTPUTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].Outputs" --output json)

BUCKET_NAME=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="S3BucketName") | .OutputValue')
BOT_ID=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="BotId") | .OutputValue')
BOT_ALIAS_ID=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="BotAliasId") | .OutputValue')
LAMBDA_ARN=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="LambdaFunctionArn") | .OutputValue')

# 3. Upload PDF file
echo "3. Uploading PDF file..."
aws s3 cp safer-gambling.pdf s3://$BUCKET_NAME/safer-gambling.pdf --region $REGION

# 4. Configure test bot alias
echo "4. Configuring test bot alias..."
cat > test-config.json << EOF
{
  "en_US": {
    "enabled": true,
    "codeHookSpecification": {
      "lambdaCodeHook": {
        "lambdaARN": "$LAMBDA_ARN",
        "codeHookInterfaceVersion": "1.0"
      }
    }
  }
}
EOF

aws lexv2-models update-bot-alias \
    --bot-id $BOT_ID \
    --bot-alias-id "TSTALIASID" \
    --bot-alias-name "TestBotAlias" \
    --bot-version "DRAFT" \
    --bot-alias-locale-settings file://test-config.json \
    --region $REGION > /dev/null

rm test-config.json

echo "Deployment Complete!"
echo ""
echo "Deployment Summary:"
echo "S3 Bucket: $BUCKET_NAME"
echo "Bot ID: $BOT_ID"
echo "Bot Alias ID: ${BOT_ALIAS_ID%|*}"
echo ""
echo "Test Commands:"
echo "aws lexv2-runtime recognize-text --bot-id \"$BOT_ID\" --bot-alias-id \"${BOT_ALIAS_ID%|*}\" --locale-id \"en_US\" --session-id \"test-1\" --text \"What time does the shop open?\" --region $REGION"
echo ""
echo "Console Test: Go to Lex Console -> FAQ-Chatbot -> Test"