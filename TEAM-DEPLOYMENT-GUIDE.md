# Team Deployment Guide

Complete guide for your team to clone and deploy this EKS CI/CD pipeline.

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] AWS Account with admin access
- [ ] AWS CLI installed and configured
- [ ] kubectl installed
- [ ] eksctl installed
- [ ] Git installed
- [ ] PowerShell (Windows) or Bash (Linux/Mac)

## 🚀 Step-by-Step Deployment

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
cd nodejs-jenkins-eks-demo
```

### Step 2: Configure AWS Credentials

```powershell
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-north-1 (or your preferred region)
# Default output format: json
```

### Step 3: Update Configuration Files

#### 3.1 Update Jenkinsfile

Edit `jenkins/Jenkinsfile` and update:

```groovy
environment {
    AWS_REGION = 'YOUR_REGION'              # Change to your region
    AWS_ACCOUNT_ID = 'YOUR_ACCOUNT_ID'      # Change to your AWS account ID
    ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/nodejs-eks-app"
    IMAGE_TAG = "${BUILD_NUMBER}"
    EKS_CLUSTER = 'nodejs-eks-cluster'
}
```

#### 3.2 Update Deployment Manifest

Edit `k8s/deployment.yaml` and update the image:

```yaml
image: YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/nodejs-eks-app:latest
```

### Step 4: Deploy Infrastructure

#### Option A: Automated Deployment (Recommended)

```powershell
# Run the deployment script
.\scripts\deploy-all.ps1
```

This will deploy:
1. VPC and networking
2. EKS cluster
3. EKS node group
4. ECR repository
5. Jenkins server

**Time:** ~25-30 minutes

#### Option B: Manual Deployment

```powershell
# 1. Deploy VPC
aws cloudformation create-stack --stack-name eks-vpc --template-body file://infra/01-vpc.yml --region YOUR_REGION

# 2. Deploy EKS Cluster (or use eksctl - recommended)
eksctl create cluster --name nodejs-eks-cluster --region YOUR_REGION --nodegroup-name nodejs-nodegroup --node-type t3.medium --nodes 2

# 3. Deploy ECR
aws cloudformation create-stack --stack-name eks-ecr --template-body file://infra/04-ecr.yml --region YOUR_REGION

# 4. Deploy Jenkins
aws cloudformation create-stack --stack-name jenkins-eks --template-body file://infra/05-jenkins-standalone.yml --capabilities CAPABILITY_IAM --region YOUR_REGION
```

### Step 5: Configure kubectl

```powershell
# Update kubeconfig
aws eks update-kubeconfig --name nodejs-eks-cluster --region YOUR_REGION

# Verify connection
kubectl get nodes
```

**Expected output:**
```
NAME                                           STATUS   ROLES    AGE
ip-192-168-xx-xx.YOUR_REGION.compute.internal  Ready    <none>   5m
ip-192-168-xx-xx.YOUR_REGION.compute.internal  Ready    <none>   5m
```

### Step 6: Get Jenkins URL and Password

```powershell
# Get Jenkins URL
aws cloudformation describe-stacks --stack-name jenkins-eks --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" --output text --region YOUR_REGION

# Get Jenkins instance ID
aws cloudformation describe-stacks --stack-name jenkins-eks --query "Stacks[0].Outputs[?OutputKey=='SSMCommand'].OutputValue" --output text --region YOUR_REGION
```

### Step 7: Configure Jenkins

#### 7.1 Access Jenkins

1. Open the Jenkins URL in your browser
2. Connect to EC2 via Systems Manager to get the initial password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

#### 7.2 Install Plugins

1. Select "Install suggested plugins"
2. Wait for installation to complete
3. Create admin user

#### 7.3 Install Additional Plugins

Go to Manage Jenkins → Manage Plugins → Available:
- Docker Pipeline
- Amazon ECR
- Kubernetes CLI
- Pipeline: AWS Steps

Click "Install without restart"

### Step 8: Configure kubectl on Jenkins EC2

```powershell
# Connect to Jenkins EC2
aws ssm start-session --target JENKINS_INSTANCE_ID --region YOUR_REGION
```

In the EC2 terminal:
```bash
# Switch to jenkins user
sudo su - jenkins

# Configure kubectl
aws eks update-kubeconfig --name nodejs-eks-cluster --region YOUR_REGION

# Verify
kubectl get nodes

# Exit
exit
```

### Step 9: Add Jenkins IAM Role to EKS

```powershell
# Get Jenkins role ARN
$JENKINS_ROLE = "arn:aws:iam::YOUR_ACCOUNT_ID:role/jenkins-eks-role"

# Add to EKS
eksctl create iamidentitymapping --cluster nodejs-eks-cluster --region YOUR_REGION --arn $JENKINS_ROLE --username jenkins --group system:masters
```

### Step 10: Push Code to GitHub

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit"

# Add your GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git

# Push
git branch -M main
git push -u origin main
```

