# Jenkins Setup Guide for EKS CI/CD

## Step 1: Initial Jenkins Setup (You're Here!)

### 1.1 Unlock Jenkins
- Paste the password you copied from EC2
- Click "Continue"

### 1.2 Install Plugins
- Select **"Install suggested plugins"**
- Wait for installation to complete (2-3 minutes)

### 1.3 Create Admin User
- Username: `admin` (or your choice)
- Password: (choose a strong password)
- Full name: Your name
- Email: your-email@example.com
- Click "Save and Continue"

### 1.4 Jenkins URL
- Keep the default URL (should be your EC2 public IP)
- Click "Save and Finish"
- Click "Start using Jenkins"

---

## Step 2: Install Required Plugins

### 2.1 Navigate to Plugin Manager
- Click "Manage Jenkins" (left sidebar)
- Click "Manage Plugins"
- Click "Available" tab

### 2.2 Search and Install These Plugins:
Search for each and check the box:
- **Docker Pipeline**
- **Amazon ECR**
- **Kubernetes CLI**
- **Pipeline: AWS Steps**
- **Git**

### 2.3 Install
- Click "Install without restart"
- Wait for all plugins to install
- Check "Restart Jenkins when installation is complete"

---

## Step 3: Configure AWS Credentials in Jenkins

### 3.1 Add AWS Credentials
- Go to "Manage Jenkins" → "Manage Credentials"
- Click "(global)" domain
- Click "Add Credentials"

**Configure:**
- Kind: `AWS Credentials`
- ID: `aws-credentials`
- Description: `AWS Credentials for ECR and EKS`
- Access Key ID: (Get from your AWS account)
- Secret Access Key: (Get from your AWS account)
- Click "OK"

> **Note:** The Jenkins EC2 instance should already have an IAM role attached. You can skip this step if the role has proper permissions.

---

## Step 4: Configure kubectl on Jenkins EC2

### 4.1 SSH into Jenkins EC2 Instance
From your local machine:
```powershell
# Get the instance ID
aws ec2 describe-instances --filters "Name=tag:Name,Values=Jenkins-EKS-Server" --query "Reservations[0].Instances[0].InstanceId" --output text --region eu-north-1
```

### 4.2 Connect via Session Manager
- Go to EC2 Console
- Select the Jenkins instance
- Click "Connect" → "Session Manager" → "Connect"

### 4.3 Configure kubectl for Jenkins User
Run these commands in the EC2 terminal:

```bash
# Switch to jenkins user
sudo su - jenkins

# Configure kubectl to connect to EKS
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify connection
kubectl get nodes
kubectl get pods -A

# Exit jenkins user
exit
```

**Expected Output:**
```
NAME                                           STATUS   ROLES    AGE
ip-192-168-xx-xx.eu-north-1.compute.internal   Ready    <none>   1h
```

---

## Step 5: Create GitHub Repository (If Not Done)

### 5.1 Create New GitHub Repository
- Go to GitHub.com
- Click "New repository"
- Name: `nodejs-jenkins-eks-demo`
- Public or Private (your choice)
- Don't initialize with README
- Click "Create repository"

### 5.2 Push Your Code to GitHub
From your local machine (in the project directory):

```powershell
cd nodejs-jenkins-eks-demo

# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - EKS CI/CD pipeline"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Step 6: Create Jenkins Pipeline Job

### 6.1 Create New Pipeline
- From Jenkins dashboard, click "New Item"
- Enter name: `nodejs-eks-pipeline`
- Select "Pipeline"
- Click "OK"

### 6.2 Configure Pipeline

**General Section:**
- Description: `CI/CD Pipeline for Node.js app on EKS`
- Check "GitHub project"
- Project url: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`

**Build Triggers:**
- Check "GitHub hook trigger for GITScm polling"
- Check "Poll SCM" (as backup)
- Schedule: `H/5 * * * *` (every 5 minutes)

