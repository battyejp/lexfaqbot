# FAQ Chatbot with Amazon Lex and Bedrock

A complete serverless FAQ chatbot that uses Amazon Lex for conversation management and Amazon Bedrock Claude 3 for intelligent responses.

## 🏗️ Architecture

```
User → Amazon Lex → Lambda Function → S3 (FAQ) + Bedrock Claude 3 → Response
```

## 📁 Files

- `infrastructure.yaml` - Complete CloudFormation template
- `deploy.ps1` / `deploy.sh` - One-click deployment scripts (Windows/Linux)
- `test.ps1` / `test.sh` - Testing scripts (Windows/Linux)
- `safer-gambling.pdf` - PDF knowledge base (replace with your content!)
- `README.md` - This file

## 🚀 Quick Start

### Prerequisites
- **AWS CLI** installed and configured with appropriate permissions
  - Install: https://aws.amazon.com/cli/
  - Configure: `aws configure`
- **Windows**: PowerShell
- **Linux/Mac**: Bash with `jq` installed (`sudo apt install jq` or `brew install jq`)
- Access to Amazon Bedrock Claude 3 in your region

### 1. Deploy Everything
```bash
# Windows PowerShell
.\deploy.ps1 -StackName "my-faq-bot" -Region "eu-west-1"

# Linux/Mac Bash
./deploy.sh my-faq-bot eu-west-1
```

### 2. Test the Bot
```bash
# Windows PowerShell
.\test.ps1 -Message "What is the My Profit and Loss feature?"

# Linux/Mac Bash
./test.sh my-faq-bot eu-west-1 "What is the My Profit and Loss feature?"
```

## 🧪 Testing Options

### Option 1: AWS Console (Recommended)
1. Go to **Amazon Lex Console**
2. Find bot: **FAQ-Chatbot**
3. Click **"Test"** tab
4. Type: "What time does the shop open?"

### Option 2: Command Line
```bash
# Windows
.\test.ps1 -Message "What is safer gambling?"
.\test.ps1 -Message "How can I set limits?"

# Linux/Mac
./test.sh my-faq-bot us-east-1 "What is safer gambling?"
./test.sh my-faq-bot us-east-1 "Where can I get help?"
```

## 💬 Example Questions

The chatbot can handle various ways of asking the same question:

### **Safer Gambling Basics**
- "What is safer gambling?"
- "How can I gamble safely?"
- "What does responsible gambling mean?"
- "Tell me about safer gambling"

### **Setting Limits**
- "How can I set gambling limits?"
- "What limits should I set?"
- "How do I control my spending?"
- "Can I set time limits?"

### **Getting Help**
- "Where can I get help for gambling problems?"
- "What is the gambling helpline number?"
- "How do I contact GamCare?"
- "Where can I find support?"

### **Warning Signs**
- "What are the signs of problem gambling?"
- "How do I know if I have a gambling problem?"
- "What are the warning signs?"
- "Am I gambling too much?"

### **Self-Exclusion**
- "What is self-exclusion?"
- "How do I self-exclude?"
- "What is GamStop?"
- "Can I ban myself from gambling?"

**The AI understands natural language variations and provides consistent answers based on your FAQ content.**

### Option 3: API Integration
Use the bot ID and alias ID from deployment outputs to integrate with:
- Web applications
- Mobile apps
- Slack/Teams
- Custom chat interfaces

## 📝 Customization

### Update Knowledge Base
Replace `safer-gambling.pdf` with your own PDF content and redeploy.

### Modify Bot Responses
Update the Lambda function in `infrastructure.yaml` to:
- Change response format
- Add business logic
- Integrate with databases
- Add authentication

### Change Bedrock Model
Replace `anthropic.claude-3-sonnet-20240229-v1:0` with:
- `anthropic.claude-3-haiku-20240307-v1:0` (faster, cheaper)
- `anthropic.claude-3-opus-20240229-v1:0` (more capable)

## 💰 Cost Estimation (Monthly)

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 1000 requests | ~$0.20 |
| Lex | 1000 messages | ~$0.75 |
| Bedrock | 1000 requests | ~$3.00 |
| S3 | Storage | ~$0.02 |
| **Total** | | **~$4.00** |

## 🔧 Troubleshooting

### Bot Not Responding
1. Check Lambda logs in CloudWatch
2. Verify S3 bucket has `faqs.txt`
3. Ensure Bedrock access in your region

### Permission Errors
```bash
# Check if Bedrock is enabled
aws bedrock list-foundation-models --region us-east-1
```

### Test Alias Issues
The deployment script automatically configures the test alias. If console testing fails, redeploy.

## 🌟 Features

- ✅ **Serverless** - No servers to manage
- ✅ **Scalable** - Handles thousands of concurrent users
- ✅ **Intelligent** - Uses Claude 3 for natural responses
- ✅ **Multi-channel** - Deploy to web, mobile, Slack, etc.
- ✅ **Cost-effective** - Pay only for usage
- ✅ **Easy to customize** - Simple FAQ file format

## 📚 Next Steps

1. **Update PDF content** in `safer-gambling.pdf`
2. **Deploy to channels** (web widget, Slack, etc.)
3. **Monitor usage** in CloudWatch
4. **Scale up** by adding more intents
5. **Integrate** with your existing systems

## 🧹 Cleanup

To delete all resources and avoid charges:

### Option 1: AWS Console (Recommended)
1. Go to **AWS CloudFormation Console**
2. Select your stack (e.g., `my-faq-bot`)
3. Click **"Delete"**
4. Confirm deletion
5. Wait for stack deletion to complete

### Option 2: AWS CLI
```bash
# Replace with your stack name
aws cloudformation delete-stack --stack-name my-faq-bot --region us-east-1
```

**Note:** This will delete all resources including S3 bucket, Lambda function, Lex bot, and IAM roles.

## 🆘 Support

For issues or questions:
1. Check CloudWatch logs
2. Review AWS documentation
3. Test with CLI first before console
4. Verify all AWS services are available in your region

---

**Your FAQ chatbot is ready! 🎉**