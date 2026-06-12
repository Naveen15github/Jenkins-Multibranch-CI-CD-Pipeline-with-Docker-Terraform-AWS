# ✅ Quick Start Checklist

Copy this checklist and mark off each step as you complete it!

---

## 🚀 STEP 1: Access Jenkins (2 minutes)

- [ ] Open http://54.174.211.72:8080 in browser
- [ ] Paste password: `5ff6fbd59bee4a04b74d2fb5b5d21eb2`
- [ ] Click "Install suggested plugins" (wait 5-7 minutes)
- [ ] Create admin user (username: admin, set your password)
- [ ] Click "Save and Finish" → "Start using Jenkins"

---

## 🔌 STEP 2: Install Additional Plugins (3 minutes)

- [ ] Go to: Manage Jenkins → Plugins → Available plugins
- [ ] Search and install: **Docker Pipeline**
- [ ] Search and install: **SonarQube Scanner**
- [ ] Search and install: **SSH Agent**
- [ ] Select "Restart Jenkins when installation is complete"
- [ ] Wait for restart (2-3 minutes)

---

## 🔑 STEP 3: Add Jenkins Credentials (5 minutes)

Navigate to: **Manage Jenkins → Credentials**

Then:
- Look for **"Stores scoped to Jenkins"** section
- Click on the **(global)** domain link
- OR click **"System"** → **"Global credentials (unrestricted)"** if available
- You should now see an "Add Credentials" button

### A) Docker Hub Credentials
- [ ] Click **"Add Credentials"** (or "+ Add Credentials" button)
- [ ] Kind: "Username with password"
- [ ] Username: `naveen152005`
- [ ] Password: `naveen@123`
- [ ] ID: `DOCKER_HUB_CREDENTIALS`
- [ ] Description: Docker Hub Login
- [ ] Click "Create"

### B) SSH Key
- [ ] Click **"Add Credentials"**
- [ ] Kind: "SSH Username with private key"
- [ ] ID: `SSH_KEY`
- [ ] Description: EC2 SSH Key
- [ ] Username: `ec2-user`
- [ ] Private Key: Click "Enter directly"
- [ ] **On your local computer**, open PowerShell and run:
  ```powershell
  Get-Content C:\Users\Naveen\.ssh\jenkins-cicd-key
  ```
- [ ] Copy the **entire output** (including BEGIN/END lines)
- [ ] Paste it into the "Key" text box in Jenkins
- [ ] Click "Create"

### C) Slack Webhook (For Slack Notifications)

#### Get Slack Webhook URL:

**If you see "wait a few minutes" error:**
- [ ] Wait 5-10 minutes before creating a new app (Slack rate limit)
- [ ] OR use an existing app if you have one (skip to "Incoming Webhooks" below)

**Create New Slack App:**
- [ ] Go to https://api.slack.com/apps
- [ ] Click **"Create New App"** → **"From scratch"**
- [ ] App Name: `Jenkins CI/CD Bot` (or any name you prefer)
- [ ] Pick your Slack workspace from the dropdown
- [ ] Click **"Create App"**

**Configure Incoming Webhooks:**
- [ ] In the left sidebar, click **"Incoming Webhooks"**
- [ ] Toggle **"Activate Incoming Webhooks"** to ON (switch should turn green)
- [ ] Scroll down to bottom, click **"Add New Webhook to Workspace"**
- [ ] Select the channel for notifications:
  - Recommended: `#jenkins` or `#deployments` (create a dedicated channel)
  - Or use: `#general` or any existing channel
- [ ] Click **"Allow"**
- [ ] **Copy the Webhook URL** 
  - Format: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX`
  - Click the **"Copy"** button next to the webhook URL

#### Add Webhook to Jenkins:
- [ ] Back in Jenkins: Manage Jenkins → Credentials → System → Global credentials
- [ ] Click **"Add Credentials"**
- [ ] Kind: **"Secret text"**
- [ ] Secret: (paste your Slack webhook URL)
- [ ] ID: `SLACK_WEBHOOK`
- [ ] Description: Slack Notifications
- [ ] Click **"Create"**

#### Test Slack Integration (Optional):
- [ ] After pipeline is created, trigger a build
- [ ] Check your Slack channel for build notifications

---

## 🔍 STEP 4: Configure SonarQube (5 minutes)

- [ ] Wait 2-3 minutes for SonarQube to start
- [ ] Open http://54.174.211.72:9000
- [ ] Login: `admin` / `admin`
- [ ] Change password when prompted
- [ ] Click "Create Project" → "Manually"
- [ ] Project key: `jenkins-cicd-pipeline`
- [ ] Display name: `Jenkins CI/CD Pipeline`
- [ ] Click "Set Up"
- [ ] Choose "With Jenkins"
- [ ] Generate Token (name: `jenkins`)
- [ ] **🔑 COPY THE TOKEN** (you'll need it next!)
- [ ] Keep browser tab open

---

## 🎫 STEP 5: Add SonarQube Token to Jenkins (1 minute)

- [ ] Back in Jenkins: Manage Jenkins → Credentials → System → Global credentials
- [ ] Click "Add Credentials"
- [ ] Kind: "Secret text"
- [ ] Secret: (paste the SonarQube token from Step 4)
- [ ] ID: `SONAR_TOKEN`
- [ ] Description: SonarQube Authentication
- [ ] Click "Create"

---

## 🪝 STEP 6: Add SonarQube Webhook (2 minutes)

- [ ] Back in SonarQube: Administration → Configuration → Webhooks
- [ ] Click "Create"
- [ ] Name: `Jenkins`
- [ ] URL: `http://10.0.1.56:8080/sonarqube-webhook/`
- [ ] Secret: (leave empty)
- [ ] Click "Create"

