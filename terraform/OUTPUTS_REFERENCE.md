# Terraform Outputs Reference Guide

This document explains all the outputs you'll receive after running `terraform apply` and how to use them.

## 📤 Output Categories

### 1. Network Information
### 2. Jenkins Server Details
### 3. Staging Server Details
### 4. Production Server Details
### 5. Security Information
### 6. Connection Commands
### 7. Quick Reference URLs

---

## 1️⃣ Network Information

### `vpc_id`
**Description**: The ID of your VPC (Virtual Private Cloud)  
**Example**: `vpc-0a1b2c3d4e5f6g7h8`  
**Use Case**: Reference when creating additional resources in the same VPC

```bash
# View in AWS Console
aws ec2 describe-vpcs --vpc-ids <vpc-id>
```

### `public_subnet_id`
**Description**: The ID of your public subnet  
**Example**: `subnet-0a1b2c3d4e5f6g7h8`  
**Use Case**: Launch additional instances in the same subnet

```bash
# View subnet details
aws ec2 describe-subnets --subnet-ids <subnet-id>
```

---

## 2️⃣ Jenkins Server Details

### `jenkins_instance_id`
**Description**: EC2 instance ID for Jenkins server  
**Example**: `i-0a1b2c3d4e5f6g7h8`  
**Use Case**: Start/stop/monitor the Jenkins instance

```bash
# View instance details
aws ec2 describe-instances --instance-ids <instance-id>

# Start instance
aws ec2 start-instances --instance-ids <instance-id>

# Stop instance
aws ec2 stop-instances --instance-ids <instance-id>

# Get instance status
aws ec2 describe-instance-status --instance-ids <instance-id>
```

### `jenkins_public_ip`
**Description**: Public Elastic IP address for Jenkins server  
**Example**: `54.123.45.67`  
**Use Case**: Access Jenkins UI, SSH to server

```bash
# Access Jenkins UI
http://54.123.45.67:8080

# SSH to server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67

# Ping server
ping 54.123.45.67
```

### `jenkins_private_ip`
**Description**: Private IP address within VPC  
**Example**: `10.0.1.10`  
**Use Case**: Internal VPC communication

### `jenkins_url`
**Description**: Complete Jenkins UI URL  
**Example**: `http://54.123.45.67:8080`  
**Use Case**: Direct access to Jenkins dashboard

```bash
# Open in browser
open http://54.123.45.67:8080  # macOS
start http://54.123.45.67:8080  # Windows

# Check if accessible
curl -I http://54.123.45.67:8080
```

### `sonarqube_url`
**Description**: Complete SonarQube URL  
**Example**: `http://54.123.45.67:9000`  
**Use Case**: Access SonarQube code analysis dashboard

```bash
# Open in browser
open http://54.123.45.67:9000

# Check status
curl http://54.123.45.67:9000/api/system/status
```

---

## 3️⃣ Staging Server Details

### `staging_instance_id`
**Description**: EC2 instance ID for staging server  
**Example**: `i-1b2c3d4e5f6g7h8i9`  
**Use Case**: Manage staging instance

```bash
# View instance details
aws ec2 describe-instances --instance-ids <instance-id>

# Check Docker containers
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@<staging-ip> 'docker ps'

# View application logs
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@<staging-ip> 'docker logs cicd-app'
```

### `staging_public_ip`
**Description**: Public Elastic IP for staging server  
**Example**: `54.123.45.68`  
**Use Case**: Access staging application, SSH access

### `staging_private_ip`
**Description**: Private IP within VPC  
**Example**: `10.0.1.11`  
**Use Case**: Internal communication

### `staging_app_url`
**Description**: Complete staging application URL  
**Example**: `http://54.123.45.68:3000`  
**Use Case**: Test application in staging environment

```bash
# Access staging app
curl http://54.123.45.68:3000

# Check health endpoint
curl http://54.123.45.68:3000/health

# Test specific endpoint
curl http://54.123.45.68:3000/api/users
```

---

## 4️⃣ Production Server Details

### `production_instance_id`
**Description**: EC2 instance ID for production server  
**Example**: `i-2c3d4e5f6g7h8i9j0`  
**Use Case**: Manage production instance

```bash
# View instance metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --start-time 2026-06-12T00:00:00Z \
  --end-time 2026-06-12T23:59:59Z \
  --period 3600 \
  --statistics Average
```

### `production_public_ip`
**Description**: Public Elastic IP for production server  
**Example**: `54.123.45.69`  
**Use Case**: Access production application

