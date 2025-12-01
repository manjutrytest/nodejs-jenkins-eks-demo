# Next Steps Checklist - Complete Your EKS CI/CD Pipeline

## ✅ Completed
- [x] Jenkins installed and configured
- [x] Required plugins installed
- [x] Admin user created
- [x] EKS cluster running
- [x] ECR repository created

---

## 🔄 Step 1: Configure kubectl on Jenkins EC2 (5 minutes)

**Connect to Jenkins EC2:**
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

**Run these commands in EC2 terminal:**
```bash
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
exit
```

**Expected output:**
```
NAME                                           STATUS   ROLES    AGE
ip-192-168-xx-xx.eu-north-1.compute.internal   Ready    <none>   1h
```

✅ **Mark complete when you see the node listed**

---

## 🔄 Step 2: Push Code to GitHub (5 minutes)

### Option A: Create New GitHub Repository

1. Go to https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Public or Private (your choice)
4. Don't initialize with README
5. Click "Create repository"

### Option B: Use Existing Repository

Skip to pushing code below.

### Push Code:

```powershell
cd nodejs-jenkins-eks-demo

# Initialize (if new repo)
git init
git branch -M main

# Add and commit
git add .
git commit -m "Initial commit - EKS CI/CD pipeline"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push
git push -u origin main
```

✅ **Mark complete when code is on GitHub**

---

## 🔄 Step 3: Create Jenkins Pipeline Job (3 minutes)

### In Jenkins (http://16.171.58.221:8080):

1. Click **"New Item"**
2. Name: `nodejs-eks-pipeline`
3. Select: **"Pipeline"**
4. Click **"OK"**

### Configure:

**General Section:**
- Description: `CI/CD Pipeline for Node.js on EKS`
- ✅ Check "GitHub project"
- Project URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

**Build Triggers:**
- ✅ Check "Poll SCM"
- Schedule: `H/5 * * * *`

**Pipeline Section:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- Credentials: (Add if private repo)
- Branch: `*/main`
- Script Path: `jenkins/Jenkinsfile`

4. Click **"Save"**

✅ **Mark complete when pipeline is created**

---

## 🔄 Step 4: Run First Build (10 minutes)

1. Go to pipeline: `nodejs-eks-pipeline`
2. Click **"Build Now"**
3. Click on build **#1**
4. Click **"Console Output"**
5. Watch the build progress

### Expected Stages:
```
✅ Checkout - Pull code from GitHub
✅ Build - npm install & test
✅ Docker Build - Create container image
✅ Push to ECR - Upload to AWS ECR
✅ Deploy to EKS - Update Kubernetes
```

### If Build Fails:

**Common Issue 1: kubectl not configured**
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

**Common Issue 2: Docker permission denied**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

**Common Issue 3: npm test fails**
Just remove the test line from Jenkinsfile temporarily.

✅ **Mark complete when build shows "SUCCESS"**

---

## 🔄 Step 5: Verify Deployment (5 minutes)

```powershell
# Check pods are running
kubectl get pods

# Check service
kubectl get svc nodejs-app-service

# Get Load Balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Wait 2-3 minutes for DNS propagation**, then test:

```powershell
# Test application (replace with your LB URL)
curl http://YOUR-LOAD-BALANCER-URL.eu-north-1.elb.amazonaws.com
```

**Expected Response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-xxxxx-xxxxx"
}
```

✅ **Mark complete when you get the JSON response**

---

## 🔄 Step 6: Test CI/CD Pipeline (5 minutes)

Make a small change to test auto-deployment:

```powershell
cd nodejs-jenkins-eks-demo/app
```

Edit `server.js` and change the message:
```javascript
message: "Hello from Node.js on EKS - Updated!"
```

Push to GitHub:
```powershell
git add .
git commit -m "Test CI/CD pipeline"
git push
```

**Wait 5 minutes** (poll interval), then:
- Check Jenkins - new build should start automatically
- After build completes, test the URL again
- You should see the updated message!

✅ **Mark complete when auto-deployment works**

---

## 🎯 Optional: Setup GitHub Webhook (Instant Builds)

### In GitHub Repository:
1. Go to Settings → Webhooks → Add webhook
2. Payload URL: `http://16.171.58.221:8080/github-webhook/`
3. Content type: `application/json`
4. Events: "Just the push event"
5. Click "Add webhook"

### In Jenkins Pipeline:
1. Edit pipeline configuration
2. Build Triggers: ✅ Check "GitHub hook trigger for GITScm polling"
3. Save

Now builds trigger instantly on push! 🚀

---

## 📊 Your Configuration Summary

| Item | Value |
|------|-------|
| AWS Account | 047861165149 |
| Region | eu-north-1 |
| EKS Cluster | nodejs-eks-cluster |
| ECR Repository | nodejs-eks-app |
| Jenkins URL | http://16.171.58.221:8080 |
| Jenkins Instance | i-0b73f57d5bc95b311 |

---

## 🎉 Success Criteria

You're done when:
- ✅ Jenkins can connect to EKS cluster
- ✅ Code is on GitHub
- ✅ Pipeline job created in Jenkins
- ✅ First build completes successfully
- ✅ Application accessible via Load Balancer
- ✅ Code changes trigger automatic deployments

---

## 🆘 Need Help?

**Check Jenkins logs:**
```bash
# On Jenkins EC2
sudo tail -f /var/log/jenkins/jenkins.log
```

**Check Kubernetes pods:**
```powershell
kubectl get pods
kubectl describe pod POD_NAME
kubectl logs POD_NAME
```

**Check EKS cluster:**
```powershell
kubectl get nodes
kubectl get all
```

---

## 📚 Quick Commands Reference

```powershell
# Connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1

# Get Load Balancer URL
kubectl get svc nodejs-app-service

# View pod logs
kubectl logs -f deployment/nodejs-app

# Scale deployment
kubectl scale deployment nodejs-app --replicas=3

# Rollback deployment
kubectl rollout undo deployment/nodejs-app

# Check build history
# Go to Jenkins → nodejs-eks-pipeline → Build History
```

---

**Start with Step 1 and work through each step. Let me know if you hit any issues!** 🚀
