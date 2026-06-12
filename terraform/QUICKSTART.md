# Quick Start Guide - 5 Minutes to Deployment

This guide will help you deploy the entire Jenkins CI/CD infrastructure to AWS in under 10 minutes.

## Prerequisites Checklist

- [ ] AWS Account with admin access
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] SSH key pair generated

## Step-by-Step Deployment

### 1. Generate SSH Key (1 minute)

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins-cicd-key -N ""

# Display public key (copy this)
cat ~/.ssh/jenkins-cicd-key.pub
```

### 2. Configure AWS (1 minute)

```bash
# Configure AWS credentials
aws configure
# Enter your:
#   AWS Access Key ID
#   AWS Secret Access Key
#   Default region (e.g., us-east-1)
#   Default output format (json)

# Verify
aws sts get-caller-identity
```

### 3. Configure Terraform Variables (2 minutes)

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars - Update these REQUIRED values:
nano terraform.tfvars  # or use your preferred editor
```

**Minimum Required Changes:**

```hcl
# 1. Add your SSH public key (from step 1)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EA... (paste your full public key here)"

# 2. Restrict access to your IP (IMPORTANT for security!)
allowed_ssh_cidr     = ["YOUR_PUBLIC_IP/32"]  # e.g., ["203.0.113.45/32"]
allowed_jenkins_cidr = ["YOUR_PUBLIC_IP/32"]

# 3. Add your Docker Hub credentials
docker_hub_username = "yourdockerhubusername"
docker_hub_password = "your-docker-hub-token"  # Generate token at hub.docker.com
```

**To find your public IP:**
```bash
curl ifconfig.me
```

### 4. Deploy Infrastructure (5-7 minutes)

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

### 5. Save Important Information

```bash
# Display all outputs
terraform output

# Save outputs to file
terraform output -json > infrastructure-outputs.json

# Display deployment summary
terraform output deployment_summary
```

**Save these values immediately:**
- Jenkins URL
- Jenkins public IP
- SonarQube URL
- Staging public IP
- Production public IP

## Post-Deployment Setup (10 minutes)

### 1. Access Jenkins (2 minutes)

```bash
# Get initial admin password
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip) \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'

# Open Jenkins in browser
terraform output jenkins_url
```

**In Jenkins UI:**
1. Paste the admin password
2. Click "Install suggested plugins"
3. Create admin user
4. Click "Save and Finish"

### 2. Install Additional Jenkins Plugins (3 minutes)

Go to: **Manage Jenkins → Plugin Manager → Available**

Install these plugins:
- [ ] Docker Pipeline
- [ ] SonarQube Scanner
- [ ] SSH Agent
- [ ] Multibranch Pipeline (if not already installed)

Click **Install without restart**

### 3. Configure Jenkins Credentials (3 minutes)

Go to: **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

**Add 4 credentials:**

#### a) Docker Hub Credentials
- Kind: Username with password
- ID: `DOCKER_HUB_CREDENTIALS`
- Username: Your Docker Hub username
- Password: Your Docker Hub token
- Click Save

#### b) SSH Key for Deployments
- Kind: SSH Username with private key
- ID: `SSH_KEY`
- Username: `ec2-user`
- Private Key: Click "Enter directly"
  ```bash
  # Display your private key
  cat ~/.ssh/jenkins-cicd-key
  # Copy the ENTIRE output including BEGIN and END lines
  ```
- Click Save

#### c) Slack Webhook (optional but recommended)
- Kind: Secret text
- ID: `SLACK_WEBHOOK`
- Secret: Your Slack webhook URL
  - Get from: https://api.slack.com/apps → Create App → Incoming Webhooks
- Click Save

