# 🚀 Jenkins CI/CD Pipeline - Setup Status

**Last Updated:** June 12, 2026  
**Status:** ✅ Infrastructure Ready | ⏳ Jenkins Configuration Pending

---

## ✅ COMPLETED STEPS

### 1. Infrastructure Deployment
- ✅ VPC created: `vpc-0222692ccbbb99dff`
- ✅ Subnet created: `subnet-0028b8fc373a8a94b` (10.0.1.0/24)
- ✅ Security Groups configured (Jenkins, Staging, Production)
- ✅ SSH Key generated: `C:\Users\Naveen\.ssh\jenkins-cicd-key`
- ✅ IAM roles and policies created
- ✅ CloudWatch log groups configured

### 2. EC2 Instances Deployed
| Server | Instance ID | Public IP | Private IP | Type |
|--------|-------------|-----------|------------|------|
| **Jenkins** | i-07cbb13dd53c32341 | 54.174.211.72 | 10.0.1.56 | t3.medium |
| **Staging** | i-0f2d9bc85ac433065 | 3.213.252.204 | 10.0.1.75 | t3.micro |
| **Production** | i-0b1bee4c97b2bb76e | 34.194.214.144 | 10.0.1.231 | t3.small |

### 3. Services Running
- ✅ Jenkins running at: http://54.174.211.72:8080
- ✅ SonarQube running at: http://54.174.211.72:9000
- ✅ Java 21 installed on Jenkins server
- ✅ Docker installed on all servers

### 4. Jenkinsfile Updated
- ✅ Docker Hub username: `naveen152005`
- ✅ Staging IP: `3.213.252.204`
- ✅ Production IP: `34.194.214.144`

---

## ⏳ REMAINING CONFIGURATION (30-40 minutes)

Follow these steps in order to complete your CI/CD pipeline setup:

### 📋 STEP 1: Access Jenkins (2 minutes)

1. Open browser: **http://54.174.211.72:8080**

2. Use this password to unlock Jenkins:
   ```
   5ff6fbd59bee4a04b74d2fb5b5d21eb2
   ```

3. Click **"Install suggested plugins"**
   - Wait 5-7 minutes for plugin installation

4. Create admin user:
   - Username: `admin`
   - Password: *(choose a strong password)*
   - Full name: `Admin`
   - Email: `your-email@example.com`

5. Keep Jenkins URL as default, click **"Save and Finish"**

---

### 🔌 STEP 2: Install Additional Plugins (3 minutes)

In Jenkins:
1. Go to **Manage Jenkins** → **Plugins** → **Available plugins**

2. Search and install these 3 plugins:
   - ☐ **Docker Pipeline**
   - ☐ **SonarQube Scanner**
   - ☐ **SSH Agent**

3. Select **"Restart Jenkins when installation is complete"**

4. Wait 2-3 minutes for restart

---

### 🔑 STEP 3: Add Jenkins Credentials (5 minutes)

Navigate to: **Manage Jenkins** → **Credentials** → **System** → **Global credentials**

#### A) Docker Hub Credentials
Click **"Add Credentials"**:
- **Kind:** Username with password
- **Username:** `naveen152005`
- **Password:** `naveen@123`
- **ID:** `DOCKER_HUB_CREDENTIALS`
- **Description:** Docker Hub Login
- Click **Create**

#### B) SSH Key for Deployments
Click **"Add Credentials"**:
- **Kind:** SSH Username with private key
- **ID:** `SSH_KEY`
- **Description:** EC2 SSH Key
- **Username:** `ec2-user`
- **Private Key:** Click "Enter directly"

**Get your private key** by running in PowerShell:
```powershell
Get-Content C:\Users\Naveen\.ssh\jenkins-cicd-key
```

