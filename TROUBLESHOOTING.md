# 🔧 Troubleshooting Guide

Common issues and their solutions for your Jenkins CI/CD pipeline.

---

## 🚫 Jenkins Issues

### Jenkins Won't Load / Times Out

**Symptom:** Browser can't reach http://54.174.211.72:8080

**Solutions:**
1. Check if Jenkins service is running:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
sudo systemctl status jenkins
```

2. If stopped, restart it:
```powershell
sudo systemctl restart jenkins
```

3. Wait 1-2 minutes and try again

4. Check Jenkins logs:
```powershell
sudo journalctl -u jenkins -n 50
```

### Jenkins Initial Password Not Working

**Symptom:** Password `5ff6fbd59bee4a04b74d2fb5b5d21eb2` is rejected

**Solution:**
Get the current password:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Plugins Failed to Install

**Symptom:** Plugin installation errors during setup

**Solutions:**
1. Check internet connectivity on Jenkins server
2. Try again: Manage Jenkins → Plugins → Available plugins
3. Manually restart: `ssh` to server, run `sudo systemctl restart jenkins`

### Jenkins Runs Out of Memory

**Symptom:** Jenkins becomes slow or unresponsive

**Solution:**
Increase Java heap size:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
sudo vi /etc/sysconfig/jenkins
# Change JENKINS_JAVA_OPTIONS to include: -Xmx2048m
sudo systemctl restart jenkins
```

---

## 🔍 SonarQube Issues

### SonarQube Won't Load

**Symptom:** Can't access http://54.174.211.72:9000

**Solutions:**
1. Check if SonarQube container is running:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
docker ps -a | grep sonarqube
```

2. Check container logs:
```powershell
docker logs sonarqube
```

3. Restart SonarQube:
```powershell
docker restart sonarqube
```

4. If container doesn't exist, recreate it:
```powershell
docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  --restart unless-stopped \
  sonarqube:10-community
```

### SonarQube Takes Too Long to Start

**Symptom:** SonarQube not ready after 5+ minutes

**Solutions:**
1. SonarQube needs 2-3 minutes on first start
2. Check if it's still starting:
```powershell
docker logs sonarqube --follow
```

3. Look for: "SonarQube is operational"

### SonarQube Quality Gate Fails in Pipeline

**Symptom:** Pipeline fails at "Quality Gate" stage

**Solutions:**
1. Check if webhook is configured correctly
2. In SonarQube: Administration → Configuration → Webhooks
3. Verify URL: `http://localhost:8080/sonarqube-webhook/`
4. Check SonarQube project exists: `jenkins-cicd-pipeline`
5. Verify SONAR_TOKEN credential in Jenkins

---

## 🔐 Credentials Issues

### Docker Hub Login Fails

**Symptom:** Pipeline fails with "unauthorized" or "login failed"

**Solutions:**
1. Verify credentials in Jenkins:
   - Go to: Manage Jenkins → Credentials
   - Check DOCKER_HUB_CREDENTIALS
   - Username: `naveen152005`
   - Password: `naveen@123`

2. Test Docker Hub login manually:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
echo "naveen@123" | docker login -u naveen152005 --password-stdin
```

3. If login fails, verify credentials on Docker Hub website

### SSH Key Not Working

**Symptom:** Pipeline fails during deployment with "Permission denied"

**Solutions:**
1. Verify SSH_KEY credential in Jenkins has correct key
2. Test SSH manually:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
```

3. If manual SSH works but pipeline fails:
   - Check SSH_KEY credential in Jenkins
   - Ensure entire key is copied (including BEGIN/END lines)
   - No extra spaces or line breaks

4. Verify key permissions:
```powershell
# On Windows
icacls C:\Users\Naveen\.ssh\jenkins-cicd-key
```

---

## 🚀 Deployment Issues

### Deployment to Staging/Production Fails

**Symptom:** Pipeline fails at "Deploy to Staging/Production" stage

**Solutions:**
1. Check if Docker is running on target server:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
docker ps
```

2. Check deploy script logs in Jenkins console output

3. Verify server IPs in Jenkinsfile:
   - STAGING_SERVER_IP = "3.213.252.204"
   - PROD_SERVER_IP = "34.194.214.144"

4. Test manual deployment:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
docker pull naveen152005/myapp:latest
docker run -d -p 3000:3000 --name cicd-app naveen152005/myapp:latest
```

### Health Check Fails After Deployment

**Symptom:** Deployment succeeds but health check fails

**Solutions:**
1. Check if container is running:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
docker ps
```

2. Check container logs:
```powershell
docker logs cicd-app
```

3. Test health endpoint manually:
```powershell
curl http://3.213.252.204:3000/health
```

4. Check if port 3000 is accessible:
```powershell
curl http://3.213.252.204:3000
```

5. Verify security group allows traffic on port 3000 from Jenkins server

### Rollback Executes Unexpectedly

**Symptom:** Production deployment rolls back automatically

**Solutions:**
1. Check health-check.sh script timeout settings
2. Verify production server is accessible from Jenkins
3. Check if previous build exists to rollback to
4. Review Jenkins console output for exact failure reason

---

## 🌐 Network/Connectivity Issues

### Can't SSH to Servers

**Symptom:** `ssh` command times out or connection refused

**Solutions:**
1. Verify your current public IP:
```powershell
curl ifconfig.me
```

2. Check if IP changed (was: 122.164.251.126)

3. If changed, update security groups:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
# Update terraform.tfvars with new IP
terraform apply
```

4. Verify SSH key permissions:
```powershell
icacls C:\Users\Naveen\.ssh\jenkins-cicd-key /inheritance:r /grant:r "%USERNAME%:R"
```

### Can't Access Application URLs

**Symptom:** Can't reach http://3.213.252.204:3000