**Note:** Use Jenkins private IP (10.0.1.56) instead of localhost.

---

## ⚙️ STEP 7: Configure SonarQube in Jenkins (2 minutes)

- [ ] In Jenkins: Manage Jenkins → System
- [ ] Scroll to "SonarQube servers"
- [ ] Check: "Enable injection of SonarQube server configuration"
- [ ] Click "Add SonarQube"
- [ ] Name: `SonarQube`
- [ ] Server URL: `http://localhost:9000`
- [ ] Server authentication token: Select `SONAR_TOKEN`
- [ ] Scroll to bottom, click "Save"

---

## 📝 STEP 8: Commit Jenkinsfile (2 minutes)

Run in PowerShell:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline
git add Jenkinsfile
git commit -m "Configure Jenkinsfile with AWS server IPs and Docker Hub username"
git push origin main
```

If you don't have a Git repository yet:
- [ ] Create repository on GitHub/GitLab/Bitbucket
- [ ] Initialize and push:
```powershell
git init
git add .
git commit -m "Initial commit with Jenkins CI/CD pipeline"
git remote add origin https://github.com/yourusername/jenkins-cicd-pipeline.git
git branch -M main
git push -u origin main
```

---

## 🛠️ STEP 9: Create Jenkins Pipeline (3 minutes)

- [ ] In Jenkins, click "New Item"
- [ ] Name: `jenkins-cicd-pipeline`
- [ ] Select: "Multibranch Pipeline"
- [ ] Click "OK"
- [ ] Under "Branch Sources", click "Add source" → "Git"
- [ ] Project Repository: (your Git repo URL)
- [ ] If private repo, add credentials (GitHub token)
- [ ] Click "Save"
- [ ] Jenkins will scan for branches automatically

---

## 🧪 STEP 10: Test Pipeline (10 minutes)

### Test Dev Branch:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline
git checkout -b dev
echo "// trigger dev pipeline" >> src\app.js
git add .
git commit -m "test: trigger dev pipeline"
git push origin dev
```
- [ ] Check Jenkins - "dev" branch should be building

### Test Staging Branch:
```powershell
git checkout -b staging
git merge dev
git push origin staging
```
- [ ] Check Jenkins - "staging" should build, scan, and deploy

### Test Production:
```powershell
git checkout main
git merge staging
git push origin main
```
- [ ] Check Jenkins - should pause for approval
- [ ] Click "Proceed" to deploy to production

---

## ✅ STEP 11: Verify Deployments (2 minutes)

### Test Staging:
```powershell
curl http://3.213.252.204:3000
curl http://3.213.252.204:3000/health
```
- [ ] Should return: `{"message":"Hello from CI/CD Pipeline"}`

### Test Production:
```powershell
curl http://34.194.214.144:3000
curl http://34.194.214.144:3000/health
```
- [ ] Should return: `{"message":"Hello from CI/CD Pipeline"}`

---

## 🎉 DONE!

- [ ] Jenkins pipeline is operational
- [ ] SonarQube is analyzing code
- [ ] Staging auto-deploys on push to staging branch
- [ ] Production requires manual approval
- [ ] Health checks and rollback are working

---

## 📊 Quick Reference

| Service | URL | Credentials |
|---------|-----|-------------|
| Jenkins | http://54.174.211.72:8080 | admin / (your password) |
| SonarQube | http://54.174.211.72:9000 | admin / (your password) |
| Staging | http://3.213.252.204:3000 | - |
| Production | http://34.194.214.144:3000 | - |

**SSH Key Location:** `C:\Users\Naveen\.ssh\jenkins-cicd-key`

**Docker Hub:** naveen152005 / naveen@123

**Monthly Cost:** ~$77

---

## 🗑️ Teardown

When done:
```powershell
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform destroy
```

---

**Need detailed help?** See `SETUP_STATUS.md` for complete step-by-step instructions!