#### d) SonarQube Token
- Kind: Secret text
- ID: `SONAR_TOKEN`
- Secret: (We'll get this in the next step)
- Click Save (after getting token from SonarQube)

### 4. Configure SonarQube (2 minutes)

```bash
# Open SonarQube
terraform output sonarqube_url
```

**In SonarQube:**
1. Login: `admin` / `admin`
2. Change password when prompted
3. Click "Create Project" → "Manually"
4. Project key: `jenkins-cicd-pipeline`
5. Display name: `Jenkins CI/CD Pipeline`
6. Click "Set Up"
7. Choose "With Jenkins"
8. Generate token → **COPY THE TOKEN**
9. Go back to Jenkins and add this token to SONAR_TOKEN credential

**Add SonarQube Webhook:**
1. In SonarQube: **Administration → Configuration → Webhooks**
2. Click "Create"
3. Name: `Jenkins`
4. URL: `http://localhost:8080/sonarqube-webhook/`
5. Click "Create"

### 5. Configure SonarQube Server in Jenkins (1 minute)

Go to: **Manage Jenkins → Configure System**

Scroll to **SonarQube servers**:
- Check "Enable injection of SonarQube server configuration"
- Name: `SonarQube`
- Server URL: `http://localhost:9000`
- Server authentication token: Select `SONAR_TOKEN`
- Click Save

### 6. Update Jenkinsfile (1 minute)

Edit `Jenkinsfile` in your repository:

```groovy
DOCKER_IMAGE      = "YOUR_DOCKERHUB_USERNAME/myapp"
STAGING_SERVER_IP = "PASTE_STAGING_IP_HERE"
PROD_SERVER_IP    = "PASTE_PRODUCTION_IP_HERE"
```

Get the IPs:
```bash
echo "STAGING_SERVER_IP = \"$(terraform output -raw staging_public_ip)\""
echo "PROD_SERVER_IP = \"$(terraform output -raw production_public_ip)\""
```

Commit and push:
```bash
git add Jenkinsfile
git commit -m "Update Jenkinsfile with server IPs"
git push origin main
```

### 7. Create Jenkins Pipeline (2 minutes)

**In Jenkins:**
1. Click "New Item"
2. Name: `jenkins-cicd-pipeline`
3. Type: **Multibranch Pipeline**
4. Click OK

**Configure:**
- Branch Sources → Add source → Git
- Project Repository: Your Git repository URL
- Credentials: Add your Git credentials if private repo
- Click Save

Jenkins will automatically scan branches and start building!

## Verification

### Test the Pipeline

```bash
# Create dev branch and trigger build
git checkout -b dev
echo "// test" >> src/app.js
git add .
git commit -m "test: trigger dev pipeline"
git push origin dev

# Create staging branch
git checkout -b staging
git merge dev
git push origin staging

# Merge to main (will require manual approval in Jenkins)
git checkout main
git merge staging
git push origin main
```

### Check Deployments

```bash
# Check staging deployment
curl http://$(terraform output -raw staging_public_ip):3000

# Check production deployment (after approval)
curl http://$(terraform output -raw production_public_ip):3000
```

Expected response:
```json
{"message":"Hello from CI/CD Pipeline"}
```

## Quick Reference - Important URLs

```bash
# Jenkins
terraform output jenkins_url

# SonarQube
terraform output sonarqube_url

# Staging App
terraform output staging_app_url

# Production App
terraform output production_app_url
```

## Troubleshooting

### Jenkins not accessible
```bash
# Check if Jenkins is running
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)
sudo systemctl status jenkins
```

### SonarQube not accessible
```bash
# Check SonarQube container
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)
docker ps | grep sonarqube
docker logs sonarqube
```

### Cannot SSH to instances
1. Verify your IP in security groups matches your current IP
2. Check AWS Console → EC2 → Instances status

### Pipeline fails to deploy
1. Verify SSH_KEY credential contains the correct private key
2. Check security groups allow Jenkins → App servers on port 22
3. View Jenkins console output for specific error

## Cleanup

To destroy all infrastructure:

```bash
cd terraform
terraform destroy
# Type 'yes' when prompted
```

**WARNING:** This permanently deletes all resources!

## Next Steps

1. ✅ Set up Slack notifications
2. ✅ Configure branch protection rules in Git
3. ✅ Set up monitoring and alerting
4. ✅ Review security group rules
5. ✅ Enable AWS CloudTrail for audit logging
6. ✅ Set up backup strategy for Jenkins configuration
7. ✅ Document your deployment process
8. ✅ Train team on using the pipeline

## Cost Management

Expected monthly cost: **~$75/month**

To reduce costs:
- Use spot instances for non-production
- Stop instances during non-business hours
- Use t3.micro for all instances if testing
- Clean up unused Docker images regularly

## Support

If you encounter issues:
1. Check CloudWatch Logs
2. Review EC2 instance system logs
3. Check Jenkins build console output
4. Review security group rules
5. Verify credentials in Jenkins

## Summary of What You Deployed

✅ **3 EC2 Instances**
  - Jenkins Server (with SonarQube)
  - Staging Application Server
  - Production Application Server

✅ **Network Infrastructure**
  - VPC with public subnet
  - Internet Gateway
  - Security Groups with proper rules
  - 3 Elastic IPs for stable addressing

✅ **IAM Resources**
  - EC2 instance roles
  - Policies for CloudWatch and ECR

✅ **Monitoring**
  - CloudWatch Log Groups for all servers
  - CloudWatch agents installed

✅ **Automation**
  - Complete CI/CD pipeline
  - Automated testing and deployment
  - Quality gates with SonarQube
  - Slack notifications

**Total deployment time: ~20 minutes**
**Infrastructure cost: ~$75/month**

Congratulations! Your Jenkins CI/CD pipeline infrastructure is now fully operational! 🎉
