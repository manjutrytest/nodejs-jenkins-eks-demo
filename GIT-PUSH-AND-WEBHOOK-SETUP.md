# 🚀 Git Push & Jenkins Webhook Setup Guide

## Step 1: Push Repository to GitHub via Git Bash

### 1.1 Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Description: `CI/CD Pipeline for Node.js on AWS EKS with Jenkins`
4. Select: **Public** (or Private if you prefer)
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**

### 1.2 Push Code via Git Bash

Open Git Bash in the `nodejs-jenkins-eks-demo` directory and run:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"

# Rename branch to main
git branch -M main

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push to GitHub
git push -u origin main
```

**If you get authentication error:**
```bash
# Use personal access token instead of password
# Generate token at: https://github.com/settings/tokens
# Then push again and use token as password
git push -u origin main
```

✅ **Success when:** Code appears in your GitHub repository

---

## Step 2: Configure kubectl on Jenkins EC2

Before creating the pipeline, Jenkins needs access to your EKS cluster.

### 2.1 Connect to Jenkins EC2

Open PowerShell and run:
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

### 2.2 Configure kubectl for Jenkins User

In the EC2 terminal, run:
```bash
# Switch to jenkins user
sudo su - jenkins

# Configure kubectl
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify connection
kubectl get nodes

# Should see 2 nodes listed
# Exit jenkins user
exit
```

✅ **Success when:** You see 2 EKS nodes with STATUS "Ready"

---

## Step 3: Setup GitHub Webhook

### 3.1 Get Jenkins Webhook URL

Your Jenkins webhook URL is:
```
http://16.171.58.221:8080/github-webhook/
```

### 3.2 Add Webhook in GitHub

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo`
2. Click **"Settings"** (top right)
3. Click **"Webhooks"** (left sidebar)
4. Click **"Add webhook"**

**Configure webhook:**
- **Payload URL:** `http://16.171.58.221:8080/github-webhook/`
- **Content type:** `application/json`
- **Secret:** (leave empty)
- **Which events would you like to trigger this webhook?**
  - Select: **"Just the push event"**
- **Active:** ✅ (checked)
- Click **"Add webhook"**

### 3.3 Verify Webhook

After adding, you should see:
- ✅ Green checkmark next to the webhook
- Recent Deliveries tab shows successful ping

If you see ❌ red X:
- Check that Jenkins is accessible at http://16.171.58.221:8080
- Verify the webhook URL is correct
- Check Jenkins security settings allow webhooks

✅ **Success when:** Webhook shows green checkmark

---

## Step 4: Create Jenkins Pipeline

### 4.1 Open Jenkins

Go to: http://16.171.58.221:8080

### 4.2 Create New Pipeline Job

1. Click **"New Item"** (top left)
2. Enter name: `nodejs-eks-pipeline`
3. Select: **"Pipeline"**
4. Click **"OK"**

### 4.3 Configure Pipeline

**General Section:**
- **Description:** `CI/CD Pipeline for Node.js application on AWS EKS`
- ✅ Check **"GitHub project"**
- **Project url:** `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

**Build Triggers:**
- ✅ Check **"GitHub hook trigger for GITScm polling"**
- ✅ Check **"Poll SCM"** (as backup)
- **Schedule:** `H/5 * * * *`

**Pipeline Section:**
- **Definition:** Select `Pipeline script from SCM`
- **SCM:** Select `Git`
- **Repository URL:** `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- **Credentials:** 
  - If public repo: Leave as "none"
  - If private repo: Click "Add" → Add GitHub credentials
- **Branches to build:**
  - **Branch Specifier:** `*/main`
- **Script Path:** `jenkins/Jenkinsfile`

**Advanced Options (Optional):**
- **Lightweight checkout:** ✅ (checked for faster checkout)

### 4.4 Save Configuration

Click **"Save"** at the bottom

✅ **Success when:** Pipeline is created and you see the pipeline dashboard

---

## Step 5: Run First Build

### 5.1 Trigger Manual Build

