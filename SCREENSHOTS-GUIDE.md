# Screenshots Guide for Documentation

This guide tells you exactly what screenshots to capture and where to add them in your documentation.

## 📁 Setup Screenshots Folder

First, create a folder for screenshots:

```bash
mkdir screenshots
```

## 📸 Screenshots to Capture (Step by Step)

### 1. Architecture Overview

**Screenshot Name:** `architecture-diagram.png`

**What to capture:**
- Create a simple architecture diagram showing:
  - GitHub → Jenkins → Docker → ECR → EKS → Load Balancer
- You can use draw.io, Lucidchart, or even PowerPoint

**Where to add:**
- README.md (after "Architecture" section)
- ARCHITECTURE.md (at the top)

---

### 2. AWS CloudFormation Stacks

**Screenshot Name:** `cloudformation-stacks.png`

**What to capture:**
1. Go to AWS Console → CloudFormation
2. Show all your stacks:
   - eks-vpc
   - eks-cluster
   - eks-nodegroup
   - eks-ecr
   - jenkins-eks
3. Make sure STATUS shows "CREATE_COMPLETE"

**Where to add:**
- DEPLOYMENT-GUIDE.md (after infrastructure deployment section)
- TEAM-DEPLOYMENT-GUIDE.md (Step 4 verification)

---

### 3. EKS Cluster

**Screenshot Name:** `eks-cluster.png`

**What to capture:**
1. Go to AWS Console → EKS → Clusters
2. Click on "nodejs-eks-cluster"
3. Show the cluster overview with:
   - Status: Active
   - Kubernetes version
   - API server endpoint

**Where to add:**
- ARCHITECTURE.md (EKS section)
- TEAM-DEPLOYMENT-GUIDE.md (Step 5 verification)

---

### 4. EKS Nodes

**Screenshot Name:** `eks-nodes.png`

**What to capture:**
1. In EKS cluster → Compute tab
2. Show the node group with 2 nodes
3. Status should be "Active"

**Where to add:**
- DEPLOYMENT-GUIDE.md (EKS verification section)

---

### 5. ECR Repository

**Screenshot Name:** `ecr-repository.png`

**What to capture:**
1. Go to AWS Console → ECR → Repositories
2. Click on "nodejs-eks-app"
3. Show the repository with Docker images
4. Show image tags (latest, build numbers)

**Where to add:**
- DEPLOYMENT-GUIDE.md (ECR section)
- README.md (Features section)

---

### 6. Jenkins Dashboard

**Screenshot Name:** `jenkins-dashboard.png`

**What to capture:**
1. Open Jenkins: http://YOUR_JENKINS_IP:8080
2. Show the main dashboard with:
   - nodejs-eks-pipeline visible
   - Build history
   - Weather icons (build status)

**Where to add:**
- README.md (CI/CD section)
- TEAM-DEPLOYMENT-GUIDE.md (Step 7)

---

### 7. Jenkins Pipeline Configuration

**Screenshot Name:** `jenkins-pipeline-config.png`

**What to capture:**
1. Go to nodejs-eks-pipeline → Configure
2. Show the Pipeline section with:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL
   - Script Path: jenkins/Jenkinsfile

**Where to add:**
- TEAM-DEPLOYMENT-GUIDE.md (Step 12)

---

### 8. Jenkins Build Success

**Screenshot Name:** `jenkins-build-success.png`

**What to capture:**
1. Click on a successful build (green checkmark)
2. Show the Stage View with all stages:
   - ✅ Checkout
   - ✅ Build
   - ✅ Docker Build
   - ✅ Push to ECR
   - ✅ Deploy to EKS

**Where to add:**
- README.md (CI/CD Workflow section)
- DEPLOYMENT-GUIDE.md (Verification section)

---

### 9. Jenkins Console Output

**Screenshot Name:** `jenkins-console-output.png`

**What to capture:**
1. Click on a build → Console Output
2. Show the successful deployment output:
   - "Deployment successful!"
   - kubectl get pods output
   - "Finished: SUCCESS"

**Where to add:**
- TEAM-DEPLOYMENT-GUIDE.md (Step 13 verification)

---

### 10. GitHub Repository

**Screenshot Name:** `github-repository.png`

**What to capture:**
1. Your GitHub repository main page
2. Show the clean folder structure:
   - app/
   - infra/
   - jenkins/
   - k8s/
   - scripts/
   - README.md

**Where to add:**
- README.md (at the top, after title)

---

### 11. GitHub Webhook

**Screenshot Name:** `github-webhook.png`

**What to capture:**
1. Go to GitHub → Settings → Webhooks
2. Show the webhook with:
   - Payload URL: http://YOUR_JENKINS_IP:8080/github-webhook/
   - ✅ Green checkmark (successful)
   - Recent Deliveries

**Where to add:**
- TEAM-DEPLOYMENT-GUIDE.md (Step 11)

---

### 12. Kubernetes Pods

**Screenshot Name:** `kubectl-get-pods.png`

**What to capture:**
1. Open PowerShell
2. Run: `kubectl get pods`
3. Show output with 3 pods running:
   ```
   NAME                          READY   STATUS    RESTARTS   AGE
   nodejs-app-xxxxx-xxxxx        1/1     Running   0          10m
   nodejs-app-xxxxx-xxxxx        1/1     Running   0          10m
   nodejs-app-xxxxx-xxxxx        1/1     Running   0          10m
   ```

**Where to add:**
- README.md (Monitoring section)
- DEPLOYMENT-GUIDE.md (Verification section)

