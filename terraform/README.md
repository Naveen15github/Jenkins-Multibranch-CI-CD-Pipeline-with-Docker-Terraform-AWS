# Terraform Infrastructure for Jenkins CI/CD Pipeline

This Terraform configuration provisions a complete AWS infrastructure for the Jenkins CI/CD pipeline with automated deployments to staging and production environments.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                       │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Public Subnet (10.0.1.0/24)                  │ │
│  │                                                           │ │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   │ │
│  │  │   Jenkins   │   │   Staging   │   │ Production  │   │ │
│  │  │   Server    │   │   Server    │   │   Server    │   │ │
│  │  │             │   │             │   │             │   │ │
│  │  │ t3.medium   │   │  t3.micro   │   │  t3.small   │   │ │
│  │  │             │   │             │   │             │   │ │
│  │  │ :8080 :9000 │   │    :3000    │   │    :3000    │   │ │
│  │  │             │   │             │   │             │   │ │
│  │  │  + SonarQube│   │   Docker    │   │   Docker    │   │ │
│  │  └─────────────┘   └─────────────┘   └─────────────┘   │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│                    Internet Gateway                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                        Internet
```

## Infrastructure Components

### 1. **Networking**
- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnet**: Public subnet (10.0.1.0/24) with internet access
- **Internet Gateway**: For public internet connectivity
- **Route Tables**: Configured for public internet access
- **Elastic IPs**: Static IPs for all 3 servers for stable addressing

### 2. **EC2 Instances**

| Server     | Instance Type | Purpose                        | Ports       |
|------------|---------------|--------------------------------|-------------|
| Jenkins    | t3.medium     | CI/CD orchestration + SonarQube| 22, 8080, 9000 |
| Staging    | t3.micro      | Staging environment            | 22, 3000    |
| Production | t3.small      | Production environment         | 22, 3000    |

### 3. **Security Groups**

**Jenkins Security Group:**
- Port 22 (SSH) - Restricted to specified IPs
- Port 8080 (Jenkins UI) - Restricted to specified IPs
- Port 9000 (SonarQube) - Restricted to specified IPs
- All outbound traffic allowed

**Staging/Production Security Groups:**
- Port 22 (SSH) - From your IP + Jenkins server
- Port 3000 (Application) - Open to internet (0.0.0.0/0)
- All outbound traffic allowed

### 4. **IAM Roles & Policies**
- EC2 instance role with policies for:
  - CloudWatch Logs (logging)
  - ECR access (if using AWS ECR for Docker images)
  - EC2 describe tags (for auto-configuration)

### 5. **CloudWatch Log Groups**
- `/aws/ec2/jenkins-cicd-pipeline-jenkins` (7 days retention)
- `/aws/ec2/jenkins-cicd-pipeline-staging` (7 days retention)
- `/aws/ec2/jenkins-cicd-pipeline-production` (30 days retention)

### 6. **User Data Scripts**
Automated setup scripts that run on first boot:
- **Jenkins server**: Installs Jenkins, Docker, SonarQube, Node.js, AWS CLI
- **App servers**: Installs Docker, Docker Compose, CloudWatch agent, AWS CLI

## Prerequisites

Before running Terraform, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** >= 1.0 installed
4. **SSH Key Pair** generated for EC2 access

### Generate SSH Key Pair

```bash
# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins-cicd-key -C "your-email@example.com"

# The public key will be at: ~/.ssh/jenkins-cicd-key.pub
# The private key will be at: ~/.ssh/jenkins-cicd-key
```

## Installation Steps

### 1. Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

### 2. Prepare Terraform Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# IMPORTANT: Update these values!
# - ssh_public_key: Your SSH public key content
# - allowed_ssh_cidr: Your IP address
# - allowed_jenkins_cidr: Your IP address
# - docker_hub_username: Your Docker Hub username
# - docker_hub_password: Your Docker Hub token
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Review the Execution Plan

```bash
terraform plan
```

This will show you all resources that will be created. Review carefully.

### 5. Apply the Configuration

```bash
terraform apply