**Pipeline Section:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
- Credentials: (Add if private repo)
- Branch: `*/main`
- Script Path: `jenkins/Jenkinsfile`

### 6.3 Save
- Click "Save"

---

## Step 7: Update Jenkinsfile with Your Details

The Jenkinsfile needs your specific AWS details. Update these values:

```groovy
environment {
    AWS_REGION = 'eu-north-1'
    ECR_REGISTRY = 'YOUR_AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com'
    ECR_REPOSITORY = 'nodejs-app'
    EKS_CLUSTER_NAME = 'nodejs-eks-cluster'
    IMAGE_TAG = "${BUILD_NUMBER}"
}
```

**To get your AWS Account ID:**
```powershell
aws sts get-caller-identity --query Account --output text
```

---

## Step 8: Run Your First Build

### 8.1 Trigger Build
- Go to your pipeline: `nodejs-eks-pipeline`
- Click "Build Now"

### 8.2 Monitor Build
- Click on the build number (e.g., #1)
- Click "Console Output"
- Watch the build progress

**Expected Stages:**
1. ✅ Checkout - Pull code from GitHub
2. ✅ Build Docker Image - Create container image
3. ✅ Push to ECR - Upload to AWS ECR
4. ✅ Deploy to EKS - Update Kubernetes deployment
5. ✅ Verify Deployment - Check pod status

### 8.3 Build Success
If successful, you'll see:
```
Deployment successful!
Application URL: http://LOAD_BALANCER_DNS
Finished: SUCCESS
```

---

## Step 9: Verify Deployment

### 9.1 Check Kubernetes Resources
```powershell
# Get pods
kubectl get pods

# Get service
kubectl get svc nodejs-app-service

# Get deployment
kubectl get deployment nodejs-app
```

### 9.2 Test Application
```powershell
# Get Load Balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test the app (wait 2-3 minutes for DNS propagation)
curl http://LOAD_BALANCER_DNS
```

**Expected Response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-xxxxx-xxxxx"
}
```

---

## Step 10: Setup GitHub Webhook (Optional but Recommended)

### 10.1 Get Jenkins Webhook URL
```
http://YOUR_JENKINS_IP:8080/github-webhook/
```

### 10.2 Configure in GitHub
- Go to your GitHub repository
- Settings → Webhooks → Add webhook
- Payload URL: `http://YOUR_JENKINS_IP:8080/github-webhook/`
- Content type: `application/json`
- Events: "Just the push event"
- Click "Add webhook"

### 10.3 Test Webhook
- Make a small change to your code
- Commit and push to GitHub
- Jenkins should automatically trigger a build!

---

## Troubleshooting

### Issue: kubectl command not found in Jenkins
**Solution:**
```bash
sudo su - jenkins
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Issue: Permission denied for Docker
**Solution:**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue: ECR authentication failed
**Solution:**
```bash
# Verify IAM role has ECR permissions
aws ecr get-login-password --region eu-north-1
```

### Issue: Cannot connect to EKS cluster
**Solution:**
```bash
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
```

---

## Next Steps

✅ Jenkins is configured and running
✅ First build completed successfully
✅ Application deployed to EKS

**Now you can:**
1. Make code changes and push to GitHub
2. Watch Jenkins automatically build and deploy
3. Access your app via the Load Balancer URL
4. Monitor logs and metrics in AWS Console

---

## Quick Reference Commands

```powershell
# Get Jenkins URL
aws cloudformation describe-stacks --stack-name jenkins-eks --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" --output text --region eu-north-1

# Get Load Balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# View Jenkins logs
kubectl logs -f deployment/nodejs-app

# Scale deployment
kubectl scale deployment nodejs-app --replicas=3

# Rollback deployment
kubectl rollout undo deployment/nodejs-app
```

---

**🎉 Congratulations! Your EKS CI/CD pipeline is now fully operational!**