---

### 13. Kubernetes Service

**Screenshot Name:** `kubectl-get-service.png`

**What to capture:**
1. Run: `kubectl get svc nodejs-app-service`
2. Show the LoadBalancer service with EXTERNAL-IP

**Where to add:**
- DEPLOYMENT-GUIDE.md (Verification section)
- TEAM-DEPLOYMENT-GUIDE.md (Step 13)

---

### 14. Application Response

**Screenshot Name:** `application-response.png`

**What to capture:**
1. Open browser or use Postman
2. Access: http://YOUR-LOAD-BALANCER-URL
3. Show the JSON response:
   ```json
   {
     "message": "Node.js App on EKS - Jenkins CI/CD by manju",
     "version": "1.0.0",
     "timestamp": "...",
     "environment": "production",
     "pod": "nodejs-app-xxxxx"
   }
   ```

**Where to add:**
- README.md (at the top, as hero image)
- DEPLOYMENT-GUIDE.md (Testing section)
- TEAM-DEPLOYMENT-GUIDE.md (Step 13 verification)

---

### 15. AWS Load Balancer

**Screenshot Name:** `aws-load-balancer.png`

**What to capture:**
1. Go to AWS Console → EC2 → Load Balancers
2. Show the EKS-created load balancer
3. Show:
   - State: Active
   - DNS name
   - Target groups

**Where to add:**
- ARCHITECTURE.md (Load Balancer section)

---

### 16. Kubernetes Dashboard (Optional)

**Screenshot Name:** `kubernetes-dashboard.png`

**What to capture:**
1. If you have K8s dashboard installed, show:
   - Deployments
   - Pods
   - Services
   - Resource usage

**Where to add:**
- ARCHITECTURE.md (Monitoring section)

---

### 17. Auto-Deployment Test

**Screenshot Name:** `auto-deployment-test.png`

**What to capture:**
1. Show Git Bash with:
   - Code change commit
   - git push command
2. Then show Jenkins automatically starting a new build

**Where to add:**
- README.md (CI/CD Workflow section)
- TEAM-DEPLOYMENT-GUIDE.md (Making Changes section)

---

### 18. CloudWatch Logs (Optional)

**Screenshot Name:** `cloudwatch-logs.png`

**What to capture:**
1. Go to AWS Console → CloudWatch → Log groups
2. Show EKS cluster logs

**Where to add:**
- ARCHITECTURE.md (Monitoring section)

---

## 📝 How to Add Screenshots to Documentation

### Method 1: Using GitHub (Recommended)

1. Create `screenshots/` folder in your repository
2. Upload all screenshots to this folder
3. In your markdown files, add:

```markdown
![Description](screenshots/screenshot-name.png)
```

### Method 2: Using Relative Paths

```markdown
![Architecture Diagram](./screenshots/architecture-diagram.png)
```

### Method 3: Using GitHub Issues (for hosting)

1. Create a new issue in your repo
2. Drag and drop images
3. Copy the generated URL
4. Use in markdown:

```markdown
![Description](https://user-images.githubusercontent.com/...)
```

---

## 📋 Screenshot Checklist

Use this checklist as you capture screenshots:

- [ ] 1. Architecture diagram
- [ ] 2. CloudFormation stacks
- [ ] 3. EKS cluster overview
- [ ] 4. EKS nodes
- [ ] 5. ECR repository with images
- [ ] 6. Jenkins dashboard
- [ ] 7. Jenkins pipeline configuration
- [ ] 8. Jenkins build success (Stage View)
- [ ] 9. Jenkins console output
- [ ] 10. GitHub repository structure
- [ ] 11. GitHub webhook configuration
- [ ] 12. kubectl get pods output
- [ ] 13. kubectl get service output
- [ ] 14. Application JSON response
- [ ] 15. AWS Load Balancer
- [ ] 16. Kubernetes dashboard (optional)
- [ ] 17. Auto-deployment test
- [ ] 18. CloudWatch logs (optional)

---

## 🎨 Screenshot Best Practices

1. **Resolution**: Use at least 1920x1080 for clarity
2. **Format**: PNG for screenshots, JPG for photos
3. **Annotations**: Use red boxes/arrows to highlight important parts
4. **Consistency**: Use the same browser/terminal theme
5. **Privacy**: Hide sensitive information (IPs, keys, account IDs)
6. **File Size**: Compress large images (use tinypng.com)
7. **Naming**: Use descriptive names (e.g., `jenkins-build-success.png`)

---

## 🔧 Tools for Screenshots

- **Windows**: Snipping Tool, Snip & Sketch (Win + Shift + S)
- **Mac**: Command + Shift + 4
- **Linux**: Flameshot, GNOME Screenshot
- **Browser**: Full page screenshot extensions
- **Annotation**: Greenshot, ShareX, Snagit

---

## 📄 Example: Adding to README.md

```markdown
# Node.js EKS CI/CD Pipeline with Jenkins

![Application Response](screenshots/application-response.png)

## Architecture

![Architecture Diagram](screenshots/architecture-diagram.png)

## CI/CD Workflow

![Jenkins Build Success](screenshots/jenkins-build-success.png)
```

---

## 🚀 Quick Start

1. **Capture** all 18 screenshots following this guide
2. **Create** `screenshots/` folder in your repository
3. **Upload** all screenshots to the folder
4. **Update** documentation files with image links
5. **Commit and push** to GitHub
6. **Verify** images display correctly on GitHub

---

**Once you add these screenshots, your documentation will be professional and easy to follow for your team!** 📸
