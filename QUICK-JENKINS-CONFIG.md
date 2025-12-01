# Quick Jenkins Configuration for EKS

## Step 1: Configure kubectl on Jenkins EC2

You need to run this **ONCE** on the Jenkins EC2 instance:

### Option A: Via AWS Systems Manager (Recommended)

```powershell
# From your local machine, connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

Then run these commands in the EC2 terminal:

```bash
# Switch to jenkins user
sudo su - jenkins

# Configure kubectl
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify it works
kubectl get nodes
kubectl get pods -A

# Exit jenkins user
exit
```

### Option B: Via EC2 Instance Connect

1. Go to EC2 Console → Instances
2. Select instance `i-0b73f57d5bc95b311`
3. Click "Connect" → "Session Manager" → "Connect"
4. Run the same commands as Option A

---

## Step 2: Push Code to GitHub

From your local machine in the project directory:

```powershell
cd nodejs-jenkins-eks-demo

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - EKS CI/CD pipeline"

# Create GitHub repo first, then add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**OR if you want to use an existing repo:**

```powershell
# Just push to your existing repo
git add .
git commit -m "Add EKS CI/CD configuration"
git push
```

---

## Step 3: Create Jenkins Pipeline Job

### 3.1 In Jenkins Dashboard:
- Click "New Item"
- Name: `nodejs-eks-pipeline`
- Type: "Pipeline"
- Click "OK"

### 3.2 Configure the Pipeline:

**General:**
- Description: `CI/CD Pipeline for Node.js on EKS`
- ✅ Check "GitHub project"
- Project URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

**Build Triggers:**
- ✅ Check "Poll SCM"
- Schedule: `H/5 * * * *`

**Pipeline:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- Branch: `*/main`
- Script Path: `jenkins/Jenkinsfile`

### 3.3 Save
Click "Save"

---

## Step 4: Run First Build

### 4.1 Trigger Build
- Go to pipeline: `nodejs-eks-pipeline`
- Click "Build Now"

### 4.2 Monitor Progress
- Click on build #1
- Click "Console Output"
- Watch the stages execute

**Expected Stages:**
1. ✅ Checkout
2. ✅ Build (npm install & test)
3. ✅ Docker Build
4. ✅ Push to ECR
5. ✅ Deploy to EKS

---

## Step 5: Verify Deployment

```powershell
# Check pods
kubectl get pods

# Check service
kubectl get svc nodejs-app-service

# Get Load Balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Wait 2-3 minutes for DNS propagation, then test:

```powershell
# Test the application
curl http://LOAD_BALANCER_URL
```

---

## Your Configuration Details

- **AWS Account ID:** 047861165149
- **Region:** eu-north-1
- **EKS Cluster:** nodejs-eks-cluster
- **Jenkins Instance:** i-0b73f57d5bc95b311
- **Jenkins URL:** http://16.171.58.221:8080
- **ECR Repository:** 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app

---

## Troubleshooting

### If kubectl doesn't work in Jenkins:
```bash
# On Jenkins EC2, as jenkins user
sudo su - jenkins
which kubectl
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

### If Docker permission denied:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### If ECR push fails:
```bash
# Verify ECR repository exists
aws ecr describe-repositories --repository-names nodejs-eks-app --region eu-north-1
```

---

## Next Steps After First Build

1. ✅ Verify app is running: `kubectl get pods`
2. ✅ Get Load Balancer URL: `kubectl get svc`
3. ✅ Test application endpoint
4. ✅ Make a code change and push to trigger auto-build
5. ✅ Setup GitHub webhook for instant builds

**🎉 Your EKS CI/CD pipeline is ready!**
