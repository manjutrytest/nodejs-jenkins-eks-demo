# 📸 Visual Step-by-Step Guide

## Current State → Target State

```
CURRENT STATE ✅
├── EKS Cluster (Running)
├── Jenkins Server (Configured)
├── ECR Repository (Ready)
├── Load Balancer (Deployed)
└── Code (Ready to deploy)

WHAT'S MISSING ⚠️
├── kubectl not configured on Jenkins
├── Code not on GitHub
└── Jenkins pipeline not created

TARGET STATE 🎯
├── kubectl configured ✅
├── Code on GitHub ✅
├── Jenkins pipeline running ✅
└── Auto-deployment working ✅
```

---

## Step 1: Configure kubectl on Jenkins

### What You'll Do:
```
Your Computer → AWS SSM → Jenkins EC2 → Configure kubectl
```

### Commands:
```powershell
# Terminal 1: Connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

```bash
# Terminal 2: In EC2, run these
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

### What Success Looks Like:
```
NAME                                           STATUS   ROLES    AGE
ip-192-168-13-197.eu-north-1.compute.internal  Ready    <none>   93m
ip-192-168-83-102.eu-north-1.compute.internal  Ready    <none>   93m
```

---

## Step 2: Push Code to GitHub

### What You'll Do:
```
Local Code → Git → GitHub Repository
```

### Visual Flow:
```
1. Create GitHub Repo
   https://github.com/new
   ↓
2. Name: nodejs-jenkins-eks-demo
   ↓
3. Click "Create repository"
   ↓
4. Copy the repository URL
```

### Commands:
```powershell
cd nodejs-jenkins-eks-demo
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git push -u origin main
```

### What Success Looks Like:
```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
Writing objects: 100% (45/45), 15.23 KiB | 1.52 MiB/s, done.
Total 45 (delta 0), reused 0 (delta 0)
To https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
 * [new branch]      main -> main
```

---

## Step 3: Create Jenkins Pipeline

### What You'll Do:
```
Jenkins UI → Create Pipeline → Configure → Build
```

### Visual Flow:

**3.1 Create Pipeline**
```
Jenkins Dashboard
  ↓
Click "New Item"
  ↓
Name: nodejs-eks-pipeline
  ↓
Type: Pipeline
  ↓
Click "OK"
```

**3.2 Configure Pipeline**
```
General Section:
  ✅ GitHub project
  URL: https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/

Build Triggers:
  ✅ Poll SCM
  Schedule: H/5 * * * *

Pipeline:
  Definition: Pipeline script from SCM
  SCM: Git
  Repository URL: https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
  Branch: */main
  Script Path: jenkins/Jenkinsfile
```

**3.3 Run Build**
```
Click "Save"
  ↓
Click "Build Now"
  ↓
Click build "#1"
  ↓
Click "Console Output"
  ↓
Watch the magic happen! ✨
```

### What Success Looks Like:
```
[Pipeline] Start of Pipeline
[Pipeline] node
[Pipeline] {
[Pipeline] stage (Checkout)
✅ Checkout complete

[Pipeline] stage (Build)
✅ npm install complete
✅ npm test complete

[Pipeline] stage (Docker Build)
✅ Docker image built

[Pipeline] stage (Push to ECR)
✅ Image pushed to ECR

[Pipeline] stage (Deploy to EKS)
✅ Deployment updated
✅ Rollout successful

[Pipeline] End of Pipeline
Finished: SUCCESS
```

---

## Step 4: Verify Deployment

### What You'll Do:
```
Test URL → Get Response → Confirm Working
```

### Command:
```powershell
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

### What Success Looks Like:
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-7d8f9c5b6-xk2lm",
  "version": "1.0.0"
}
```

---

## Step 5: Test CI/CD Pipeline

### What You'll Do:
```
Edit Code → Commit → Push → Auto-Deploy
```

### Visual Flow:
```
1. Edit app/server.js
   Change message to: "Hello from Node.js on EKS - Updated!"
   ↓
2. Commit and push
   git add .
   git commit -m "Update message"
   git push
   ↓
3. Wait 5 minutes (Jenkins polls GitHub)
   ↓
4. Jenkins automatically starts build #2
   ↓
5. Build completes
   ↓
6. New version deployed to EKS
   ↓
7. Test URL shows updated message! 🎉
```

---

## Complete Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     CI/CD PIPELINE FLOW                      │
└─────────────────────────────────────────────────────────────┘

Developer                GitHub              Jenkins
    │                       │                    │
    │  1. git push          │                    │
    ├──────────────────────>│                    │
    │                       │                    │
    │                       │  2. Poll/Webhook   │
    │                       │<───────────────────┤
    │                       │                    │
    │                       │  3. Checkout       │
    │                       ├───────────────────>│
    │                       │                    │
    │                       │                    │  4. Build
    │                       │                    ├────────┐
    │                       │                    │        │
    │                       │                    │<───────┘
    │                       │                    │
    │                       │                    │  5. Push to ECR
    │                       │                    ├──────────────┐
    │                       │                    │              │
    │                       │                    │              ▼
    │                       │                    │            ECR
    │                       │                    │              │
    │                       │                    │  6. Deploy   │
    │                       │                    ├──────────────┤
    │                       │                    │              │
    │                       │                    │              ▼
    │                       │                    │            EKS
    │                       │                    │              │
    │                       │                    │              │
    │                       │                    │  7. Success  │
    │  8. Access App        │                    │<─────────────┘
    ├───────────────────────┼────────────────────┼──────────────>
    │                       │                    │         Load Balancer
    │<──────────────────────┼────────────────────┼──────────────┤
    │   Response            │                    │              │
    │                       │                    │              │
```

---

## Timeline

```
Minute 0:  Start ACTION 1 (Configure kubectl)
Minute 5:  Start ACTION 2 (Push to GitHub)
Minute 10: Start ACTION 3 (Create Jenkins pipeline)
Minute 15: First build starts
Minute 25: First build completes ✅
Minute 26: Test application ✅
Minute 30: Make code change
Minute 35: Auto-deployment completes ✅

Total Time: ~35 minutes (including build time)
```

---

## Quick Reference Card

```
╔════════════════════════════════════════════════════════════╗
║                    QUICK REFERENCE                         ║
╠════════════════════════════════════════════════════════════╣
║ Jenkins URL:                                               ║
║ http://16.171.58.221:8080                                  ║
║                                                            ║
║ Jenkins EC2 ID:                                            ║
║ i-0b73f57d5bc95b311                                        ║
║                                                            ║
║ EKS Cluster:                                               ║
║ nodejs-eks-cluster                                         ║
║                                                            ║
║ Load Balancer:                                             ║
║ a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3        ║
║ .elb.eu-north-1.amazonaws.com                              ║
║                                                            ║
║ AWS Account:                                               ║
║ 047861165149                                               ║
║                                                            ║
║ Region:                                                    ║
║ eu-north-1                                                 ║
╚════════════════════════════════════════════════════════════╝
```

---

## Next Steps

1. Open **ACTION-PLAN.md** for detailed commands
2. Follow the 3 actions in order
3. Test your application
4. Celebrate! 🎉

**You're 15 minutes away from a fully automated EKS CI/CD pipeline!**