1. On the pipeline page, click **"Build Now"** (left sidebar)
2. A new build (#1) will appear under "Build History"
3. Click on **"#1"**
4. Click **"Console Output"**

### 5.2 Monitor Build Progress

Watch the console output. You should see these stages:

```
[Pipeline] Start of Pipeline
[Pipeline] node
[Pipeline] {
[Pipeline] stage (Checkout)
✅ Checking out code from GitHub...

[Pipeline] stage (Build)
✅ Running npm install...
✅ Running npm test...

[Pipeline] stage (Docker Build)
✅ Building Docker image...

[Pipeline] stage (Push to ECR)
✅ Logging into ECR...
✅ Pushing image to ECR...

[Pipeline] stage (Deploy to EKS)
✅ Updating kubeconfig...
✅ Applying Kubernetes manifests...
✅ Waiting for rollout...

[Pipeline] End of Pipeline
Finished: SUCCESS
```

**Build time:** 5-10 minutes

✅ **Success when:** Console shows "Finished: SUCCESS"

---

## Step 6: Verify Deployment

### 6.1 Check Kubernetes Resources

Open PowerShell and run:

```powershell
# Check pods
kubectl get pods

# Check service
kubectl get svc nodejs-app-service

# Check deployment
kubectl get deployment nodejs-app
```

**Expected output:**
```
NAME                           READY   STATUS    RESTARTS   AGE
nodejs-app-7d8f9c5b6-xxxxx    1/1     Running   0          2m
```

### 6.2 Get Load Balancer URL

```powershell
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Your Load Balancer URL:**
```
a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

### 6.3 Test Application

Wait 2-3 minutes for DNS propagation, then:

```powershell
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-7d8f9c5b6-xxxxx",
  "version": "1.0.0"
}
```

✅ **Success when:** You get the JSON response

---

## Step 7: Test Webhook Auto-Deployment

### 7.1 Make a Code Change

Open Git Bash in your project directory:

```bash
# Edit the server.js file
cd app
nano server.js  # or use your preferred editor
```

Change line 12 from:
```javascript
message: "Hello from Node.js on EKS!"
```

To:
```javascript
message: "Hello from Node.js on EKS - Webhook Works!"
```

### 7.2 Commit and Push

```bash
# Go back to project root
cd ..

# Add changes
git add .

# Commit
git commit -m "Test webhook auto-deployment"

# Push to GitHub
git push
```

### 7.3 Watch Jenkins Auto-Build

1. Go to Jenkins: http://16.171.58.221:8080
2. Go to your pipeline: `nodejs-eks-pipeline`
3. **Within seconds**, a new build (#2) should start automatically!
4. Click on build #2 → Console Output
5. Watch it deploy

### 7.4 Verify Updated Application

After build completes:

```powershell
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS - Webhook Works!",
  ...
}
```

✅ **Success when:** You see your updated message!

---

## 🎉 Complete CI/CD Flow

```
Developer (You)
    │
    │ 1. Make code change
    │ 2. git commit & push
    │
    ▼
GitHub Repository
    │
    │ 3. Webhook triggers
    │
    ▼
Jenkins Server
    │
    │ 4. Checkout code
    │ 5. Build & test
    │ 6. Build Docker image
    │
    ▼
Amazon ECR
    │
    │ 7. Push image
    │
    ▼
Jenkins
    │
    │ 8. Deploy to EKS
    │
    ▼
Amazon EKS
    │
    │ 9. Rolling update
    │
    ▼
Load Balancer
    │
    │ 10. Serve traffic
    │
    ▼
Users (Application accessible)
```

---

## 📋 Quick Command Reference

### Git Commands
```bash
# Check status
git status

# Add files
git add .

# Commit
git commit -m "Your message"

# Push
git push

# View log
git log --oneline

# View remote
git remote -v
```

### Kubernetes Commands
```powershell
# Get all resources
kubectl get all

# Get pods with details
kubectl get pods -o wide

# View logs
kubectl logs -f deployment/nodejs-app

# Describe pod
kubectl describe pod POD_NAME

# Scale deployment
kubectl scale deployment nodejs-app --replicas=3
```

### Jenkins Commands
```powershell
# Connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1

# Restart Jenkins (on EC2)
sudo systemctl restart jenkins

# View Jenkins logs (on EC2)
sudo tail -f /var/log/jenkins/jenkins.log
```

---

## 🆘 Troubleshooting

### Issue: Git push authentication failed
**Solution:**
```bash
# Generate GitHub Personal Access Token
# Go to: https://github.com/settings/tokens
# Generate new token (classic)
# Select scopes: repo (all)
# Use token as password when pushing
```

### Issue: Webhook not triggering builds
**Solution:**
1. Check webhook in GitHub shows green checkmark
2. Verify Jenkins is accessible: http://16.171.58.221:8080
3. Check Jenkins pipeline has "GitHub hook trigger" enabled
4. Test webhook manually in GitHub (Recent Deliveries → Redeliver)

### Issue: Build fails with kubectl error
**Solution:**
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

### Issue: Docker permission denied
**Solution:**
```bash
# On Jenkins EC2
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: Application not accessible
**Solution:**
```powershell
# Check pods are running
kubectl get pods

# Check service
kubectl get svc

# View pod logs
kubectl logs -l app=nodejs-app

# Wait 2-3 minutes for DNS propagation
```

---

## ✅ Completion Checklist

- [ ] GitHub repository created
- [ ] Code pushed to GitHub via Git Bash
- [ ] kubectl configured on Jenkins EC2
- [ ] GitHub webhook added and verified
- [ ] Jenkins pipeline created and configured
- [ ] First build completed successfully
- [ ] Application accessible via Load Balancer
- [ ] Webhook tested with code change
- [ ] Auto-deployment working

**When all boxes are checked, your CI/CD pipeline is complete!** 🎉

---

## 🎯 Your Configuration

```
GitHub Repo:     https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo
Jenkins URL:     http://16.171.58.221:8080
Webhook URL:     http://16.171.58.221:8080/github-webhook/
Pipeline Name:   nodejs-eks-pipeline
Application URL: http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

---

**🚀 Start with Step 1 and work through each step. You'll have a fully automated CI/CD pipeline in 30 minutes!**
