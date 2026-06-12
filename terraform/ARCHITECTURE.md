# Infrastructure Architecture Documentation

## Overview

This document describes the complete AWS infrastructure architecture for the Jenkins CI/CD pipeline, including all resources, networking, security, and deployment workflows.

## Architecture Diagram

```
                                    Internet
                                       │
                                       │
                        ┌──────────────┴──────────────┐
                        │    Internet Gateway         │
                        └──────────────┬──────────────┘
                                       │
                ┏━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━┓
                ┃           VPC (10.0.0.0/16)                  ┃
                ┃                                              ┃
                ┃  ┌───────────────────────────────────────┐  ┃
                ┃  │  Public Subnet (10.0.1.0/24)          │  ┃
                ┃  │                                        │  ┃
                ┃  │  ┌────────────────────────────────┐   │  ┃
                ┃  │  │  Jenkins Server (t3.medium)    │   │  ┃
                ┃  │  │  ┌──────────────────────────┐  │   │  ┃
                ┃  │  │  │ Jenkins (Port 8080)      │  │   │  ┃
                ┃  │  │  │ • Multi-branch pipelines │  │   │  ┃
                ┃  │  │  │ • Git integration        │  │   │  ┃
                ┃  │  │  │ • Docker builds          │  │   │  ┃
                ┃  │  │  │ • SSH deployments        │  │   │  ┃
                ┃  │  │  └──────────────────────────┘  │   │  ┃
                ┃  │  │  ┌──────────────────────────┐  │   │  ┃
                ┃  │  │  │ SonarQube (Port 9000)    │  │   │  ┃
                ┃  │  │  │ • Code quality analysis  │  │   │  ┃
                ┃  │  │  │ • Quality gates          │  │   │  ┃
                ┃  │  │  │ • Coverage reports       │  │   │  ┃
                ┃  │  │  └──────────────────────────┘  │   │  ┃
                ┃  │  │  • Node.js 18                  │   │  ┃
                ┃  │  │  • Docker & Docker Compose     │   │  ┃
                ┃  │  │  • AWS CLI                     │   │  ┃
                ┃  │  │  • CloudWatch Agent            │   │  ┃
                ┃  │  │  EIP: X.X.X.X                  │   │  ┃
                ┃  │  └────────────────────────────────┘   │  ┃
                ┃  │                │                       │  ┃
                ┃  │                │ SSH Deploy            │  ┃
                ┃  │       ┌────────┴────────┐             │  ┃
                ┃  │       │                 │             │  ┃
                ┃  │  ┌────▼───────┐   ┌────▼───────┐     │  ┃
                ┃  │  │  Staging   │   │ Production │     │  ┃
                ┃  │  │ (t3.micro) │   │ (t3.small) │     │  ┃
                ┃  │  │            │   │            │     │  ┃
                ┃  │  │ Docker     │   │ Docker     │     │  ┃
                ┃  │  │ App:3000   │   │ App:3000   │     │  ┃
                ┃  │  │            │   │            │     │  ┃
                ┃  │  │ CloudWatch │   │ CloudWatch │     │  ┃
                ┃  │  │ Agent      │   │ Agent      │     │  ┃
                ┃  │  │            │   │            │     │  ┃
                ┃  │  │ EIP: Y.Y.Y │   │ EIP: Z.Z.Z │     │  ┃
                ┃  │  └────────────┘   └────────────┘     │  ┃
                ┃  └───────────────────────────────────────┘  ┃
                ┃                                              ┃
                ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

            ┌─────────────────────────────────────────────┐
            │         External Services                   │
            ├─────────────────────────────────────────────┤
            │  • Docker Hub (image registry)              │
            │  • GitHub/GitLab (source control)           │
            │  • Slack (notifications)                    │
            │  • CloudWatch Logs (centralized logging)    │
            └─────────────────────────────────────────────┘
```

