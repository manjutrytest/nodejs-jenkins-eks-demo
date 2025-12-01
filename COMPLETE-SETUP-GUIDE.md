# 🎯 Complete Setup Guide - Git Push, Webhook & Jenkins Pipeline

## Overview

This guide will help you:
1. ✅ Push code to GitHub via Git Bash
2. ✅ Configure kubectl on Jenkins EC2
3. ✅ Setup GitHub webhook
4. ✅ Create Jenkins pipeline
5. ✅ Test auto-deployment

**Total time: ~30 minutes**

---

## 📋 Prerequisites

- ✅ Jenkins installed and configured (DONE)
- ✅ EKS cluster running (DONE)
- ✅ ECR repository created (DONE)
- ✅ Git Bash installed on your machine
- ✅ GitHub account

---

## Part 1: Push to GitHub (10 minutes)

### Step 1.1: Open Git Bash

1. Navigate to project directory
2. Right-click in `nodejs-jenkins-eks-demo` folder
3. Select **"Git Bash Here"**

Or open Git Bash and run:
```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo
```

### Step 1.2: Create GitHub Repository

1. Open browser: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Description: `CI/CD Pipeline for Node.js on AWS EKS with Jenkins`
4. Select: **Public**
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**
7. **Keep this page open** - you'll need the URL

### Step 1.3: Run Git Commands

In Git Bash, run these commands one by one:

```bash
# Initialize git (removes any existing git config)
rm -rf .git
git init
git branch -M main

# Add all files
git add .

# Check what will be committed
git status

# Commit
git commit -m "Initial commit - EKS CI/CD pipeline with Jenkins"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Verify remote
git remote -v

# Push to GitHub
git push -u origin main
```

### Step 1.4: Authentication

When prompted for credentials:
- **Username:** Your GitHub username
- **Password:** Use Personal Access Token (not your GitHub password)

**To generate token:**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Note: `Jenkins EKS Demo`
4. Select scope: ✅ **repo** (all)
5. Click "Generate token"
6. **Copy the token** and use it as password

### Step 1.5: Verify

After successful push, go to:
```
https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo
```

You should see all your files! ✅

---

## Part 2: Configure kubectl on Jenkins (5 minutes)

Jenkins needs access to your EKS cluster to deploy applications.

### Step 2.1: Connect to Jenkins EC2

Open **PowerShell** (not Git Bash) and run:

```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

### Step 2.2: Configure kubectl

In the EC2 terminal, run these commands:

```bash
# Switch to jenkins user
sudo su - jenkins

# Configure kubectl for EKS
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify connection
kubectl get nodes

# You should see 2 nodes with STATUS "Ready"

# Exit jenkins user
exit
```

**Expected output:**
```
NAME                                           STATUS   ROLES    AGE
ip-192-168-13-197.eu-north-1.compute.internal  Ready    <none>   2h
ip-192-168-83-102.eu-north-1.compute.internal  Ready    <none>   2h
```

✅ **Success!** Jenkins can now deploy to EKS.

---

## Part 3: Setup GitHub Webhook (5 minutes)

This enables automatic builds when you push code.

### Step 3.1: Go to GitHub Repository Settings

1. Go to: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo`
2. Click **"Settings"** tab (top right)
3. Click **"Webhooks"** (left sidebar)
4. Click **"Add webhook"**

### Step 3.2: Configure Webhook

Fill in these details:

- **Payload URL:** `http://16.171.58.221:8080/github-webhook/`
- **Content type:** `application/json`
- **Secret:** (leave empty)
- **Which events?** Select "Just the push event"
- **Active:** ✅ (checked)

Click **"Add webhook"**

### Step 3.3: Verify Webhook

After adding, you should see:
- ✅ Green checkmark next to the webhook
- "Recent Deliveries" tab shows a successful ping

✅ **Success!** GitHub will now notify Jenkins on every push.

---

## Part 4: Create Jenkins Pipeline (10 minutes)

### Step 4.1: Open Jenkins

Go to: http://16.171.58.221:8080

### Step 4.2: Create Pipeline Job

1. Click **"New Item"** (top left)
2. Enter name: `nodejs-eks-pipeline`
3. Select: **"Pipeline"**
4. Click **"OK"**

### Step 4.3: Configure General Section

- **Description:** `CI/CD Pipeline for Node.js application on AWS EKS`
- ✅ Check **"GitHub project"**
- **Project url:** `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

### Step 4.4: Configure Build Triggers

- ✅ Check **"GitHub hook trigger for GITScm polling"**
- ✅ Check **"Poll SCM"**
- **Schedule:** `H/5 * * * *`

### Step 4.5: Configure Pipeline

- **Definition:** `Pipeline script from SCM`
- **SCM:** `Git`
- **Repository URL:** `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- **Credentials:** `- none -` (if public repo)
- **Branch Specifier:** `*/main`
- **Script Path:** `jenkins/Jenkinsfile`

### Step 4.6: Save and Build

1. Click **"Save"**
2. Click **"Build Now"**
3. Click on build **"#1"**
4. Click **"Console Output"**

### Step 4.7: Monitor Build

Watch the console output. Build stages:

```
✅ Checkout - Pull code from GitHub
✅ Build - npm install & test
✅ Docker Build - Create container image
✅ Push to ECR - Upload to AWS ECR
✅ Deploy to EKS - Update Kubernetes deployment
```