**Solutions:**
1. Check if container is running:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
docker ps
```

2. Check if application is listening:
```powershell
curl localhost:3000
```

3. If works locally but not externally, check security group rules

4. Verify instance is running:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform show | grep instance_state
```

---

## 📦 Pipeline Build Issues

### Tests Fail in Pipeline

**Symptom:** Pipeline fails at "Run Tests" stage

**Solutions:**
1. Check test output in Jenkins console
2. Run tests locally:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline
npm install
npm test
```

3. Fix failing tests before pushing

### Docker Build Fails

**Symptom:** Pipeline fails at "Docker Build & Push" stage

**Solutions:**
1. Check Dockerfile syntax
2. Verify Docker daemon is running on Jenkins server:
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
docker ps
```

3. Check disk space:
```powershell
df -h
```

4. Clean up old images:
```powershell
docker system prune -f
```

### Pipeline Doesn't Trigger

**Symptom:** Push to branch doesn't trigger Jenkins build

**Solutions:**
1. Verify branch exists in Jenkins multibranch pipeline
2. Manually trigger branch scan:
   - Go to pipeline → "Scan Multibranch Pipeline Now"

3. Check Jenkins credentials for Git repository access

4. Verify Jenkinsfile exists in branch root

---

## 🔄 Git Issues

### Can't Push to Repository

**Symptom:** `git push` fails with authentication error

**Solutions:**
1. If using HTTPS, generate GitHub Personal Access Token:
   - GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token with "repo" permissions
   - Use token as password

2. If using SSH, verify SSH key is added to GitHub:
   - GitHub → Settings → SSH and GPG keys

3. Update remote URL:
```powershell
git remote set-url origin https://github.com/yourusername/jenkins-cicd-pipeline.git
```

### Branch Doesn't Show in Jenkins

**Symptom:** Created branch but Jenkins doesn't detect it

**Solutions:**
1. Push branch to remote:
```powershell
git push origin branch-name
```

2. Trigger manual scan in Jenkins:
   - Pipeline → "Scan Multibranch Pipeline Now"

3. Check Jenkins logs for scan errors

---

## 💰 AWS Cost Issues

### Unexpected High Costs

**Symptom:** AWS bill higher than expected ~$77/month

**Solutions:**
1. Check data transfer costs (should be minimal)
2. Verify only 3 instances running:
```powershell
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,InstanceType,PublicIpAddress]" --output table
```

3. Stop instances when not in use:
```powershell
aws ec2 stop-instances --instance-ids i-07cbb13dd53c32341 i-0f2d9bc85ac433065 i-0b1bee4c97b2bb76e
```

4. Start instances when needed:
```powershell
aws ec2 start-instances --instance-ids i-07cbb13dd53c32341 i-0f2d9bc85ac433065 i-0b1bee4c97b2bb76e
```

### Instances Keep Stopping

**Symptom:** Instances stop unexpectedly

**Solutions:**
1. Check instance state:
```powershell
aws ec2 describe-instances --instance-ids i-07cbb13dd53c32341 --query "Reservations[*].Instances[*].[State.Name]"
```

2. Check CloudWatch for termination events
3. Verify no auto-scaling policies or scheduled actions

---

## 🔒 Security Issues

### Security Group Rules

**Symptom:** Can't access services but instances are running

**Solutions:**
1. Verify security group rules:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform show | grep security_group
```

2. Check your current IP:
```powershell
curl ifconfig.me
```

3. If IP changed, update terraform.tfvars and apply:
```powershell
terraform apply
```

### Jenkins Security Warnings

**Symptom:** Jenkins shows security warnings

**Solutions:**
1. Update Jenkins plugins: Manage Jenkins → Plugins → Updates
2. Configure Jenkins security: Manage Jenkins → Security
3. Enable CSRF protection (should be default)
4. Use role-based access control if multiple users

---

## 📞 Getting More Help

### Check Jenkins Logs
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
sudo journalctl -u jenkins -f
```

### Check Docker Logs
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
docker logs sonarqube
docker logs cicd-app
```

### Check Application Server Logs
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204
docker logs cicd-app
```

### Check AWS CloudWatch
1. Go to AWS Console → CloudWatch → Logs
2. Look for log groups:
   - `/jenkins-cicd/jenkins`
   - `/jenkins-cicd/staging`
   - `/jenkins-cicd/production`

### Terraform State
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform show
terraform state list
```

---

## 🆘 Nuclear Option: Complete Reset

If everything is broken and you want to start fresh:

### 1. Destroy Infrastructure
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform destroy
```

### 2. Wait for Deletion (5 minutes)

### 3. Redeploy
```powershell
terraform apply
```

### 4. Follow Setup Steps Again
Start from Step 1 in SETUP_STATUS.md

---

## ✅ Quick Health Check Script

Run this to verify everything is working:

```powershell
# Check Jenkins
Write-Host "Checking Jenkins..." -ForegroundColor Yellow
curl http://54.174.211.72:8080 -UseBasicParsing -TimeoutSec 5

# Check SonarQube
Write-Host "Checking SonarQube..." -ForegroundColor Yellow
curl http://54.174.211.72:9000 -UseBasicParsing -TimeoutSec 5

# Check Staging
Write-Host "Checking Staging..." -ForegroundColor Yellow
curl http://3.213.252.204:3000 -UseBasicParsing -TimeoutSec 5

# Check Production
Write-Host "Checking Production..." -ForegroundColor Yellow
curl http://34.194.214.144:3000 -UseBasicParsing -TimeoutSec 5

Write-Host "Health check complete!" -ForegroundColor Green
```

Save this as `health-check.ps1` and run: `.\health-check.ps1`

---

**Still having issues?** Check the Jenkins console output for detailed error messages!