# Type 'yes' when prompted
```

The provisioning will take approximately 5-10 minutes.

### 6. Save the Outputs

```bash
# Display all outputs
terraform output

# Save outputs to a file for reference
terraform output -json > infrastructure-outputs.json
```

## Post-Deployment Configuration

### 1. Access Jenkins

After deployment completes:

```bash
# Get the Jenkins URL from outputs
terraform output jenkins_url

# Retrieve the initial admin password
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip) \
  'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
```

Open the Jenkins URL in your browser and complete the setup wizard.

### 2. Install Jenkins Plugins

In Jenkins UI, go to **Manage Jenkins > Plugin Manager** and install:
- Git
- Pipeline
- Multibranch Pipeline
- Docker Pipeline
- SonarQube Scanner
- SSH Agent
- Credentials Binding
- HTML Publisher
- JUnit

### 3. Configure Jenkins Credentials

Go to **Manage Jenkins > Credentials > System > Global credentials**

Add the following credentials:

| ID                     | Type              | Value                                    |
|------------------------|-------------------|------------------------------------------|
| DOCKER_HUB_CREDENTIALS | Username/Password | Docker Hub username + token              |
| SSH_KEY                | SSH Username+Key  | ec2-user + contents of private key       |
| SLACK_WEBHOOK          | Secret Text       | Your Slack webhook URL                   |
| SONAR_TOKEN            | Secret Text       | SonarQube token (generate in SonarQube)  |

### 4. Configure SonarQube

```bash
# Get the SonarQube URL
terraform output sonarqube_url
```

1. Open SonarQube in browser (default: admin/admin)
2. Change the default password
3. Create a new project: **jenkins-cicd-pipeline**
4. Generate a token and save it
5. Configure webhook: `http://<jenkins-ip>:8080/sonarqube-webhook/`

### 5. Configure SonarQube in Jenkins

Go to **Manage Jenkins > Configure System > SonarQube servers**:
- Name: `SonarQube`
- Server URL: `http://localhost:9000`
- Server authentication token: Select `SONAR_TOKEN` credential

### 6. Update Jenkinsfile

Update the following variables in your `Jenkinsfile`:

```groovy
DOCKER_IMAGE      = "your-dockerhub-username/myapp"
STAGING_SERVER_IP = "<staging-public-ip>"    // From terraform output
PROD_SERVER_IP    = "<production-public-ip>"  // From terraform output
```

Get the IPs from Terraform outputs:

```bash
terraform output staging_public_ip
terraform output production_public_ip
```

### 7. Create Multi-Branch Pipeline

1. In Jenkins, click **New Item**
2. Enter name: `jenkins-cicd-pipeline`
3. Select **Multibranch Pipeline**
4. Configure Git repository
5. Save - Jenkins will scan branches automatically

## Testing the Infrastructure

### 1. Test Jenkins Server

```bash
# SSH to Jenkins server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)

# Check Jenkins status
sudo systemctl status jenkins

# Check Docker status
docker ps

# Check SonarQube container
docker ps | grep sonarqube
```

### 2. Test Staging Server

```bash
# SSH to Staging server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw staging_public_ip)

# Check Docker status
docker --version
docker ps
```

### 3. Test Production Server

```bash
# SSH to Production server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw production_public_ip)

# Check Docker status
docker --version
docker ps
```

## Useful Commands

### View All Outputs

```bash
terraform output
```

### View Specific Output

```bash
terraform output jenkins_public_ip
terraform output staging_public_ip
terraform output production_public_ip
```

### View Deployment Summary

```bash
terraform output deployment_summary
```

### SSH to Servers

```bash
# Jenkins
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)

# Staging
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw staging_public_ip)

# Production
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw production_public_ip)
```

### View CloudWatch Logs

