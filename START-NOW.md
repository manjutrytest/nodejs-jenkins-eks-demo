# 🚀 START HERE - Complete Your Jenkins EKS Pipeline

## Current Status ✅

Your infrastructure is ready:
- ✅ EKS Cluster: **nodejs-eks-cluster** (2 nodes running)
- ✅ Jenkins Server: **http://16.171.58.221:8080** (configured)
- ✅ ECR Repository: **nodejs-eks-app** (ready)
- ✅ Load Balancer: **a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com**

---

## 🎯 3 Simple Steps to Complete Setup

### Step 1: Configure kubectl on Jenkins (5 min)

**Connect to Jenkins EC2:**
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

**In the EC2 terminal, run:**
```bash
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

You should see 2 nodes listed. ✅

---

### Step 2: Push Code to GitHub (5 min)

**Create GitHub repo:** https://github.com/new
- Name: `nodejs-jenkins-eks-demo`
- Click "Create repository"

**Push code:**
```powershell
cd nodejs-jenkins-eks-demo
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git push -u origin main
```

---

### Step 3: Create Jenkins Pipeline (3 min)

**In Jenkins (http://16.171.58.221:8080):**

1. Click **"New Item"**
2. Name: `nodejs-eks-pipeline`
3. Type: **"Pipeline"**
4. Click **"OK"**

**Configure:**
- General → ✅ GitHub project → URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`
- Build Triggers → ✅ Poll SCM → Schedule: `H/5 * * * *`
- Pipeline → Definition: `Pipeline script from SCM`
  - SCM: `Git`
  - Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
  - Branch: `*/main`
  - Script Path: `jenkins/Jenkinsfile`
- Click **"Save"**

**Run first build:**
- Click **"Build Now"**
- Click build **#1** → **"Console Output"**
- Watch it complete (5-10 minutes)

---

## 🎉 Test Your Application

After build completes:

```powershell
# Test the application
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-xxxxx"
}
```

---

## 🔄 Test CI/CD Pipeline

Make a change:
```powershell
# Edit app/server.js - change the message
git add .
git commit -m "Update message"
git push
```

Wait 5 minutes → Jenkins auto-builds → New version deployed! 🚀

---

## 📋 Quick Reference

| Resource | Value |
|----------|-------|
| Jenkins URL | http://16.171.58.221:8080 |
| Jenkins EC2 | i-0b73f57d5bc95b311 |
| EKS Cluster | nodejs-eks-cluster |
| Load Balancer | a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com |
| AWS Account | 047861165149 |
| Region | eu-north-1 |

---

## 🆘 Troubleshooting

**Build fails with kubectl error:**
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

**Docker permission denied:**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**Can't access application:**
```powershell
# Check pods
kubectl get pods

# Check logs
kubectl logs -l app=nodejs-app
```

---

## 📚 Additional Documentation

- **NEXT-STEPS-CHECKLIST.md** - Detailed step-by-step guide
- **QUICK-JENKINS-CONFIG.md** - Configuration reference
- **JENKINS-SETUP-GUIDE.md** - Complete setup guide
- **Jenkinsfile** - Pipeline configuration (already has your AWS account)

---

**🎯 Start with Step 1 above and you'll be done in 15 minutes!**
