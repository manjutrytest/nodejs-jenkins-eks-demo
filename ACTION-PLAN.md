# 🎯 ACTION PLAN - Complete in 15 Minutes

## ✅ What's Already Done
- Jenkins installed and configured at http://16.171.58.221:8080
- EKS cluster running with 2 nodes
- ECR repository created
- Load Balancer deployed
- All code and configuration files ready

---

## 🚀 What You Need to Do Now

### ACTION 1: Configure kubectl on Jenkins (5 minutes)

**Open a new terminal and run:**
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

**In the EC2 terminal that opens, copy and paste these commands:**
```bash
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

**✅ Success when you see:** 2 nodes listed with STATUS "Ready"

---

### ACTION 2: Push Code to GitHub (5 minutes)

**Step 2a: Create GitHub Repository**
1. Open browser: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Select Public or Private
4. **DO NOT** check "Initialize with README"
5. Click "Create repository"

**Step 2b: Push Code**

Copy your GitHub username, then run:
```powershell
cd nodejs-jenkins-eks-demo

git init
git add .
git commit -m "Initial commit - EKS CI/CD pipeline"
git branch -M main

# Replace YOUR_USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

git push -u origin main
```

**✅ Success when:** Code appears in your GitHub repository

---

### ACTION 3: Create Jenkins Pipeline (5 minutes)

**Step 3a: Create Pipeline Job**
1. Open Jenkins: http://16.171.58.221:8080
2. Click "New Item"
3. Name: `nodejs-eks-pipeline`
4. Select "Pipeline"
5. Click "OK"

**Step 3b: Configure Pipeline**

Scroll down and fill in these sections:

**General:**
- Description: `CI/CD Pipeline for Node.js on EKS`
- ✅ Check "GitHub project"
- Project url: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

**Build Triggers:**
- ✅ Check "Poll SCM"
- Schedule: `H/5 * * * *`

**Pipeline:**
- Definition: Select `Pipeline script from SCM`
- SCM: Select `Git`
- Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- Branch Specifier: `*/main`
- Script Path: `jenkins/Jenkinsfile`

**Step 3c: Save and Build**
1. Click "Save" at the bottom
2. Click "Build Now" on the left
3. Click on build "#1" that appears
4. Click "Console Output"
5. Watch the build (takes 5-10 minutes)

**✅ Success when:** Console shows "Finished: SUCCESS"

---

## 🎉 Verify Everything Works

After the build completes successfully:

```powershell
# Test the application
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T...",
  "hostname": "nodejs-app-..."
}
```

---

## 🔄 Test Auto-Deployment

Make a small change to test the CI/CD pipeline:

```powershell
cd nodejs-jenkins-eks-demo
```

Edit `app/server.js` - change line 12:
```javascript
message: "Hello from Node.js on EKS - CI/CD Works!"
```

Push the change:
```powershell
git add .
git commit -m "Test CI/CD pipeline"
git push
```

**Wait 5 minutes** (Jenkins polls every 5 minutes)
- Jenkins will automatically start a new build
- After build completes, test the URL again
- You should see your updated message!

---

## 📋 Quick Copy-Paste Commands

**Connect to Jenkins EC2:**
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

**Configure kubectl (run in EC2):**
```bash
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

**Push to GitHub (replace YOUR_USERNAME):**
```powershell
cd nodejs-jenkins-eks-demo
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git push -u origin main
```

**Test application:**
```powershell
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

---

## 🆘 Troubleshooting

### Problem: Build fails with "kubectl: command not found"
**Solution:** You skipped ACTION 1. Go back and configure kubectl on Jenkins.

### Problem: Build fails with "Permission denied" for Docker
**Solution:** Run on Jenkins EC2:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Problem: Can't push to GitHub
**Solution:** Make sure you:
1. Created the GitHub repository first
2. Replaced YOUR_USERNAME with your actual username
3. Have git credentials configured

### Problem: Application not responding
**Solution:** Wait 2-3 minutes for DNS propagation, then try again.

---

## 📊 Your Configuration

| Item | Value |
|------|-------|
| Jenkins URL | http://16.171.58.221:8080 |
| Jenkins EC2 ID | i-0b73f57d5bc95b311 |
| EKS Cluster | nodejs-eks-cluster |
| Load Balancer | a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com |
| AWS Account | 047861165149 |
| Region | eu-north-1 |
| ECR Repository | nodejs-eks-app |

---

## ✅ Completion Checklist

- [ ] ACTION 1: kubectl configured on Jenkins
- [ ] ACTION 2: Code pushed to GitHub
- [ ] ACTION 3: Jenkins pipeline created and first build successful
- [ ] Application accessible via Load Balancer
- [ ] CI/CD tested with code change

**When all boxes are checked, you're done!** 🎉

---

## 🎯 What You'll Have

A complete CI/CD pipeline where:
1. You push code to GitHub
2. Jenkins automatically detects the change
3. Builds Docker image
4. Pushes to ECR
5. Deploys to EKS
6. Application updates automatically

**Just like your ECS project, but with Kubernetes!** 🚀