```bash
# List log streams for Jenkins
aws logs describe-log-streams \
  --log-group-name /aws/ec2/jenkins-cicd-pipeline-jenkins

# Tail Jenkins logs
aws logs tail /aws/ec2/jenkins-cicd-pipeline-jenkins --follow
```

## Cost Estimation

Estimated monthly AWS costs (us-east-1 region):

| Resource         | Type      | Monthly Cost |
|------------------|-----------|--------------|
| Jenkins EC2      | t3.medium | ~$30         |
| Staging EC2      | t3.micro  | ~$7          |
| Production EC2   | t3.small  | ~$15         |
| Elastic IPs (3)  | -         | ~$11         |
| EBS Storage      | 70 GB     | ~$7          |
| Data Transfer    | Varies    | ~$5          |
| **Total**        |           | **~$75/mo**  |

*Costs may vary based on usage, data transfer, and region.*

## Security Best Practices

### 1. **Restrict IP Access**
Update `terraform.tfvars` with your specific IP:

```hcl
allowed_ssh_cidr     = ["YOUR_IP/32"]
allowed_jenkins_cidr = ["YOUR_IP/32"]
```

### 2. **Use AWS Secrets Manager**
Store sensitive credentials in AWS Secrets Manager instead of tfvars:

```bash
aws secretsmanager create-secret \
  --name jenkins-cicd-docker-hub-token \
  --secret-string "your-token-here"
```

### 3. **Enable CloudTrail**
Enable AWS CloudTrail for audit logging of all API calls.

### 4. **Enable VPC Flow Logs**
Monitor network traffic with VPC Flow Logs.

### 5. **Use IAM Roles**
Use IAM roles instead of storing AWS credentials on instances.

## Updating the Infrastructure

### Modify Resources

```bash
# Edit variables in terraform.tfvars
nano terraform.tfvars

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### Add Tags

```bash
# Update additional_tags in terraform.tfvars
additional_tags = {
  Owner      = "Your Team"
  CostCenter = "Engineering"
}

# Apply
terraform apply
```

## Destroying the Infrastructure

**WARNING:** This will permanently delete all resources!

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

## Troubleshooting

### Issue: Jenkins Not Starting

```bash
# SSH to Jenkins server
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$(terraform output -raw jenkins_public_ip)

# Check Jenkins status
sudo systemctl status jenkins

# View Jenkins logs
sudo journalctl -u jenkins -f
```

### Issue: SonarQube Not Accessible

```bash
# Check SonarQube container
docker ps | grep sonarqube

# View SonarQube logs
docker logs sonarqube
```

### Issue: Cannot SSH to Instances

1. Verify security group allows your IP
2. Verify key pair is correct
3. Check instance status in AWS Console

```bash
# Update security group if needed
terraform apply -target=aws_security_group.jenkins
```

### Issue: High AWS Costs

```bash
# Review current resources
terraform state list

# Check instance types
terraform state show aws_instance.jenkins

# Consider downsizing
# Edit terraform.tfvars and change instance types
```

## Backup and Disaster Recovery

### Backup Jenkins Configuration

```bash
# Create AMI snapshot of Jenkins server
aws ec2 create-image \
  --instance-id $(terraform output -raw jenkins_instance_id) \
  --name "jenkins-backup-$(date +%Y%m%d)" \
  --description "Jenkins backup"
```

### Restore from Backup

```bash
# Update variables.tf to use backed-up AMI
# Then run terraform apply
```

## Maintenance

### Update User Data Scripts

After updating user-data scripts, you need to recreate instances:

```bash
# Taint the resource to force recreation
terraform taint aws_instance.jenkins

# Apply changes
terraform apply
```

### Update Security Groups

Security groups can be updated without recreating instances:

```bash
# Edit main.tf security group rules
# Apply changes
terraform apply
```

## Support

For issues or questions:
1. Check CloudWatch Logs for application logs
2. Review EC2 instance system logs in AWS Console
3. Check Jenkins build logs
4. Review this README for troubleshooting steps

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
