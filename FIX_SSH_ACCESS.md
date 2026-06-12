# 🔧 Fix SSH Access for Deployment

## Problem:
Jenkins cannot SSH into Staging/Production servers due to security group restrictions.

**Error:** `ssh: connect to host 3.213.252.204 port 22: Connection timed out`

---

## ✅ Quick Fix (AWS Console):

### Step 1: Update Staging Server Security Group

1. Go to **AWS Console** → **EC2** → **Security Groups**
2. Find: `jenkins-cicd-pipeline-staging-sg-xxxxx`
3. **Click "Edit inbound rules"**
4. **Add a new rule:**
   - Type: **SSH**
   - Protocol: **TCP**
   - Port: **22**
   - Source: **10.0.1.56/32** (Jenkins server private IP)
   - Description: **SSH from Jenkins**
5. **Click "Save rules"**

### Step 2: Update Production Server Security Group

1. Find: `jenkins-cicd-pipeline-production-sg-xxxxx`
2. **Click "Edit inbound rules"**
3. **Add a new rule:**
   - Type: **SSH**
   - Protocol: **TCP**
   - Port: **22**
   - Source: **10.0.1.56/32** (Jenkins server private IP)
   - Description: **SSH from Jenkins**
4. **Click "Save rules"**

---

## ✅ Alternative: Terraform Fix

If you want to fix via Terraform:

```bash
cd C:\Users\Naveen\Downloads\jenkins-cicd-pipeline\jenkins-cicd-pipeline\terraform
terraform apply -auto-approve
```

This will update the security groups automatically.

---

## 🧪 Test After Fix:

### From Jenkins Server:
```bash
# SSH into Jenkins server
ssh -i C:\Users\Naveen\.ssh\jenkins-cicd-key ec2-user@54.174.211.72

# Test SSH to Staging
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@10.0.1.75

# Test SSH to Production
ssh -i ~/.ssh/jenkins-cicd-key ec2-user@10.0.1.231
```

If the SSH test works, Jenkins deployments will work!

---

## 📋 Server IPs:

| Server | Public IP | Private IP | Purpose |
|--------|-----------|------------|---------|
| Jenkins | 54.174.211.72 | 10.0.1.56 | CI/CD Server |
| Staging | 3.213.252.204 | 10.0.1.75 | Staging App |
| Production | 34.194.214.144 | 10.0.1.231 | Production App |

---

## 🎯 Next Step:

After fixing the security groups:

1. **Go to Jenkins** → **jenkins-cicd-pipeline** → **staging** 
2. Click **"Build Now"** to retry the deployment
3. Build should now complete successfully!