## CI/CD Pipeline Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                     DEVELOPER WORKFLOW                           │
└──────────────────────────────────────────────────────────────────┘
                               │
                    git push origin <branch>
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                    JENKINS MULTI-BRANCH PIPELINE                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐   ┌──────────────┐   ┌────────────────┐       │
│  │  Checkout   │──▶│  Install     │──▶│   Run Tests    │       │
│  │             │   │  Dependencies│   │   (npm test)   │       │
│  └─────────────┘   └──────────────┘   └────────────────┘       │
│                                               │                  │
│                         ┌─────────────────────┴──────┐          │
│                         │                            │          │
│                    dev branch              staging/main branch  │
│                         │                            │          │
│                    ┌────▼────┐              ┌────────▼────────┐ │
│                    │ Slack   │              │  SonarQube      │ │
│                    │ Notify  │              │  Code Analysis  │ │
│                    └─────────┘              └────────┬────────┘ │
│                                                      │          │
│                                             ┌────────▼────────┐ │
│                                             │  Quality Gate   │ │
│                                             │  (Pass/Fail)    │ │
│                                             └────────┬────────┘ │
│                                                      │          │
│                                             ┌────────▼────────┐ │
│                                             │  Docker Build   │ │
│                                             │  & Push to Hub  │ │
│                                             └────────┬────────┘ │
│                                                      │          │
│                         ┌────────────────────────────┴───────┐  │
│                         │                                    │  │
│                    staging branch                       main branch
│                         │                                    │  │
│                 ┌───────▼────────┐               ┌──────────▼──┐ │
│                 │  Deploy to     │               │   Manual    │ │
│                 │  Staging EC2   │               │  Approval   │ │
│                 └───────┬────────┘               └──────┬──────┘ │
│                         │                               │        │
│                 ┌───────▼────────┐               ┌──────▼──────┐ │
│                 │ Health Check   │               │   Deploy to │ │
│                 │  (Pass/Fail)   │               │   Prod EC2  │ │
│                 └───────┬────────┘               └──────┬──────┘ │
│                         │                               │        │
│                 ┌───────▼────────┐               ┌──────▼──────┐ │
│                 │  Slack Notify  │               │Health Check │ │
│                 │   (Success)    │               │(Pass/Fail)  │ │
│                 └────────────────┘               └──────┬──────┘ │
│                                                          │        │
│                                              ┌───────────▼──────┐ │
│                                              │   Auto-Rollback  │ │
│                                              │   (if failed)    │ │
│                                              └───────────┬──────┘ │
│                                                          │        │
│                                              ┌───────────▼──────┐ │
│                                              │  Slack Notify    │ │
│                                              │ (Success/Fail)   │ │
│                                              └──────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

## Resource Inventory

### Compute Resources

| Resource | Type | Specs | Purpose | Monthly Cost |
|----------|------|-------|---------|--------------|
| Jenkins Server | EC2 t3.medium | 2 vCPU, 4 GB RAM, 30 GB storage | CI/CD orchestration, SonarQube hosting | ~$30 |
| Staging Server | EC2 t3.micro | 2 vCPU, 1 GB RAM, 20 GB storage | Staging environment testing | ~$7 |
| Production Server | EC2 t3.small | 2 vCPU, 2 GB RAM, 20 GB storage | Production application hosting | ~$15 |

### Network Resources

| Resource | Configuration | Purpose |
|----------|---------------|---------|
| VPC | 10.0.0.0/16 | Isolated network for all resources |
| Public Subnet | 10.0.1.0/24 | Hosts all EC2 instances with internet access |
| Internet Gateway | - | Enables internet connectivity |
| Route Table | Public routes | Routes traffic to internet via IGW |
| Elastic IP (Jenkins) | Static public IP | Stable Jenkins/SonarQube access |
| Elastic IP (Staging) | Static public IP | Stable staging app access |
| Elastic IP (Production) | Static public IP | Stable production app access |

### Security Resources

