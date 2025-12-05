#!/bin/bash

set -e

echo "=========================================="
echo "DevOps One-Click Deployment"
echo "=========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure'."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Navigate to terraform directory
cd terraform

echo "🔧 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

echo ""
read -p "Do you want to proceed with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""

# Get outputs
ALB_URL=$(terraform output -raw alb_url)

echo "🌐 Application URL: $ALB_URL"
echo ""
echo "⏳ Wait 3-5 minutes for instances to be healthy, then test with:"
echo "   curl $ALB_URL"
echo "   curl $ALB_URL/health"
echo ""
echo "📊 To view resources:"
echo "   - AWS Console → EC2 → Load Balancers"
echo "   - AWS Console → EC2 → Auto Scaling Groups"
echo "   - AWS Console → EC2 → Target Groups"
echo ""