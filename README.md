# Jenkins Multi-Branch CI/CD Pipeline

A production-ready CI/CD pipeline using Jenkins, Docker, SonarQube, and Slack for a Node.js Express API.

---

## Pipeline Overview

| Branch    | Tests | SonarQube | Docker Build | Deploy       | Approval | Rollback | Slack |
|-----------|-------|-----------|--------------|--------------|----------|----------|-------|
| dev       | YES   | NO        | NO           | NO           | NO       | NO       | YES   |
| staging   | YES   | YES       | YES          | Staging EC2  | NO       | NO       | YES   |
| main      | YES   | YES       | YES          | Prod EC2     | YES      | YES      | YES   |

---

## Prerequisites

Install on your local machine:
- Git
- Node.js 18+
- Docker and Docker Compose
- AWS CLI (optional, for EC2 management)

---

## AWS EC2 Setup

You need 3 EC2 instances (Amazon Linux 2 or Ubuntu 22.04):

| Server    | Purpose           | Suggested Type |
|-----------|-------------------|----------------|
| Jenkins   | CI/CD server      | t3.medium      |
| Staging   | Staging deploy    | t3.micro       |
| Prod      | Production deploy | t3.small       |

### Security Group Rules (all 3 servers)
- SSH: port 22 (your IP only)
- App: port 3000 (open)
- Jenkins UI: port 8080 (your IP only, Jenkins server only)
- SonarQube: port 9000 (your IP only, Jenkins server only)

---

## Jenkins Installation (on Jenkins EC2)

```bash
# Amazon Linux 2
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Get initial admin password
sudo cat /var/jenkins_home/secrets/initialAdminPassword
```

Install Docker on the Jenkins server:
```bash
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

## SonarQube Installation (on Jenkins EC2 via Docker)

```bash
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:10-community
```

Access at: http://<jenkins-ec2-ip>:9000
Default login: admin / admin — change on first login.

Create a project:
1. Projects > Create Project > Manually
2. Project key: jenkins-cicd-pipeline
3. Generate a token and copy it for Jenkins credentials

---

## Jenkins Plugin Installation

Go to Manage Jenkins > Plugin Manager > Available and install:

- Git
- Pipeline
- Multibranch Pipeline
- Docker Pipeline
- SonarQube Scanner
- SSH Agent
- Credentials Binding
- HTML Publisher
- JUnit
- Blue Ocean (optional, for improved UI)

---

## Jenkins Credentials Setup

Go to Manage Jenkins > Credentials > System > Global credentials > Add Credential

| ID                       | Type              | Value                                  |
|--------------------------|-------------------|----------------------------------------|
| DOCKER_HUB_CREDENTIALS   | Username/Password | DockerHub username + password or token |
| SSH_KEY                  | SSH Username+Key  | ec2-user + contents of your .pem file  |
| SLACK_WEBHOOK            | Secret Text       | Full Slack webhook URL                 |
| SONAR_TOKEN              | Secret Text       | SonarQube generated token              |

---

## SonarQube Server Config in Jenkins

Go to Manage Jenkins > Configure System > SonarQube servers:
- Name: SonarQube
- Server URL: http://localhost:9000
- Server authentication token: select SONAR_TOKEN

---

## Create Multi-Branch Pipeline Job

1. Jenkins > New Item
2. Name: jenkins-cicd-pipeline
3. Type: Multibranch Pipeline
4. Branch Sources: Git
   - Repository URL: your GitHub repo URL
   - Credentials: add GitHub credentials if the repo is private
5. Build Configuration: by Jenkinsfile
6. Save — Jenkins will scan and discover branches automatically

---

## Create the 3 Branches

```bash
git clone https://github.com/yourusername/jenkins-cicd-pipeline.git
cd jenkins-cicd-pipeline

# dev branch
git checkout -b dev
git push origin dev

# staging branch
git checkout -b staging
git push origin staging

# main branch already exists by default
```

---

## Update Jenkinsfile Variables

Before the first run, update these three values in Jenkinsfile:

```
DOCKER_IMAGE      = "yourdockerhubusername/myapp"
STAGING_SERVER_IP = "YOUR_STAGING_EC2_IP"
PROD_SERVER_IP    = "YOUR_PROD_EC2_IP"
```

---

## Install Docker on Staging and Prod EC2

```bash
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
```

---

## Test the Pipeline End to End

```bash
# Trigger dev pipeline
git checkout dev
echo "// trigger" >> src/app.js
git add . && git commit -m "test: trigger dev pipeline"
git push origin dev

# Trigger staging pipeline
git checkout staging
git merge dev
git push origin staging

# Trigger main pipeline (requires manual approval in Jenkins UI)
git checkout main
git merge staging
git push origin main
```

---

## Verify Slack Notifications

1. Go to https://api.slack.com/apps
2. Create App > Incoming Webhooks > enable > Add to Workspace
3. Copy webhook URL into Jenkins SLACK_WEBHOOK credential
4. Trigger any build and check your Slack channel for messages

---

## Verify SonarQube Report

1. After staging or main build runs, go to http://<jenkins-ip>:9000
2. Projects > jenkins-cicd-pipeline
3. Check coverage percentage, bugs, code smells, and quality gate status

---

## Test Rollback

1. Push a bad commit to main that makes the health check fail
2. Jenkins automatically runs scripts/rollback.sh
3. It pulls the previous build Docker image and restarts the container
4. Slack notifies about the failure

To inspect manually:
```bash
ssh -i your-key.pem ec2-user@PROD_EC2_IP
docker ps                  # see running container
docker images              # see available image tags
```

---

## Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| docker: command not found on Jenkins | Docker not in PATH for jenkins user | sudo usermod -aG docker jenkins && sudo systemctl restart jenkins |
| Host key verification failed | SSH strict host checking | -o StrictHostKeyChecking=no is already in all scripts |
| Quality Gate timeout | SonarQube webhook not configured | In SonarQube: Admin > Webhooks > Add http://<jenkins-ip>:8080/sonarqube-webhook/ |
| Cannot connect to SonarQube | Wrong SONAR_HOST_URL | Update to actual Jenkins server IP in Jenkinsfile |
| Docker push unauthorized | Bad DockerHub credentials | Re-create DOCKER_HUB_CREDENTIALS with a DockerHub access token |
| npm ci fails | package-lock.json missing | Run npm install locally and commit package-lock.json |
| Slack notification not sent | Wrong webhook URL | Test: curl -X POST -d '{"text":"test"}' YOUR_WEBHOOK_URL |
| Input approval timeout | No approval within 30 min | Increase timeout value in Jenkinsfile |