### `production_private_ip`
**Description**: Private IP within VPC  
**Example**: `10.0.1.12`  
**Use Case**: Internal communication

### `production_app_url`
**Description**: Complete production application URL  
**Example**: `http://54.123.45.69:3000`  
**Use Case**: Access live production application

```bash
# Access production app
curl http://54.123.45.69:3000

# Monitor response time
curl -w "@curl-format.txt" -o /dev/null -s http://54.123.45.69:3000

# Load testing (be careful!)
ab -n 100 -c 10 http://54.123.45.69:3000/
```

---

## 5️⃣ Security Information

### `jenkins_security_group_id`
**Description**: Security group ID for Jenkins server  
**Example**: `sg-0a1b2c3d4e5f6g7h8`  
**Use Case**: Modify security rules

```bash
# View security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Add a new rule (example: allow port 8443)
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 8443 \
  --cidr 0.0.0.0/0
```

### `staging_security_group_id`
**Description**: Security group ID for staging server  
**Example**: `sg-1b2c3d4e5f6g7h8i9`

### `production_security_group_id`
**Description**: Security group ID for production server  
**Example**: `sg-2c3d4e5f6g7h8i9j0`

### `key_pair_name`
**Description**: Name of the SSH key pair  
**Example**: `jenkins-cicd-pipeline-key`  
**Use Case**: Reference for SSH connections

```bash
# View key pair
aws ec2 describe-key-pairs --key-names <key-name>

# Download private key (if created via AWS Console)
# Note: Private key is NOT retrievable if lost!
```

---

## 6️⃣ Connection Commands

### `ssh_connection_jenkins`
**Description**: Ready-to-use SSH command for Jenkins  
**Example**: `ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67`

```bash
# Connect to Jenkins server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67

# Execute remote command
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67 'sudo systemctl status jenkins'

# Copy file to server
scp -i ~/.ssh/jenkins-cicd-key local-file.txt ec2-user@54.123.45.67:/tmp/

# Copy file from server
scp -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67:/var/log/jenkins/jenkins.log .
```

### `ssh_connection_staging`
**Description**: Ready-to-use SSH command for staging  
**Example**: `ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.68`

```bash
# Connect to staging server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.68

# Check Docker status
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.68 'docker ps -a'

# View application logs
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.68 'docker logs -f cicd-app'

# Restart application
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.68 'docker restart cicd-app'
```

### `ssh_connection_production`
**Description**: Ready-to-use SSH command for production  
**Example**: `ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.69`

### `jenkins_initial_password_command`
**Description**: Command to retrieve Jenkins initial admin password  
**Example**: `ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'`

```bash
# Get Jenkins password
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67 \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'

# Copy to clipboard (macOS)
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67 \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' | pbcopy

# Copy to clipboard (Linux with xclip)
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@54.123.45.67 \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' | xclip -selection clipboard
```

---

## 7️⃣ Deployment Summary (JSON Object)

### `deployment_summary`
**Description**: Complete summary of all important information  
**Format**: JSON object with nested data

```json
{
  "jenkins": {
    "ui_url": "http://54.123.45.67:8080",
    "sonarqube_url": "http://54.123.45.67:9000",
    "public_ip": "54.123.45.67",
    "ssh_command": "ssh -i <your-key.pem> ec2-user@54.123.45.67"
  },
  "staging": {
    "app_url": "http://54.123.45.68:3000",
    "public_ip": "54.123.45.68",
    "ssh_command": "ssh -i <your-key.pem> ec2-user@54.123.45.68"
  },
  "production": {
    "app_url": "http://54.123.45.69:3000",
    "public_ip": "54.123.45.69",
    "ssh_command": "ssh -i <your-key.pem> ec2-user@54.123.45.69"
  }
}
```

---

## 🔧 How to Access Outputs

### View All Outputs
```bash
# After terraform apply
terraform output

# In JSON format
terraform output -json

# Save to file
terraform output -json > infrastructure-outputs.json
```

### View Specific Output
```bash
# Get Jenkins URL
terraform output jenkins_url

# Get Jenkins IP (raw format, no quotes)
terraform output -raw jenkins_public_ip

# Get staging IP
terraform output -raw staging_public_ip

# Get production IP
terraform output -raw production_public_ip
```