**Build time:** 5-10 minutes

✅ **Success when:** Console shows "Finished: SUCCESS"

---

## Part 5: Verify Deployment (5 minutes)

### Step 5.1: Check Kubernetes Resources

In PowerShell:

```powershell
# Check pods
kubectl get pods

# Check service
kubectl get svc nodejs-app-service

# Check deployment
kubectl get deployment nodejs-app
```

### Step 5.2: Test Application

```powershell
# Test the endpoint
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-7d8f9c5b6-xxxxx"
}
```

✅ **Success!** Your application is live!

---

## Part 6: Test Auto-Deployment (5 minutes)

### Step 6.1: Make a Code Change

In Git Bash:

```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo/app

# Edit server.js (use nano, vim, or your editor)
nano server.js
```

Change line 12:
```javascript
message: "Hello from Node.js on EKS - Webhook Works!"
```

Save and exit (Ctrl+X, Y, Enter in nano)

### Step 6.2: Commit and Push

```bash
# Go back to project root
cd ..

# Add changes
git add .

# Commit
git commit -m "Test webhook auto-deployment"

# Push
git push
```

### Step 6.3: Watch Jenkins

1. Go to Jenkins: http://16.171.58.221:8080
2. Go to pipeline: `nodejs-eks-pipeline`
3. **Within seconds**, build #2 should start automatically!
4. Click on build #2 → Console Output
5. Watch it deploy

### Step 6.4: Verify Update

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

✅ **Success!** Auto-deployment is working!

---

## 🎉 Complete CI/CD Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR CI/CD PIPELINE                       │
└─────────────────────────────────────────────────────────────┘

1. Developer (You)
   │
   │ Edit code in VS Code/Editor
   │
   ▼
2. Git Bash
   │
   │ git add . && git commit -m "..." && git push
   │
   ▼
3. GitHub Repository
   │
   │ Webhook triggers instantly
   │
   ▼
4. Jenkins Server (http://16.171.58.221:8080)
   │
   │ Checkout → Build → Test → Docker Build
   │
   ▼
5. Amazon ECR
   │
   │ Push Docker image
   │
   ▼
6. Jenkins
   │
   │ Deploy to EKS (kubectl apply)
   │
   ▼
7. Amazon EKS Cluster
   │
   │ Rolling update (zero downtime)
   │
   ▼
8. Load Balancer
   │
   │ Route traffic to new pods
   │
   ▼
9. Users
   │
   │ Access updated application
   │
   ▼
   ✅ DONE! (Total time: ~5 minutes from push to live)
```

---

## 📋 Quick Reference

### Your URLs
```
GitHub:      https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo
Jenkins:     http://16.171.58.221:8080
Pipeline:    http://16.171.58.221:8080/job/nodejs-eks-pipeline/
Application: http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
Webhook:     http://16.171.58.221:8080/github-webhook/
```

### Quick Commands

**Git (in Git Bash):**
```bash
cd /c/Users/mangowra/nodejs-jenkins-eks-demo
git status
git add .
git commit -m "Your message"
git push
```

**Kubernetes (in PowerShell):**
```powershell
kubectl get pods
kubectl get svc
kubectl logs -f deployment/nodejs-app
kubectl describe pod POD_NAME
```

**Jenkins EC2 (in PowerShell):**
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

---

## 🆘 Troubleshooting

### Git push fails with authentication error
**Solution:** Use Personal Access Token
1. Generate at: https://github.com/settings/tokens
2. Use token as password when pushing

### Webhook not triggering builds
**Solution:** 
1. Check webhook shows green checkmark in GitHub
2. Verify "GitHub hook trigger" is enabled in Jenkins pipeline
3. Test webhook manually in GitHub (Redeliver)

### Build fails with kubectl error
**Solution:**
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

### Application not accessible
**Solution:**
1. Wait 2-3 minutes for DNS propagation
2. Check pods: `kubectl get pods`
3. Check logs: `kubectl logs -l app=nodejs-app`

---

## ✅ Completion Checklist

- [ ] Code pushed to GitHub via Git Bash
- [ ] kubectl configured on Jenkins EC2
- [ ] GitHub webhook added and verified (green checkmark)
- [ ] Jenkins pipeline created and configured
- [ ] First build completed successfully
- [ ] Application accessible via Load Balancer
- [ ] Code change tested and auto-deployed
- [ ] Webhook auto-deployment working

**When all boxes are checked, you're done!** 🎉

---

## 🎓 What You've Built

A production-ready CI/CD pipeline with:
- ✅ Automated builds on every git push
- ✅ Docker containerization
- ✅ AWS ECR for image storage
- ✅ Kubernetes orchestration on EKS
- ✅ Zero-downtime rolling updates
- ✅ Load balancer for high availability
- ✅ Infrastructure as Code (CloudFormation)
- ✅ Pipeline as Code (Jenkinsfile)

---

## 🚀 Next Steps

1. **Add more features** to your application
2. **Setup monitoring** with CloudWatch
3. **Add automated tests** to pipeline
4. **Implement blue-green deployments**
5. **Add staging environment**
6. **Setup alerts** for build failures

---

**Start with Part 1 and work through each part. You'll have a complete CI/CD pipeline in 30 minutes!** 🚀
