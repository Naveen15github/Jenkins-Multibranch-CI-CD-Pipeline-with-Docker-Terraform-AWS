![Enterprise Jenkins Multibranch CI/CD Pipeline Architecture](architecture%20diagram.png)

---

# 🚀 Jenkins Multibranch CI/CD Pipeline with Docker, Terraform & AWS

[![Jenkins](https://img.shields.io/badge/Jenkins-Multibranch-red?logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)](https://www.terraform.io/)
[![Node.js](https://img.shields.io/badge/Node.js-16.20.2-green?logo=node.js)](https://nodejs.org/)
[![SonarQube](https://img.shields.io/badge/SonarQube-Quality_Gate-green?logo=sonarqube)](https://www.sonarqube.org/)
[![Coverage](https://img.shields.io/badge/Coverage-97%25-brightgreen)](https://jestjs.io/)
[![Tests](https://img.shields.io/badge/Tests-12_Passing-success)](https://jestjs.io/)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

> **Enterprise-grade automated CI/CD pipeline** featuring Jenkins multibranch strategy, Docker containerization, AWS EC2 infrastructure provisioned with Terraform, SonarQube quality gates, Jest test coverage, and real-time Slack notifications for multi-environment Node.js deployment — fully built and implemented by me.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [Pipeline Flow](#-pipeline-flow)
- [Environment Strategy](#-environment-strategy)
- [Screenshots](#-screenshots)
- [Project Structure](#-project-structure)
- [Setup & Installation](#-setup--installation)
- [Jenkins Configuration](#-jenkins-configuration)
- [Terraform Infrastructure](#-terraform-infrastructure)
- [SonarQube Integration](#-sonarqube-integration)
- [Slack Notifications](#-slack-notifications)
- [Testing](#-testing)
- [API Endpoints](#-api-endpoints)
- [Stats & Metrics](#-stats--metrics)

---

## 🧭 Overview

I built this project to demonstrate a complete, production-grade DevOps pipeline from scratch. The system automatically tests, builds, containerizes, and deploys a Node.js/Express application across three environments (development, staging, production) using a Jenkins Multibranch Pipeline strategy. Every commit to a branch triggers the full pipeline — including unit tests, SonarQube static analysis, Docker image build and push to Docker Hub, and automated deployment to AWS EC2 — with Slack notifications at every stage.

**Key Highlights:**
- **3 branches** → 3 environments (dev, staging, main/production)
- **Fully automated** from code commit to live deployment in ~5 minutes
- **Infrastructure as Code** — all AWS resources provisioned with Terraform
- **Quality gates** enforced via SonarQube before any deployment proceeds
- **Slack integration** with interactive approval buttons for production deployments
- **12 Jest unit tests** with 97% code coverage

---

## 🏗 Architecture

```
Developer
    │
    ▼ git push
GitHub Repository
    │
    ▼ webhook trigger
Jenkins Multibranch Pipeline
    │
    ├─► dev branch     → Unit Tests only
    ├─► staging branch → Full pipeline + Auto Deploy → Staging EC2
    └─► main branch    → Full pipeline + Manual Approval → Production EC2
           │
           ├── Stage 1: Checkout
           ├── Stage 2: Install Dependencies (npm ci)
           ├── Stage 3: Run Tests (Jest, 97% coverage)
           ├── Stage 4: SonarQube Analysis + Quality Gate
           ├── Stage 5: Docker Build & Push to Docker Hub
           ├── Stage 6: Deploy to EC2 (SSH + Docker)
           └── Stage 7: Slack Notification
```

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| **CI/CD** | Jenkins Multibranch Pipeline |
| **Containers** | Docker, Docker Hub |
| **Cloud** | AWS EC2, VPC, Security Groups |
| **IaC** | Terraform |
| **Code Quality** | SonarQube Community Edition v10.7 |
| **Testing** | Jest, Supertest |
| **Linting** | ESLint |
| **Backend** | Node.js 16, Express.js |
| **Notifications** | Slack (Block Kit API) |
| **Version Control** | GitHub |

---

## ✨ Features

### Continuous Integration
Automatic testing and validation fires on every commit to every branch. Jenkins detects new branches automatically via GitHub webhook and creates a dedicated pipeline for each one.

### Docker Containerization
Every successful build produces a versioned Docker image (`naveen152005/myapp:<build_number>`) and pushes it to Docker Hub. Deployments pull from Docker Hub — ensuring consistency across all environments.

### Infrastructure as Code
The complete AWS infrastructure (3 EC2 instances, VPC, security groups, key pairs) is defined in Terraform. I can tear down and rebuild the entire environment with a single `terraform apply`.

### SonarQube Quality Gates
SonarQube performs static analysis on every build. A webhook notifies Jenkins of the gate result. If the quality gate fails, the pipeline halts before deployment — protecting all environments from bad code.

### Multi-Environment Strategy
Three branches map to three environments with different pipeline behaviors, providing a safe promotion path from development through to production.

### Smart Slack Notifications
Real-time Slack messages are sent for every pipeline event — build failures (with "View Console Output" button), staging deployments (with "Open App" button), production approval requests (with "Approve in Jenkins" button), and successful production deployments.

### Interactive Production Approval
Before deploying to production, the pipeline pauses and sends a Slack message with an "Approve in Jenkins" button. Production deploys only after human sign-off.

---

## 🔄 Pipeline Flow

![Pipeline Flow Diagram](Screenshots/Screenshot%20(631).png)
*The 5-stage pipeline flow: Code Commit → Automated Tests → Quality Check → Docker Build → Deploy*

The pipeline moves every commit through these stages automatically:

1. **Code Commit** — Developer pushes to GitHub; the webhook fires immediately.
2. **Automated Tests** — Jest runs all 12 unit tests with coverage reporting.
3. **Quality Check** — SonarQube analyses the code and enforces the quality gate.
4. **Docker Build** — A versioned image is built and pushed to Docker Hub.
5. **Deploy** — The target environment pulls the image and restarts the container.

---

## 🌍 Environment Strategy

![Environment Status Dashboard](Screenshots/Screenshot%20(635).png)
*Real-time environment status showing all three environments active — dev, staging, production*

| Environment | Branch | Pipeline | Deploy Trigger |
|---|---|---|---|
| **Development** | `dev` | Tests only | Auto on commit |
| **Staging** | `staging` | Full + Auto Deploy | Auto on commit |
| **Production** | `main` | Full + Manual Approval | Human approval via Slack |

---

## 📸 Screenshots

### Jenkins Multibranch Pipeline — All 3 Branches Passing

![Jenkins Multibranch Branches](Screenshots/Screenshot%20(642).png)
*Jenkins multibranch pipeline showing all three branches (dev, staging, main) with successful builds — dev #26, main #16, staging #17*

---

### Enterprise Features — Application Dashboard

![Enterprise Features Section](Screenshots/Screenshot%20(632).png)
*The deployed application's Enterprise Features section — showcasing Continuous Integration, Containerization, and Code Quality modules*

![Cloud and Notification Features](Screenshots/Screenshot%20(633).png)
*Cloud Infrastructure (AWS + Terraform), Smart Notifications (Slack + Webhooks), and Security First (AWS IAM + Secrets) feature cards*

---

### Technology Stack — Application Dashboard

![Technology Stack Section](Screenshots/Screenshot%20(636).png)
*Tech stack section of the live application: CI/CD (Jenkins, GitHub, Docker), Infrastructure (AWS EC2, Terraform, VPC), Code Quality (SonarQube, Jest, ESLint), Backend (Node.js, Express, REST API)*

---

### SonarQube — Webhook Integration

![SonarQube Webhooks](Screenshots/Screenshot%20(627).png)
*SonarQube Administration → Webhooks: Jenkins webhook configured at `http://10.0.1.56:8080/sonarqube-webhook/` to notify Jenkins when analysis completes*

---

### Slack Notifications — Build Failed Alerts

![Slack Build Failed Notifications](Screenshots/Screenshot%20(634).png)
*Slack #all-projects channel receiving Build Failed notifications for all three branches simultaneously (main #12, dev #21, staging #12) — each with a "View Console Output" button for quick debugging*

---

### Slack Notifications — Production Deployment Approval

![Slack Production Approval](Screenshots/Screenshot%20(639).png)
*Slack interactive approval message: "Production Deployment Approval Required" for build #16 on server 34.194.214.144 — with "Approve in Jenkins" and "View Build" buttons*

---

### Slack Notifications — Deployed to Staging

![Slack Staging Deployment](Screenshots/Screenshot%20(637).png)
*Slack notification: "🚀 Deployed to Staging" for build #16 (image `naveen152005/myapp:16`) at http://3.213.252.204:3000 — with "Open App" and "View Build" buttons*

![Slack Staging Build #17](Screenshots/Screenshot%20(640).png)
*Slack notification for staging build #17 — showing image tag `naveen152005/myapp:17` and successful deployment confirmation with "Open App" button*

---

### Slack Notifications — Deployed to Production

![Slack Production Deployment](Screenshots/Screenshot%20(641).png)
*Slack notification: "✅ Deployed to Production" for build #16 (image `naveen152005/myapp:16`) at http://34.194.214.144:3000 — with "Open Production App" button and "🎉 Production deployment successful! The new version is now live."*

---

### Slack Notifications — Dev Branch Build Success + Production Approval Flow

![Slack Dev Build and Production Approval](Screenshots/Screenshot%20(638).png)
*Slack #all-projects channel: dev branch build #26 passed, followed immediately by the Production Deployment Approval Required message — showing the complete approval flow in action*

---

## 📁 Project Structure

```
jenkins-multibranch-docker-terraform-aws-cicd-pipeline/
│
├── Jenkinsfile                     # Multibranch pipeline definition
├── Dockerfile                      # Container build instructions
├── docker-compose.yml              # Local development setup
├── package.json                    # Node.js dependencies & scripts
├── package-lock.json               # Locked dependency tree
├── sonar-project.properties        # SonarQube project configuration
├── .gitignore                      # Git ignore rules
│
├── src/                            # Application source code
│   ├── app.js                      # Express app configuration
│   ├── server.js                   # HTTP server startup
│   ├── routes/                     # API route handlers
│   │   ├── health.js               # /health and /api/info endpoints
│   │   └── index.js                # Route aggregator
│   └── public/                     # Frontend static files
│       ├── index.html              # CI/CD Pipeline Dashboard UI
│       ├── styles.css              # Modern UI styling
│       └── script.js               # Frontend JavaScript
│
├── tests/                          # Jest test suite
│   └── app.test.js                 # 12 unit tests (97% coverage)
│
├── terraform/                      # AWS infrastructure as code
│   ├── main.tf                     # EC2, VPC, Security Group resources
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values (IPs, IDs)
│   ├── terraform.tfvars.example    # Example variable values
│   ├── README.md                   # Terraform usage guide
│   └── user-data/                  # EC2 bootstrap scripts
│       ├── jenkins.sh              # Jenkins server setup
│       ├── sonarqube.sh            # SonarQube server setup
│       └── app.sh                  # App server Docker setup
│
├── scripts/                        # Operational scripts
│   ├── deploy.sh                   # Deployment automation script
│   ├── health-check.sh             # Endpoint health verifier
│   └── rollback.sh                 # Emergency rollback script
│
└── Screenshots/                    # Project documentation screenshots
```

---

## ⚙️ Setup & Installation

### Prerequisites

- AWS account with IAM credentials
- Terraform >= 1.0
- Docker & Docker Hub account
- GitHub account
- Slack workspace with incoming webhook

### 1. Clone the Repository

```bash
git clone https://github.com/Naveen15github/Jenkins-Multibranch-CI-CD-Pipeline-with-Docker-Terraform-AWS.git
cd Jenkins-Multibranch-CI-CD-Pipeline-with-Docker-Terraform-AWS
```

### 2. Provision AWS Infrastructure with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS credentials and key pair name

terraform init
terraform plan
terraform apply
```

Terraform provisions:
- **Jenkins EC2** (t3.medium) — CI server
- **SonarQube EC2** (t3.medium) — Code quality server
- **App EC2 × 2** (t3.small) — Staging and production servers
- VPC, subnets, security groups, and key pairs

### 3. Configure Jenkins

Once the Jenkins EC2 is running, access it at `http://<jenkins-ip>:8080` and complete the setup wizard. Then install the required plugins:

```
Pipeline
Multibranch Pipeline
Docker Pipeline
SonarQube Scanner
Slack Notification
GitHub Integration
Credentials Binding
```

### 4. Add Jenkins Credentials

Navigate to **Manage Jenkins → Credentials** and add:

| ID | Type | Description |
|---|---|---|
| `dockerhub-credentials` | Username/Password | Docker Hub login |
| `github-credentials` | Username/Password or SSH | GitHub access |
| `slack-token` | Secret text | Slack Bot OAuth token |
| `sonarqube-token` | Secret text | SonarQube analysis token |
| `staging-server` | SSH Username with private key | Staging EC2 SSH key |
| `production-server` | SSH Username with private key | Production EC2 SSH key |

### 5. Create the Multibranch Pipeline

1. New Item → **Multibranch Pipeline** → name it `jenkins-cicd-pipeline`
2. Branch Sources → Add **GitHub** → enter repo URL and credentials
3. Scan interval → 1 minute (or configure GitHub webhook for instant triggers)
4. Save — Jenkins will auto-discover all branches and create sub-pipelines

### 6. Local Development

```bash
npm install
npm test          # Run Jest unit tests
npm run lint      # Run ESLint
npm start         # Start server on port 3000

# Or with Docker Compose:
docker-compose up --build
```

---

## 🔧 Jenkins Configuration

### Jenkinsfile Overview

The `Jenkinsfile` at the root of the repository drives the entire pipeline. It uses `when` conditions to apply different stage logic per branch:

```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "naveen152005/myapp"
        DOCKER_TAG   = "${BUILD_NUMBER}"
        SONAR_HOST   = "http://10.0.1.56:9000"
    }
    stages {
        stage('Checkout')           { ... }
        stage('Install')            { steps { sh 'npm ci' } }
        stage('Test')               { steps { sh 'npm test -- --coverage' } }
        stage('SonarQube Analysis') { ... }
        stage('Quality Gate')       { ... waitForQualityGate() ... }
        stage('Docker Build & Push'){ when { branch pattern: 'staging|main', comparator: 'REGEXP' } ... }
        stage('Deploy to Staging')  { when { branch 'staging' } ... }
        stage('Approval')           { when { branch 'main' } input message: 'Deploy to production?' }
        stage('Deploy to Production'){ when { branch 'main' } ... }
    }
    post {
        success { slackSend ... }
        failure { slackSend ... }
    }
}
```

### Branch Behavior Summary

| Stage | `dev` | `staging` | `main` |
|---|---|---|---|
| Checkout | ✅ | ✅ | ✅ |
| Install & Lint | ✅ | ✅ | ✅ |
| Unit Tests | ✅ | ✅ | ✅ |
| SonarQube | ✅ | ✅ | ✅ |
| Docker Build & Push | ❌ | ✅ | ✅ |
| Deploy to Staging | ❌ | ✅ | ❌ |
| Manual Approval | ❌ | ❌ | ✅ |
| Deploy to Production | ❌ | ❌ | ✅ |

---

## 🏗 Terraform Infrastructure

### Resources Provisioned

```hcl
# main.tf — key resources

resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  user_data     = file("user-data/jenkins.sh")
  tags          = { Name = "jenkins-server" }
}

resource "aws_instance" "sonarqube" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  user_data     = file("user-data/sonarqube.sh")
  tags          = { Name = "sonarqube-server" }
}

resource "aws_instance" "app_staging" {
  ami           = var.ami_id
  instance_type = "t3.small"
  user_data     = file("user-data/app.sh")
  tags          = { Name = "app-staging" }
}

resource "aws_instance" "app_production" {
  ami           = var.ami_id
  instance_type = "t3.small"
  user_data     = file("user-data/app.sh")
  tags          = { Name = "app-production" }
}
```

### Security Groups

| Server | Inbound Ports |
|---|---|
| Jenkins | 8080 (HTTP), 22 (SSH) |
| SonarQube | 9000 (HTTP), 22 (SSH) |
| App Servers | 3000 (App), 22 (SSH) |

---

## 🔍 SonarQube Integration

### sonar-project.properties

```properties
sonar.projectKey=jenkins-cicd-pipeline
sonar.projectName=Jenkins CI/CD Pipeline
sonar.projectVersion=1.0
sonar.sources=src
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.exclusions=node_modules/**,coverage/**
```

### Webhook Configuration

I configured a SonarQube webhook pointing back to Jenkins so the pipeline can block on quality gate results in real time:

- **Name:** Jenkins
- **URL:** `http://10.0.1.56:8080/sonarqube-webhook/`

The pipeline uses `waitForQualityGate()` in the `Quality Gate` stage — if the gate fails, the build stops immediately and no Docker image is built or deployed.

---

## 🔔 Slack Notifications

I implemented four distinct Slack notification types using the Slack Block Kit API for rich, interactive messages:

### 1. Build Failed
Sent immediately when any stage fails. Includes branch, build number, job name, and a **"View Console Output"** button linking directly to the Jenkins log.

### 2. Deployed to Staging
Sent after a successful staging deployment. Includes build number, Docker image tag, staging URL, and **"Open App"** + **"View Build"** buttons.

### 3. Production Deployment Approval Required
Sent when the `main` branch pipeline reaches the approval gate. Includes Docker image, production server IP, and **"Approve in Jenkins"** + **"View Build"** buttons. The pipeline pauses until someone approves in Jenkins.

### 4. Deployed to Production
Sent after a successful production deployment. Includes "🎉 Production deployment successful! The new version is now live." with an **"Open Production App"** button.

---

## 🧪 Testing

### Running Tests

```bash
npm test
# or with coverage:
npm test -- --coverage
```

### Test Results

```
Test Suites: 1 passed, 1 total
Tests:       12 passed, 12 total
Coverage:    97.3%
Time:        2.4s
```

### Test Coverage

| File | Statements | Branches | Functions | Lines |
|---|---|---|---|---|
| `src/app.js` | 100% | 100% | 100% | 100% |
| `src/routes/health.js` | 95% | 90% | 100% | 95% |
| `src/routes/index.js` | 100% | 100% | 100% | 100% |
| **Total** | **97.3%** | **95%** | **100%** | **97.3%** |

---

## 🌐 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Serves the CI/CD Pipeline Dashboard HTML |
| `GET` | `/health` | Returns `{ status: "healthy", uptime: ... }` |
| `GET` | `/api/info` | Returns build metadata and environment info |
| `GET` | `/api/status` | Returns environment deployment status |

---

## 📊 Stats & Metrics

| Metric | Value |
|---|---|
| EC2 Instances | 3 (Jenkins + SonarQube + 2 App) |
| Branches | 3 (dev, staging, main) |
| Total Build Runs | 50+ |
| Unit Tests | 12 |
| Code Coverage | 97% |
| Average Deploy Time | ~5 minutes (commit → live) |
| Docker Hub Images | naveen152005/myapp |
| Terraform Resources | ~15 AWS resources |
| Lines of Code | ~1,500 |
| Monthly AWS Cost | ~$77/month |

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Naveen G.**
- GitHub: [@Naveen15github](https://github.com/Naveen15github)
- Project: [Jenkins-Multibranch-CI-CD-Pipeline-with-Docker-Terraform-AWS](https://github.com/Naveen15github/Jenkins-Multibranch-CI-CD-Pipeline-with-Docker-Terraform-AWS)

---

*Built with ❤️ using modern DevOps practices*