### Step 11: Setup GitHub Webhook

1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: `http://JENKINS_IP:8080/github-webhook/`
4. Content type: `application/json`
5. Events: "Just the push event"
6. Click "Add webhook"

### Step 12: Create Jenkins Pipeline

1. Open Jenkins
2. Click "New Item"
3. Name: `nodejs-eks-pipeline`
4. Type: "Pipeline"
5. Click "OK"

**Configure:**
- General → ✅ GitHub project → `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo/`
- Build Triggers → ✅ GitHub hook trigger + ✅ Poll SCM → Schedule: `H/5 * * * *`
- Pipeline:
  - Definition: `Pipeline script from SCM`
  - SCM: `Git`
  - Repository URL: `https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git`
  - Branch: `*/main`
  - Script Path: `jenkins/Jenkinsfile`

6. Click "Save"
7. Click "Build Now"

### Step 13: Verify Deployment

```powershell
# Check pods
kubectl get pods

# Check service
kubectl get svc nodejs-app-service

# Get Load Balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test application (wait 2-3 minutes for DNS)
curl http://LOAD_BALANCER_URL
```

**Expected response:**
```json
{
  "message": "Node.js App on EKS - Jenkins CI/CD by manju",
  "version": "1.0.0",
  "timestamp": "...",
  "environment": "production",
  "pod": "nodejs-app-xxxxx"
}
```

## ✅ Verification Checklist

- [ ] EKS cluster running with 2 nodes
- [ ] Jenkins accessible and configured
- [ ] kubectl can connect to EKS
- [ ] ECR repository created
- [ ] GitHub webhook configured
- [ ] Jenkins pipeline created
- [ ] First build successful
- [ ] Application accessible via Load Balancer
- [ ] Auto-deployment working (test with code change)

## 🔄 Making Changes

After setup, your team can:

1. **Make code changes** in `app/server.js`
2. **Commit and push** to GitHub
3. **Jenkins automatically builds and deploys** (5 minutes)
4. **Verify** the changes are live

## 🆘 Common Issues

### Issue: kubectl can't connect to EKS
**Solution:**
```powershell
aws eks update-kubeconfig --name nodejs-eks-cluster --region YOUR_REGION
kubectl get nodes
```

### Issue: Jenkins build fails with kubectl error
**Solution:**
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region YOUR_REGION
kubectl get nodes
exit
```

### Issue: Jenkins IAM role not authorized
**Solution:**
```powershell
eksctl create iamidentitymapping --cluster nodejs-eks-cluster --region YOUR_REGION --arn arn:aws:iam::YOUR_ACCOUNT_ID:role/jenkins-eks-role --username jenkins --group system:masters
```

### Issue: Application not accessible
**Solution:**
- Wait 2-3 minutes for DNS propagation
- Check pods: `kubectl get pods`
- Check service: `kubectl get svc`
- Check Load Balancer in AWS Console

### Issue: Docker permission denied in Jenkins
**Solution:**
```bash
# On Jenkins EC2
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## 📊 Monitoring and Maintenance

```powershell
# View pod logs
kubectl logs -f deployment/nodejs-app

# Scale deployment
kubectl scale deployment nodejs-app --replicas=5

# Rollback deployment
kubectl rollout undo deployment/nodejs-app

# Restart deployment
kubectl rollout restart deployment/nodejs-app

# View Jenkins logs
# Connect to Jenkins EC2 and run:
sudo tail -f /var/log/jenkins/jenkins.log
```

## 🧹 Cleanup

When you're done, delete all resources:

```powershell
# Delete EKS cluster
eksctl delete cluster --name nodejs-eks-cluster --region YOUR_REGION

# Delete CloudFormation stacks
aws cloudformation delete-stack --stack-name jenkins-eks --region YOUR_REGION
aws cloudformation delete-stack --stack-name eks-ecr --region YOUR_REGION
aws cloudformation delete-stack --stack-name eks-vpc --region YOUR_REGION
```

## 💡 Tips for Your Team

1. **Use a shared AWS account** for the team environment
2. **Document your AWS account ID and region** in a team wiki
3. **Use IAM roles** instead of access keys when possible
4. **Set up CloudWatch alarms** for production monitoring
5. **Implement proper branching strategy** (dev, staging, prod)
6. **Add automated tests** to the pipeline
7. **Use Kubernetes namespaces** for environment isolation

## 📞 Support

If your team encounters issues:
1. Check the troubleshooting section above
2. Review Jenkins console output
3. Check kubectl logs: `kubectl logs POD_NAME`
4. Verify AWS resources in the console
5. See COMMANDS-CHEATSHEET.md for quick reference

---

**Your team is now ready to deploy and manage the EKS CI/CD pipeline!** 🚀