Copy the **ENTIRE output** including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...all the lines...
-----END OPENSSH PRIVATE KEY-----
```

Paste in the **"Key"** field and click **Create**

#### C) Slack Webhook (OPTIONAL)
*Skip this if you don't use Slack*

Click **"Add Credentials"**:
- **Kind:** Secret text
- **Secret:** Your Slack webhook URL
- **ID:** `SLACK_WEBHOOK`
- **Description:** Slack Notifications

---

### 🔍 STEP 4: Configure SonarQube (5 minutes)

1. Wait 2-3 minutes for SonarQube to fully start

2. Open: **http://54.174.211.72:9000**

3. Login: `admin` / `admin`

4. Change password when prompted

5. Click **"Create Project"** → **"Manually"**
   - **Project key:** `jenkins-cicd-pipeline`
   - **Display name:** `Jenkins CI/CD Pipeline`
   - Click **"Set Up"**

6. Choose **"With Jenkins"**

7. **Generate Token:**
   - Token name: `jenkins`
   - Click **"Generate"**
   - **🔑 COPY THIS TOKEN** (example: `squ_a1b2c3d4e5f6g7h8i9j0`)
   - You'll need it in the next step!

8. Keep this tab open

---

### 🎫 STEP 5: Add SonarQube Token to Jenkins (1 minute)

1. Back in Jenkins: **Manage Jenkins** → **Credentials** → **System** → **Global credentials**

2. Click **"Add Credentials"**:
   - **Kind:** Secret text
   - **Secret:** *(paste the SonarQube token from Step 4)*
   - **ID:** `SONAR_TOKEN`
   - **Description:** SonarQube Authentication
   - Click **Create**

---

### 🪝 STEP 6: Add SonarQube Webhook (2 minutes)

Back in SonarQube:

1. Click **"Administration"** (top menu) → **"Configuration"** → **"Webhooks"**

2. Click **"Create"**:
   - **Name:** `Jenkins`
   - **URL:** `http://localhost:8080/sonarqube-webhook/`
   - **Secret:** *(leave empty)*
   - Click **Create**

---

### ⚙️ STEP 7: Configure SonarQube in Jenkins (2 minutes)

In Jenkins:

1. **Manage Jenkins** → **System**

2. Scroll to **"SonarQube servers"**

3. Check: ☑ **"Enable injection of SonarQube server configuration"**

4. Click **"Add SonarQube"**:
   - **Name:** `SonarQube`
   - **Server URL:** `http://localhost:9000`
   - **Server authentication token:** Select `SONAR_TOKEN`

5. Scroll to bottom, click **"Save"**

---

### 📝 STEP 8: Commit Updated Jenkinsfile (2 minutes)

On your local computer in PowerShell:

```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline
git status
git add Jenkinsfile
git commit -m "Configure Jenkinsfile with AWS server IPs and Docker Hub username"
git push origin main
```

If you don't have a Git repository yet:
```powershell
# Initialize Git if not done already
git init
git add .
git commit -m "Initial commit with Jenkins CI/CD pipeline"

# Add your remote repository
git remote add origin https://github.com/yourusername/jenkins-cicd-pipeline.git
git branch -M main
git push -u origin main
```

---

### 🛠️ STEP 9: Create Jenkins Pipeline (3 minutes)

In Jenkins:

1. Click **"New Item"** (left sidebar)

2. Enter name: `jenkins-cicd-pipeline`

3. Select: **"Multibranch Pipeline"**

4. Click **"OK"**

5. Under **"Branch Sources"**:
   - Click **"Add source"** → **"Git"**

6. **Project Repository:** *(enter your Git repository URL)*
   - Example: `https://github.com/yourusername/jenkins-cicd-pipeline.git`

7. If private repo, click **"Add"** → **Jenkins**:
   - **Kind:** Username with password
   - **Username:** your-github-username
   - **Password:** your-github-token or password
   - Click **"Add"**, then select from dropdown

8. Scroll down, click **"Save"**

9. Jenkins will **automatically scan for branches**!

---

### 🧪 STEP 10: Test Your Pipeline (10 minutes)