| Resource | Rules | Purpose |
|----------|-------|---------|
| Jenkins Security Group | SSH (22), Jenkins (8080), SonarQube (9000) | Controls access to Jenkins server |
| Staging Security Group | SSH (22), App (3000) | Controls access to staging server |
| Production Security Group | SSH (22), App (3000) | Controls access to production server |
| IAM Role (ec2_role) | CloudWatch, ECR permissions | Allows EC2 instances to interact with AWS services |
| IAM Instance Profile | Attaches role to instances | Provides AWS credentials to instances |
| SSH Key Pair | RSA 4096-bit | Secure SSH access to all instances |

### Monitoring Resources

| Resource | Retention | Purpose |
|----------|-----------|---------|
| CloudWatch Log Group (Jenkins) | 7 days | Jenkins application logs |
| CloudWatch Log Group (Staging) | 7 days | Staging application logs |
| CloudWatch Log Group (Production) | 30 days | Production application logs |
| CloudWatch Agent | - | Collects and ships logs to CloudWatch |

## Security Architecture

### Network Security

```
┌─────────────────────────────────────────────────────────┐
│                    INTERNET                             │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    Your IP     Any IP      Any IP
         │           │           │
         │           │           │
    ┌────▼───┐  ┌───▼───┐  ┌────▼────┐
    │SSH:22  │  │8080   │  │3000     │
    │        │  │9000   │  │         │
    └────┬───┘  └───┬───┘  └────┬────┘
         │          │           │
    ┌────▼──────────▼───────────▼────┐
    │      Security Groups           │
    │  • Stateful firewall          │
    │  • Allow only specified ports │
    │  • Deny all by default        │
    └────┬──────────────────────────┘
         │
    ┌────▼──────────────────────────┐
    │         EC2 Instances         │
    │  • No public keys stored      │
    │  • IAM roles for AWS access   │
    │  • Encrypted EBS volumes      │
    └───────────────────────────────┘
```

### Access Control Matrix

| Service | Port | Source | Protocol | Purpose |
|---------|------|--------|----------|---------|
| SSH (Jenkins) | 22 | Your IP | TCP | Remote administration |
| Jenkins UI | 8080 | Your IP | TCP | CI/CD management |
| SonarQube | 9000 | Your IP | TCP | Code quality dashboard |
| SSH (Staging) | 22 | Your IP + Jenkins SG | TCP | Deployment & administration |
| Staging App | 3000 | 0.0.0.0/0 | TCP | Public application access |
| SSH (Production) | 22 | Your IP + Jenkins SG | TCP | Deployment & administration |
| Production App | 3000 | 0.0.0.0/0 | TCP | Public application access |

### IAM Permissions

```json
{
  "Jenkins/Staging/Production EC2 Instances": {
    "CloudWatch Logs": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ],
    "ECR": [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ],
    "EC2": [
      "ec2:DescribeTags"
    ]
  }
}
```

## Deployment Architecture

### Application Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│                 JENKINS SERVER                              │
│                                                             │
│  1. Build Docker Image                                      │
│     docker build -t myapp:$BUILD_NUMBER .                  │
│                                                             │
│  2. Push to Docker Hub                                      │
│     docker push myapp:$BUILD_NUMBER                        │
│                                                             │
│  3. SSH to Target Server                                    │
│     ssh ec2-user@<server-ip>                               │
│                                                             │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
┌─────────────────────┐       ┌─────────────────────┐
│  STAGING SERVER     │       │  PRODUCTION SERVER  │
│                     │       │                     │
│  1. Pull Image      │       │  1. Pull Image      │
│  2. Stop Old        │       │  2. Stop Old        │
│  3. Start New       │       │  3. Start New       │
│  4. Health Check    │       │  4. Health Check    │
│                     │       │  5. Rollback if Fail│
└─────────────────────┘       └─────────────────────┘
```

### Container Management

Each application server runs:
- **Single Docker container** for the Node.js application
- **Port mapping**: Host 3000 → Container 3000
- **Restart policy**: `unless-stopped` for high availability
- **Environment**: `NODE_ENV=production`

Container lifecycle:
1. Pull latest image from Docker Hub
2. Stop and remove existing container
3. Start new container with updated image
4. Verify health via HTTP endpoint
5. Rollback if health check fails (production only)

## Data Flow

### Build Pipeline Data Flow

```
Developer → Git Push → Jenkins
                        ↓
                    Checkout Code
                        ↓
                    npm install
                        ↓
                    npm test (Jest)
                        ↓
                    Coverage Report → Jenkins UI
                        ↓
                [staging/main only]
                        ↓
                    SonarQube Scan
                        ↓
                    Quality Gate Check
                        ↓
                    Docker Build
                        ↓
                    Docker Hub ← Push Image
                        ↓
                    SSH Deploy → App Server
                        ↓
                    Health Check
                        ↓
                    Slack Notification