### Use Outputs in Scripts
```bash
# Bash script example
#!/bin/bash

JENKINS_IP=$(terraform output -raw jenkins_public_ip)
STAGING_IP=$(terraform output -raw staging_public_ip)
PROD_IP=$(terraform output -raw production_public_ip)

echo "Jenkins: http://$JENKINS_IP:8080"
echo "Staging: http://$STAGING_IP:3000"
echo "Production: http://$PROD_IP:3000"

# Update Jenkinsfile
sed -i "s/STAGING_SERVER_IP = .*/STAGING_SERVER_IP = \"$STAGING_IP\"/" ../Jenkinsfile
sed -i "s/PROD_SERVER_IP = .*/PROD_SERVER_IP = \"$PROD_IP\"/" ../Jenkinsfile
```

### Use Outputs in Other Terraform Modules
```hcl
# In another Terraform configuration
data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../terraform/terraform.tfstate"
  }
}

# Reference outputs
resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "jenkins.example.com"
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infra.outputs.jenkins_public_ip]
}
```

---

## 📋 Quick Reference Commands

### Save Important Information
```bash
# Save all outputs to file
terraform output -json > infrastructure-outputs.json

# Extract specific values
terraform output -raw jenkins_public_ip > jenkins-ip.txt
terraform output -raw staging_public_ip > staging-ip.txt
terraform output -raw production_public_ip > production-ip.txt

# Create a summary file
cat << EOF > connection-info.txt
===========================================
Infrastructure Connection Information
===========================================

Jenkins Server:
  URL: $(terraform output -raw jenkins_url)
  SSH: ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)

SonarQube:
  URL: $(terraform output -raw sonarqube_url)

Staging Server:
  URL: $(terraform output -raw staging_app_url)
  SSH: ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw staging_public_ip)

Production Server:
  URL: $(terraform output -raw production_app_url)
  SSH: ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw production_public_ip)

Initial Jenkins Password:
  $(ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip) 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' 2>/dev/null || echo "Not yet available")

===========================================
EOF

cat connection-info.txt
```

### Update Local Jenkinsfile
```bash
# Automatically update Jenkinsfile with server IPs
STAGING_IP=$(terraform output -raw staging_public_ip)
PROD_IP=$(terraform output -raw production_public_ip)

# Update Jenkinsfile
cd ..
sed -i "s/STAGING_SERVER_IP = \"YOUR_STAGING_EC2_IP\"/STAGING_SERVER_IP = \"$STAGING_IP\"/" Jenkinsfile
sed -i "s/PROD_SERVER_IP = \"YOUR_PROD_EC2_IP\"/PROD_SERVER_IP = \"$PROD_IP\"/" Jenkinsfile

echo "Jenkinsfile updated with server IPs"
```

### Test All Endpoints
```bash
# Test script
#!/bin/bash

JENKINS_URL=$(terraform output -raw jenkins_url)
SONAR_URL=$(terraform output -raw sonarqube_url)
STAGING_URL=$(terraform output -raw staging_app_url)
PROD_URL=$(terraform output -raw production_app_url)

echo "Testing Jenkins..."
curl -I $JENKINS_URL 2>/dev/null | head -n 1

echo "Testing SonarQube..."
curl -I $SONAR_URL 2>/dev/null | head -n 1

echo "Testing Staging App..."
curl -I $STAGING_URL 2>/dev/null | head -n 1

echo "Testing Production App..."
curl -I $PROD_URL 2>/dev/null | head -n 1
```

### Monitor All Instances
```bash
# Check status of all instances
aws ec2 describe-instance-status \
  --instance-ids \
    $(terraform output -raw jenkins_instance_id) \
    $(terraform output -raw staging_instance_id) \
    $(terraform output -raw production_instance_id) \
  --query 'InstanceStatuses[*].[InstanceId,InstanceState.Name,SystemStatus.Status,InstanceStatus.Status]' \
  --output table
```

---

## 🎯 Common Use Cases

### 1. First Time Access
```bash
# Get everything you need to start
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
JENKINS_URL=$(terraform output -raw jenkins_url)

# Get initial password
JENKINS_PASSWORD=$(ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$JENKINS_IP \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' 2>/dev/null)

echo "Open: $JENKINS_URL"
echo "Password: $JENKINS_PASSWORD"
```

### 2. Update Application Configuration
```bash
# Update environment variables or configs
PROD_IP=$(terraform output -raw production_public_ip)

ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$PROD_IP << 'EOF'
  docker stop cicd-app
  docker rm cicd-app
  docker run -d \
    --name cicd-app \
    -p 3000:3000 \
    -e NODE_ENV=production \
    -e NEW_CONFIG=value \
    your-image:tag
EOF
```