#### Test Dev Branch (Build + Test only):
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline
git checkout -b dev
echo "// trigger dev pipeline" >> src\app.js
git add .
git commit -m "test: trigger dev pipeline"
git push origin dev
```

Check Jenkins - you should see **"dev"** branch building!

#### Test Staging Branch (Build + Deploy to Staging):
```powershell
git checkout -b staging
git merge dev
git push origin staging
```

Check Jenkins - **"staging"** branch will:
- Run tests
- Run SonarQube scan
- Build Docker image
- Push to Docker Hub
- Deploy to Staging server (3.213.252.204)

#### Test Production (Requires Manual Approval):
```powershell
git checkout main
git merge staging
git push origin main
```

Check Jenkins:
- Build will **pause for manual approval**
- Click on the build → **"Paused for Input"**
- Click **"Proceed"** to deploy to production

---

### ✅ STEP 11: Verify Deployments (2 minutes)

#### Test Staging Server:
```powershell
curl http://3.213.252.204:3000
curl http://3.213.252.204:3000/health
```

#### Test Production Server:
```powershell
curl http://34.194.214.144:3000
curl http://34.194.214.144:3000/health
```

**Expected Response:**
```json
{"message":"Hello from CI/CD Pipeline"}
```

---

## 📊 QUICK REFERENCE

### Access URLs
| Service | URL | Credentials |
|---------|-----|-------------|
| **Jenkins** | http://54.174.211.72:8080 | Password: `5ff6fbd59bee4a04b74d2fb5b5d21eb2` |
| **SonarQube** | http://54.174.211.72:9000 | admin / *(your password)* |
| **Staging App** | http://3.213.252.204:3000 | - |
| **Production App** | http://34.194.214.144:3000 | - |

### SSH Commands
```powershell
# Jenkins Server
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72

# Staging Server
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@3.213.252.204

# Production Server
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@34.194.214.144
```

### Docker Hub
- **Username:** naveen152005
- **Password:** naveen@123
- **Repository:** naveen152005/myapp

### AWS Details
- **Account:** 478468758108
- **Region:** us-east-1
- **User:** Naveen
- **VPC:** vpc-0222692ccbbb99dff

---

## 🎯 PIPELINE WORKFLOW

### Dev Branch
1. ✅ Checkout code
2. ✅ Install dependencies
3. ✅ Run tests
4. ❌ No deployment

### Staging Branch
1. ✅ Checkout code
2. ✅ Install dependencies
3. ✅ Run tests
4. ✅ SonarQube scan
5. ✅ Quality gate check
6. ✅ Build Docker image
7. ✅ Push to Docker Hub
8. ✅ Deploy to Staging (3.213.252.204)
9. ✅ Health check

### Main Branch (Production)
1. ✅ Checkout code
2. ✅ Install dependencies
3. ✅ Run tests
4. ✅ SonarQube scan
5. ✅ Quality gate check
6. ✅ Build Docker image
7. ✅ Push to Docker Hub
8. ⏸️ **Manual approval required**
9. ✅ Deploy to Production (34.194.214.144)
10. ✅ Health check
11. 🔄 Auto-rollback on failure

---

## 💰 COST BREAKDOWN

| Resource | Type | Monthly Cost |
|----------|------|--------------|
| Jenkins Server | t3.medium | ~$30 |
| Staging Server | t3.micro | ~$7 |
| Production Server | t3.small | ~$15 |
| Data Transfer | ~50 GB | ~$5 |
| Elastic IPs | 3 × $3.60 | ~$11 |
| CloudWatch Logs | 5 GB | ~$3 |
| EBS Volumes | 3 × 30 GB | ~$6 |
| **TOTAL** | | **~$77/month** |

---

## 🗑️ TEARDOWN INSTRUCTIONS

When you're done with the infrastructure:

```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform destroy
```

This will delete all AWS resources and stop billing.

---

## 🎉 CONGRATULATIONS!

Once you complete the steps above, you'll have:

✅ **Automated CI/CD Pipeline** with Jenkins  
✅ **Code Quality Analysis** with SonarQube  
✅ **Automated Testing** with Jest  
✅ **Docker Container Build & Push**  
✅ **Automated Staging Deployments**  
✅ **Manual Production Approvals**  
✅ **Automated Health Checks**  
✅ **Automatic Rollback on Failure**  
✅ **CloudWatch Monitoring**  
✅ **Slack Notifications** (optional)

---

## 📞 TROUBLESHOOTING

### Jenkins Won't Start
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
sudo systemctl status jenkins
sudo systemctl restart jenkins
sudo journalctl -u jenkins -n 50
```

### SonarQube Won't Start
```powershell
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72
docker ps -a
docker logs sonarqube
docker restart sonarqube
```

### Can't Connect to Servers
Check security groups allow your IP (122.164.251.126)

### Pipeline Fails
- Check Jenkins credentials (DOCKER_HUB_CREDENTIALS, SSH_KEY, SONAR_TOKEN)
- Verify SonarQube is running
- Check Docker Hub credentials are correct
- Ensure SSH key has correct permissions

---

**Ready to start?** Begin with **STEP 1** above! 🚀