```

### Log Flow

```
Application Logs → Docker Container
                        ↓
              docker logs -f cicd-app
                        ↓
              /var/log/docker-app.log
                        ↓
              CloudWatch Agent
                        ↓
              CloudWatch Logs
                        ↓
              AWS Console / CLI
```

## High Availability Considerations

### Current Setup
- **Single instance per environment** (not HA)
- **Elastic IPs** for stable addressing
- **Automated rollback** on production failures
- **Docker restart policy** for automatic recovery

### Recommended HA Improvements
1. **Use Application Load Balancer** (ALB) for production
2. **Deploy to multiple AZs** with Auto Scaling
3. **Implement database** with RDS Multi-AZ
4. **Add Route 53** for DNS management
5. **Use ElastiCache** for session management
6. **Implement S3** for artifact storage
7. **Add CloudFront** for CDN capabilities

## Disaster Recovery

### Backup Strategy

| Component | Backup Method | Frequency | Retention |
|-----------|---------------|-----------|-----------|
| Jenkins Configuration | AMI Snapshot | Manual/Weekly | 4 weeks |
| Application Code | Git Repository | Continuous | Indefinite |
| Docker Images | Docker Hub | Per build | Tagged |
| Infrastructure Code | Git (Terraform) | Continuous | Indefinite |
| CloudWatch Logs | AWS CloudWatch | Automatic | 7-30 days |

### Recovery Procedures

**Jenkins Server Failure:**
```bash
# 1. Restore from AMI snapshot
aws ec2 create-image --instance-id <jenkins-id> --name jenkins-restore

# 2. Launch new instance from AMI
# 3. Associate Elastic IP to new instance
# 4. Verify Jenkins and SonarQube are running
```

**Application Server Failure:**
```bash
# 1. Terminate failed instance
# 2. Launch new instance with Terraform
terraform apply -target=aws_instance.staging

# 3. Re-run deployment pipeline
# Jenkinsfile will automatically deploy latest build
```

**Complete Infrastructure Loss:**
```bash
# 1. Restore from Terraform state
terraform init
terraform apply

# 2. Reconfigure Jenkins from documentation
# 3. Re-run pipelines to deploy applications
```

## Monitoring and Alerting

### Current Monitoring
- ✅ CloudWatch Logs for all servers
- ✅ Jenkins build status in UI
- ✅ SonarQube quality metrics
- ✅ Slack notifications for builds
- ✅ Health check endpoints

### Recommended Additions
- ❌ CloudWatch Metrics for CPU/Memory/Disk
- ❌ CloudWatch Alarms for resource thresholds
- ❌ Application Performance Monitoring (APM)
- ❌ Uptime monitoring (e.g., Pingdom, UptimeRobot)
- ❌ Log aggregation and analysis (e.g., ELK stack)

## Scaling Considerations

### Vertical Scaling (Current)
```
t3.micro → t3.small → t3.medium → t3.large
```
Easy to implement via instance type change in Terraform.

### Horizontal Scaling (Future)
```
Single Instance → Auto Scaling Group → Multi-AZ Deployment
```
Requires:
- Application Load Balancer
- Auto Scaling Group configuration
- Stateless application design
- Shared session storage (ElastiCache)
- Database migration to RDS

## Cost Optimization

### Current Monthly Costs: ~$75

| Optimization | Savings | Trade-off |
|--------------|---------|-----------|
| Use t3.micro for all instances | ~$30/mo | Less performance |
| Stop instances during off-hours | ~$40/mo | Manual start/stop |
| Use Spot Instances | ~$50/mo | Potential interruptions |
| Remove Elastic IPs | ~$11/mo | Dynamic IPs |
| Reduce log retention | ~$2/mo | Less historical data |

### Cost Monitoring
```bash
# View current month costs
aws ce get-cost-and-usage \
  --time-period Start=2026-06-01,End=2026-06-30 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=TAG,Key=Project

