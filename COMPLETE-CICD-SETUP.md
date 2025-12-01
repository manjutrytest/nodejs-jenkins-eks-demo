# Complete CI/CD Setup for EKS

## Current Status
✅ EKS cluster running
✅ Kubernetes working
⚠️ Using test image (not your custom Node.js app)

## What We Need to Add

1. **GitHub Repository** - Store your code
2. **Jenkins** - Build automation
3. **Docker** - Build images (on Jenkins, not your laptop)
4. **ECR** - Store Docker images
5. **CI/CD Pipeline** - Auto-deploy on git push

## Step-by-Step Setup

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `nodejs-jenkins-eks-demo`
3. Don't initialize with anything
4. Create repository

### Step 2: Push Code to GitHub

```bash
cd nodejs-jenkins-eks-demo

git init
git add .
git commit -m "Initial commit: EKS deployment"
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git branch -M main
git push -u origin main
```

### Step 3: Deploy Jenkins EC2

```powershell
aws cloudformation deploy `
  --template-file infra/05-jenkins-standalone.yml `
  --stack-name jenkins-eks `
  --capabilities CAPABILITY_NAMED_IAM `
  --region eu-north-1
```

**This takes 5-10 minutes and creates:**
- Jenkins EC2 instance
- Docker pre-installed
- kubectl pre-installed
- AWS CLI pre-installed

### Step 4: Get Jenkins URL

```powershell
aws cloudformation describe-stacks `
  --stack-name jenkins-eks `
  --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" `
  --output text `
  --region eu-north-1
```

### Step 5: Access Jenkins

1. Open Jenkins URL in browser
2. Get initial password:
   - Go to EC2 Console
   - Select Jenkins instance
   - Click "Connect" → "Session Manager"
   - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

### Step 6: Setup Jenkins

1. **Install Plugins:**
   - Suggested plugins
   - Docker Pipeline
   - Kubernetes CLI Plugin
   - Amazon ECR Plugin
   - GitHub Integration

2. **Create Admin User**

3. **Configure kubectl on Jenkins:**
   
   In Session Manager on Jenkins EC2:
   ```bash
   # Switch to jenkins user
   sudo su - jenkins
   
   # Configure kubectl
   aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
   
   # Verify
   kubectl get nodes
   ```

### Step 7: Create Jenkins Pipeline

1. **New Item** → **Pipeline**
2. **Name**: `nodejs-eks-pipeline`
3. **Configure:**
   - GitHub project: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo`
   - Build Triggers: ✅ GitHub hook trigger for GITScm polling
   - Pipeline:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
     - Credentials: Add your GitHub token
     - Branch: `*/main`
     - Script Path: `jenkins/Jenkinsfile`

### Step 8: Setup GitHub Webhook

1. Go to: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/settings/hooks`
2. Add webhook:
   - Payload URL: `http://<JENKINS_IP>:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Just the push event
   - Active: ✅

### Step 9: Build Initial Image

1. In Jenkins, click **"Build Now"**
2. Jenkins will:
   - Clone your repo
   - Run npm install & test
   - Build Docker image
   - Push to ECR
   - Deploy to EKS

### Step 10: Update Deployment to Use Your Image

After Jenkins builds and pushes your image:

```bash
# Update deployment to use your custom image
kubectl set image deployment/nodejs-app \
  nodejs-app=047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:latest

# Check rollout
kubectl rollout status deployment/nodejs-app

# Verify pods
kubectl get pods
```

### Step 11: Test Your Application

```bash
# Get URL
kubectl get svc nodejs-app-service

# Test
curl http://<LOAD_BALANCER_URL>/
curl http://<LOAD_BALANCER_URL>/health
```

## Complete CI/CD Flow

```
Developer → GitHub → Webhook → Jenkins → Docker Build → 
ECR Push → kubectl apply → EKS Deploy → Live!
```

## Test the Pipeline

```bash
# Make a change
echo "// Updated" >> app/server.js

# Commit and push
git add app/server.js
git commit -m "Test CI/CD"
git push origin main

# Jenkins automatically:
# 1. Detects push
# 2. Builds image
# 3. Pushes to ECR
# 4. Deploys to EKS
# 5. Updates pods (rolling update)
```

## Verify Everything Works

```bash
# Check Jenkins build
# Go to Jenkins UI → View build logs

# Check pods updated
kubectl get pods

# Check new image
kubectl describe pod <POD_NAME> | grep Image

# Test application
curl http://<LOAD_BALANCER_URL>/
```

## Architecture with CI/CD

```
┌──────────┐
│ GitHub   │
└────┬─────┘
     │ Webhook
     ▼
┌──────────┐
│ Jenkins  │
│   EC2    │
│ (Docker) │
└────┬─────┘
     │ Build & Push
     ▼
┌──────────┐
│   ECR    │
└────┬─────┘
     │ Pull Image
     ▼
┌──────────────────────┐
│    EKS Cluster       │
│  ┌────────────────┐  │
│  │ Deployment     │  │
│  │ 3 Pods         │  │
│  └────────────────┘  │
│  ┌────────────────┐  │
│  │ Service (NLB)  │  │
│  └────────────────┘  │
└──────────────────────┘
     │
     ▼
  Internet
```

## What You'll Have

✅ **Full CI/CD Pipeline**
- Code push triggers automatic deployment
- Docker images built automatically
- Zero-downtime rolling updates
- Complete automation

✅ **Production-Ready**
- High availability (3 replicas)
- Auto-healing
- Load balanced
- Scalable

✅ **Industry Standard**
- Kubernetes (used by Google, Netflix, Spotify)
- Jenkins (most popular CI/CD)
- Docker (standard containerization)
- AWS (leading cloud provider)

## Cost with Jenkins

- EKS Control Plane: $73/month
- Worker Nodes (2x t3.medium): $60/month
- Jenkins (t3.medium): $30/month
- Network Load Balancer: $20/month
- **Total: ~$183/month**

## Next Steps

1. ✅ Deploy Jenkins (Step 3 above)
2. ✅ Setup GitHub webhook
3. ✅ Build custom image
4. ✅ Test CI/CD pipeline
5. 🎯 Add monitoring
6. 🎯 Add auto-scaling
7. 🎯 Add staging environment

Ready to deploy Jenkins and complete the CI/CD setup? 🚀