### 3. Backup Critical Data
```bash
# Backup Jenkins configuration
JENKINS_IP=$(terraform output -raw jenkins_public_ip)

ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$JENKINS_IP \
  'sudo tar czf /tmp/jenkins-backup.tar.gz /var/lib/jenkins'

scp -i ~/.ssh/jenkins-cicd-key \
  ec2-user@$JENKINS_IP:/tmp/jenkins-backup.tar.gz \
  ./backups/jenkins-backup-$(date +%Y%m%d).tar.gz
```

### 4. Check Application Health
```bash
# Health check all environments
for env in staging production; do
  IP=$(terraform output -raw ${env}_public_ip)
  echo "Checking $env ($IP)..."
  curl -s http://$IP:3000/health | jq .
done
```

---

## 📊 Output Summary Table

| Output Name | Type | Purpose | Example |
|-------------|------|---------|---------|
| `vpc_id` | String | VPC identifier | vpc-0a1b2c3d |
| `public_subnet_id` | String | Subnet identifier | subnet-0a1b2c3d |
| `jenkins_instance_id` | String | Jenkins EC2 ID | i-0a1b2c3d |
| `jenkins_public_ip` | String | Jenkins Elastic IP | 54.123.45.67 |
| `jenkins_private_ip` | String | Jenkins private IP | 10.0.1.10 |
| `jenkins_url` | String | Jenkins UI URL | http://54.123.45.67:8080 |
| `sonarqube_url` | String | SonarQube URL | http://54.123.45.67:9000 |
| `staging_instance_id` | String | Staging EC2 ID | i-1b2c3d4e |
| `staging_public_ip` | String | Staging Elastic IP | 54.123.45.68 |
| `staging_private_ip` | String | Staging private IP | 10.0.1.11 |
| `staging_app_url` | String | Staging app URL | http://54.123.45.68:3000 |
| `production_instance_id` | String | Production EC2 ID | i-2c3d4e5f |
| `production_public_ip` | String | Production Elastic IP | 54.123.45.69 |
| `production_private_ip` | String | Production private IP | 10.0.1.12 |
| `production_app_url` | String | Production app URL | http://54.123.45.69:3000 |
| `jenkins_security_group_id` | String | Jenkins SG ID | sg-0a1b2c3d |
| `staging_security_group_id` | String | Staging SG ID | sg-1b2c3d4e |
| `production_security_group_id` | String | Production SG ID | sg-2c3d4e5f |
| `key_pair_name` | String | SSH key name | jenkins-cicd-pipeline-key |
| `ssh_connection_jenkins` | String | Jenkins SSH command | ssh -i ... |
| `ssh_connection_staging` | String | Staging SSH command | ssh -i ... |
| `ssh_connection_production` | String | Production SSH command | ssh -i ... |
| `jenkins_initial_password_command` | String | Get password command | ssh ... |
| `deployment_summary` | Object | Complete summary | {...} |

---

## 💡 Pro Tips

1. **Save outputs immediately after deployment**
   ```bash
   terraform output -json > outputs-$(date +%Y%m%d-%H%M%S).json
   ```

2. **Create shell aliases for quick access**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias jenkins-ssh='ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(cd terraform && terraform output -raw jenkins_public_ip)'
   alias staging-ssh='ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(cd terraform && terraform output -raw staging_public_ip)'
   alias prod-ssh='ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(cd terraform && terraform output -raw production_public_ip)'
   ```

3. **Monitor costs by tagging**
   ```bash
   # View costs by project
   aws ce get-cost-and-usage \
     --time-period Start=2026-06-01,End=2026-06-30 \
     --granularity MONTHLY \
     --metrics UnblendedCost \
     --group-by Type=TAG,Key=Project \
     --filter file://cost-filter.json
   ```

4. **Set up CloudWatch alarms**
   ```bash
   # CPU alarm for production
   aws cloudwatch put-metric-alarm \
     --alarm-name prod-high-cpu \
     --alarm-description "Production CPU > 80%" \
     --metric-name CPUUtilization \
     --namespace AWS/EC2 \
     --statistic Average \
     --period 300 \
     --evaluation-periods 2 \
     --threshold 80 \
     --comparison-operator GreaterThanThreshold \
     --dimensions Name=InstanceId,Value=$(terraform output -raw production_instance_id)
   ```

---

**Remember**: Always keep your infrastructure outputs secure and never commit them to public repositories!