# Set up billing alarm
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alarm \
  --alarm-description "Alert when charges exceed $100" \
  --metric-name EstimatedCharges \
  --threshold 100
```

## Compliance and Security Standards

### Implemented Security Controls
- ✅ Encryption at rest (EBS volumes)
- ✅ Encryption in transit (HTTPS for Jenkins/SonarQube)
- ✅ Least privilege IAM roles
- ✅ Security group restrictions
- ✅ SSH key-based authentication
- ✅ Automated security scanning (SonarQube)
- ✅ Audit logging (CloudWatch Logs)

### Additional Recommendations
- ❌ AWS WAF for application firewall
- ❌ AWS Shield for DDoS protection
- ❌ AWS GuardDuty for threat detection
- ❌ AWS Config for compliance monitoring
- ❌ Secrets Manager for credential management
- ❌ SSL/TLS certificates (ACM) for HTTPS
- ❌ VPC Flow Logs for network monitoring

## Maintenance Windows

### Regular Maintenance Tasks

| Task | Frequency | Downtime | Automation |
|------|-----------|----------|------------|
| OS Security Patches | Monthly | 5-10 min | Manual |
| Jenkins Plugin Updates | Monthly | 2-5 min | Manual |
| Docker Image Cleanup | Weekly | None | Automated |
| Log Rotation | Daily | None | Automated |
| Terraform State Backup | Weekly | None | Automated |
| Jenkins AMI Backup | Weekly | None | Automated |

### Maintenance Procedure
```bash
# 1. Notify team of maintenance window
# 2. SSH to each server and update
yum update -y

# 3. Restart services if needed
sudo systemctl restart jenkins
sudo systemctl restart docker

# 4. Verify services are running
sudo systemctl status jenkins
docker ps

# 5. Test applications
curl http://<server-ip>:3000/health
```

## Troubleshooting Guide

### Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Jenkins not accessible | Cannot reach port 8080 | Check security group, verify instance status |
| SonarQube not starting | Port 9000 unavailable | Check Docker container: `docker logs sonarqube` |
| Deployment fails | SSH connection refused | Verify SSH_KEY credential, check security group |
| Health check fails | Rollback triggered | Check application logs, verify port 3000 listening |
| High costs | AWS bill exceeds estimate | Review CloudWatch metrics, check for unused resources |
| Out of disk space | Builds fail | Clean up old Docker images: `docker system prune -a` |

## Summary

This infrastructure provides a **production-ready CI/CD pipeline** with:

✅ **Automated testing** and quality gates  
✅ **Multi-environment** deployment (dev, staging, production)  
✅ **Security best practices** with IAM, security groups, encryption  
✅ **Monitoring and logging** via CloudWatch  
✅ **Automated rollback** for failed deployments  
✅ **Infrastructure as Code** with Terraform  
✅ **Cost-effective** at ~$75/month  

**Total deployment time**: ~20 minutes  
**Monthly operational cost**: ~$75  
**Infrastructure managed**: 3 EC2 instances, VPC, security, monitoring  

For questions or improvements, see the main README.md or QUICKSTART.md files.
