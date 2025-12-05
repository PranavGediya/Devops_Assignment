# DevOps One-Click Deployment

A production-ready AWS infrastructure deployment using Terraform that provisions a highly available, auto-scaling web application with a single command.

## 🏗️ Architecture Overview

This project deploys a complete AWS infrastructure with the following components:

### Network Layer
- **VPC** (`10.0.0.0/16`) with DNS support enabled
- **2 Public Subnets** (`10.0.1.0/24`, `10.0.2.0/24`) across multiple AZs
- **2 Private Subnets** (`10.0.11.0/24`, `10.0.12.0/24`) across multiple AZs
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for private subnet outbound connectivity
- **Route Tables** with appropriate routing configurations

### Compute Layer
- **Application Load Balancer (ALB)** - Internet-facing, distributes traffic across instances
- **Target Group** - Health checks on `/health` endpoint
- **Launch Template** - Amazon Linux 2023 with Node.js application
- **Auto Scaling Group** - 2-4 instances in private subnets

### Security Layer
- **ALB Security Group** - Allows HTTP (80) and HTTPS (443) from internet
- **EC2 Security Group** - Allows traffic only from ALB on port 8080
- **IAM Role** - EC2 instances with CloudWatch and SSM permissions
- **Network ACLs** - Default VPC network access control

### Application
Simple Node.js REST API with:
- `GET /` - Returns "Hello from EC2 instance! Server is running."
- `GET /health` - Returns "ok" (used for health checks)

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1. **Terraform** (>= 1.0)
   ```bash
   # Download from https://www.terraform.io/downloads
   terraform --version
   ```

2. **AWS CLI** (>= 2.0)
   ```bash
   # Install from https://aws.amazon.com/cli/
   aws --version
   ```

3. **AWS Credentials Configured**
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., eu-north-1)
   # Enter output format (json)
   ```

4. **Git**
   ```bash
   git --version
   ```

5. **Bash Shell** (Linux/macOS/WSL)

## 🚀 Quick Start - One-Click Deployment

### Step 1: Clone the Repository
```bash
git clone https://github.com/PranavGediya/Devops_Assignment.git
cd Devops_Assignment
```

### Step 2: Review Configuration (Optional)
Check the default variables in `variables.tf` or create a `terraform.tfvars` file:

```hcl
aws_region        = "eu-north-1"
project_name      = "devops-assignment"
vpc_cidr          = "10.0.0.0/16"
instance_type     = "t3.micro"
min_size          = 2
max_size          = 4
desired_capacity  = 2
```

### Step 3: Deploy Everything with One Command
```bash
./scripts/deploy.sh
```

**What happens during deployment:**
1. ✅ Prerequisites check (Terraform, AWS CLI)
2. 🔧 Terraform initialization
3. 📋 Infrastructure planning
4. 🚀 Resource provisioning (~3-5 minutes)
5. ✅ Deployment completion with ALB URL

### Step 4: Wait for Health Checks
After deployment completes, wait **3-5 minutes** for:
- EC2 instances to launch and initialize
- Node.js application to install and start
- ALB health checks to pass
- Target registration to complete

### Step 5: Test the Deployment
Use the provided test script:
```bash
./scripts/test.sh
```

Or manually test the ALB URL (provided in deployment output):
```bash
# Test main endpoint
curl http://devops-assignment-alb-XXXXXXXXXX.eu-north-1.elb.amazonaws.com

# Test health endpoint
curl http://devops-assignment-alb-XXXXXXXXXX.eu-north-1.elb.amazonaws.com/health

# Load test (10 requests)
for i in {1..10}; do curl http://your-alb-url.amazonaws.com; echo ""; done
```

**Expected Output:**
```
Hello from EC2 instance! Server is running.
```

## 📁 Project Structure

```
devops-one-click-deployment/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output definitions
├── terraform.tfvars       # Variable values (optional)
├── scripts/
│   ├── deploy.sh          # One-click deployment script
│   ├── test.sh            # Testing script
│   └── destroy.sh         # Cleanup script
├── README.md              # This file
└── .gitignore            # Git ignore rules
```

## 🔧 Detailed Deployment Steps

If you prefer manual deployment over the one-click script:

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Validate Configuration
```bash
terraform validate
```

### 3. Plan Infrastructure
```bash
terraform plan -out=tfplan
```

### 4. Apply Configuration
```bash
terraform apply tfplan
```

### 5. View Outputs
```bash
terraform output
```

## 🧪 Testing the Deployment

### Automated Testing
```bash
./scripts/test.sh
```

The test script performs:
- ✅ Basic connectivity test
- ✅ Health endpoint verification
- ✅ Load testing (10 requests)
- ✅ Response time measurement

### Manual Testing

#### Test Basic Endpoint
```bash
ALB_URL=$(terraform output -raw alb_url)
curl $ALB_URL
```

#### Test Health Endpoint
```bash
curl $ALB_URL/health
```

#### Verify Auto Scaling
```bash
# Check ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names devops-assignment-asg \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus,LifecycleState]' \
  --output table
```

#### Check Target Health
```bash
# Get Target Group ARN
TG_ARN=$(terraform output -raw target_group_arn)

# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table
```

## 📊 Viewing Resources in AWS Console

After deployment, you can view resources in the AWS Console:

1. **VPC & Networking**
   - Console → VPC → Your VPCs → `devops-assignment-vpc`
   - View subnets, route tables, IGW, NAT Gateway

2. **Load Balancer**
   - Console → EC2 → Load Balancers → `devops-assignment-alb`
   - View listeners, rules, monitoring

3. **Target Group**
   - Console → EC2 → Target Groups → `devops-assignment-tg`
   - View registered targets and health status

4. **Auto Scaling Group**
   - Console → EC2 → Auto Scaling Groups → `devops-assignment-asg`
   - View instances, scaling policies, activity history

5. **EC2 Instances**
   - Console → EC2 → Instances
   - Filter by tag: `devops-assignment-asg-instance`

6. **Security Groups**
   - Console → EC2 → Security Groups
   - `devops-assignment-alb-sg` and `devops-assignment-ec2-sg`

## 🔒 Security Best Practices Implemented

✅ **Network Security**
- EC2 instances in private subnets (no public IPs)
- Security groups with least privilege
- ALB in public subnets only

✅ **Access Control**
- No SSH ports open to internet
- SSM Session Manager enabled for secure access
- IAM roles with minimum required permissions

✅ **Application Security**
- IMDSv2 required (metadata security)
- Security group rules limiting traffic sources
- Health checks for instance monitoring

✅ **Best Practices**
- No hardcoded secrets
- Automated deployment (Infrastructure as Code)
- Multi-AZ deployment for high availability
- Auto-scaling for resilience

## 🔍 Troubleshooting

### Issue: Deployment Fails at ALB Creation

**Solution:** 
- Check if your AWS account has restrictions on ALB creation
- Verify you have the necessary IAM permissions
- If using a new account, wait 24 hours or contact AWS Support

### Issue: Instances Show Unhealthy

**Possible Causes:**
1. Application not started yet (wait 3-5 minutes)
2. Security group misconfiguration
3. Application crash

**Debug Steps:**
```bash
# Check instance logs via SSM
aws ssm start-session --target i-xxxxxxxxx

# Once connected, check application status
sudo systemctl status app.service
sudo journalctl -u app.service -n 50
```

### Issue: Cannot Access ALB URL

**Checklist:**
- ✅ Wait 3-5 minutes after deployment
- ✅ Verify targets are healthy in target group
- ✅ Check security group allows inbound HTTP
- ✅ Verify ALB is in "active" state

### Issue: Terraform State Lock

**Solution:**
```bash
# If state is locked, force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

## 💰 Cost Estimation

Approximate monthly costs (us-east-1 region):

| Resource | Cost |
|----------|------|
| NAT Gateway | ~$32/month |
| Application Load Balancer | ~$16/month |
| EC2 t3.micro (2 instances) | ~$15/month |
| Data Transfer | ~$5/month |
| **Total** | **~$68/month** |

**💡 Cost Saving Tips:**
- Delete resources when not in use
- Use t3.micro or t4g.micro instances
- Consider using VPC endpoints instead of NAT Gateway
- Enable auto-scaling to scale down during low usage

## 🧹 Cleanup - Destroy All Resources

To avoid ongoing AWS charges, destroy all resources when done:

### Option 1: Using Destroy Script (Recommended)
```bash
./scripts/destroy.sh
```

### Option 2: Manual Terraform Destroy
```bash
terraform destroy -auto-approve
```

### Option 3: Interactive Destroy
```bash
terraform destroy
# Type 'yes' when prompted
```

**Verify Cleanup:**
```bash
# Check if resources are deleted
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=devops-assignment-vpc"
aws elbv2 describe-load-balancers --names devops-assignment-alb
```

## 📚 Additional Resources

### SSH Access to Private Instances (via SSM)
```bash
# List running instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-assignment-asg-instance" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress]' \
  --output table

# Connect via SSM Session Manager (no SSH key needed)
aws ssm start-session --target i-xxxxxxxxx
```

### View Application Logs
```bash
# Once connected via SSM
sudo journalctl -u app.service -f
```

### Update Application Code
```bash
# Connect to instance via SSM
cd /home/ec2-user/app

# Edit server.js
sudo nano server.js

# Restart service
sudo systemctl restart app.service
```

### Scaling the Application
```bash
# Update desired capacity
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name devops-assignment-asg \
  --desired-capacity 3
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 🙋 Support

For issues or questions:
- Open an issue on GitHub
- Contact: [Your Contact Information]

## ✅ Assignment Checklist

- [x] One-click deployment script
- [x] REST API with `/` and `/health` endpoints
- [x] EC2 instances in private subnets
- [x] Internet access via NAT Gateway
- [x] Application Load Balancer (public)
- [x] Target Group with health checks
- [x] Auto Scaling Group (2-4 instances)
- [x] Security groups (ALB and EC2)
- [x] IAM roles (CloudWatch + SSM)
- [x] No hardcoded secrets
- [x] No SSH open to world
- [x] Teardown/destroy script
- [x] Infrastructure as Code (Terraform)
- [x] Documentation

---

**Made with ❤️ by Pranav Gediya**

**Repository:** https://github.com/PranavGediya/Devops_Assignment
