# Complete EKS Deployment Guide

## What You Need on Your Laptop

**Only 2 things:**
1. ✅ AWS CLI (you have this)
2. ✅ Git (you have this)

**You DON'T need:**
- ❌ Docker
- ❌ kubectl
- ❌ Kubernetes
- ❌ Jenkins

**Everything runs in AWS!**

## Step-by-Step Deployment

### Step 1: Deploy Infrastructure (20-25 minutes)

```powershell
# From your Windows laptop
cd C:\Users\mangowra
git clone <YOUR_REPO_URL>
cd nodejs-jenkins-eks-demo

# Deploy everything to AWS
aws cloudformation deploy --template-file infra/01-vpc.yml --stack-name nodejs-eks-vpc --region eu-north-1

aws cloudformation deploy --template-file infra/04-ecr.yml --stack-name nodejs-eks-ecr --region eu-north-1

aws cloudformation deploy --template-file infra/02-eks-cluster.yml --stack-name nodejs-eks-cluster --capabilities CAPABILITY_NAMED_IAM --region eu-north-1
# This takes 10-15 minutes

aws cloudformation deploy --template-file infra/03-eks-nodegroup.yml --stack-name nodejs-eks-nodegroup --capabilities CAPABILITY_NAMED_IAM --region eu-north-1
# This takes 5-10 minutes

aws cloudformation deploy --template-file infra/05-jenkins.yml --stack-name nodejs-eks-jenkins --capabilities CAPABILITY_NAMED_IAM --region eu-north-1
```

### Step 2: Get Jenkins URL

```powershell
aws cloudformation describe-stacks --stack-name nodejs-eks-jenkins --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" --output text --region eu-north-1
```

### Step 3: Access Jenkins

1. Open the Jenkins URL in your browser
2. Get the initial password:

```powershell
# Get Jenkins IP
$jenkinsIp = aws cloudformation describe-stacks --stack-name nodejs-eks-jenkins --query "Stacks[0].Outputs[?OutputKey=='JenkinsPublicIP'].OutputValue" --output text --region eu-north-1

# SSH to get password (if you have SSH key)
ssh ec2-user@$jenkinsIp "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

**Or use AWS Systems Manager Session Manager** (no SSH key needed):
- Go to EC2 Console
- Select Jenkins instance
- Click "Connect" → "Session Manager"
- Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

### Step 4: Setup Jenkins

1. **Install Plugins:**
   - Suggested plugins
   - Docker Pipeline
   - Kubernetes CLI Plugin
   - Amazon ECR Plugin

2. **Create Admin User**

3. **Create Pipeline Job:**
   - New Item → Pipeline
   - Name: `nodejs-eks-pipeline`
   - Pipeline script from SCM
   - Git URL: Your GitHub repo
   - Script Path: `jenkins/Jenkinsfile`

### Step 5: Configure kubectl on Jenkins

Jenkins EC2 already has kubectl installed. Configure it:

**SSH to Jenkins** (or use Session Manager):
```bash
# Configure kubectl
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify
kubectl get nodes
```

### Step 6: Build Initial Image

1. In Jenkins, click "Build Now"
2. This will:
   - Build Docker image
   - Push to ECR
   - Deploy to EKS

### Step 7: Get Application URL

**From your Windows laptop:**
```powershell
# SSH to Jenkins and run
ssh ec2-user@$jenkinsIp "kubectl get svc nodejs-app-service"
```

**Or use AWS Console:**
- Go to EC2 → Load Balancers
- Find the NLB created by Kubernetes
- Copy the DNS name

### Step 8: Test Application

```powershell
curl http://<LOAD_BALANCER_DNS>/
```

## Verification Steps

### Check EKS Cluster

```powershell
aws eks describe-cluster --name nodejs-eks-cluster --region eu-north-1
```

### Check Nodes

```powershell
aws eks list-nodegroups --cluster-name nodejs-eks-cluster --region eu-north-1
```

### Check ECR Images

```powershell
aws ecr describe-images --repository-name nodejs-eks-app --region eu-north-1
```

## Using kubectl from Your Laptop (Optional)

If you want to use kubectl from your Windows laptop:

1. **Install kubectl:**
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

2. **Configure kubectl:**
```powershell
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

3. **Test:**
```powershell
kubectl get nodes
kubectl get pods
kubectl get svc
```

## Common Operations

### View Pods
```powershell
# From Jenkins EC2
ssh ec2-user@$jenkinsIp "kubectl get pods"
```

### View Logs
```powershell
ssh ec2-user@$jenkinsIp "kubectl logs -f deployment/nodejs-app"
```

### Scale Application
```powershell
ssh ec2-user@$jenkinsIp "kubectl scale deployment nodejs-app --replicas=5"
```

### Update Application
Just push code to GitHub - Jenkins will auto-deploy!

## Troubleshooting

### Jenkins Can't Access EKS

**Fix:** Update Jenkins IAM role to include EKS permissions (already configured in CloudFormation)

### Pods Not Starting

**Check from Jenkins EC2:**
```bash
kubectl get pods
kubectl describe pod <POD_NAME>
kubectl logs <POD_NAME>
```

### Can't Access Application

**Check service:**
```bash
kubectl get svc nodejs-app-service
kubectl describe svc nodejs-app-service
```

### Image Pull Errors

**Verify ECR:**
```powershell
aws ecr describe-images --repository-name nodejs-eks-app --region eu-north-1
```

## Cleanup

**From your Windows laptop:**
```powershell
# Delete Kubernetes resources first
ssh ec2-user@$jenkinsIp "kubectl delete -f k8s/"

# Delete CloudFormation stacks
aws cloudformation delete-stack --stack-name nodejs-eks-jenkins --region eu-north-1
aws cloudformation delete-stack --stack-name nodejs-eks-nodegroup --region eu-north-1
aws cloudformation wait stack-delete-complete --stack-name nodejs-eks-nodegroup --region eu-north-1

aws cloudformation delete-stack --stack-name nodejs-eks-cluster --region eu-north-1
aws cloudformation wait stack-delete-complete --stack-name nodejs-eks-cluster --region eu-north-1

aws cloudformation delete-stack --stack-name nodejs-eks-ecr --region eu-north-1
aws cloudformation delete-stack --stack-name nodejs-eks-vpc --region eu-north-1
```

## Cost Summary

- **EKS Control Plane**: $73/month (always running)
- **Worker Nodes** (2x t3.medium): $60/month
- **Jenkins** (t3.medium): $30/month
- **Network Load Balancer**: $20/month
- **ECR + Data**: $6/month
- **Total**: ~$189/month

**To reduce costs:**
- Delete when not in use
- Use smaller instance types
- Reduce number of nodes

## Architecture Summary

```
Your Laptop (AWS CLI only)
    │
    ▼
AWS CloudFormation
    │
    ├─ Creates VPC
    ├─ Creates EKS Cluster
    ├─ Creates Worker Nodes
    ├─ Creates Jenkins EC2 (with Docker + kubectl)
    └─ Creates ECR
    
Jenkins EC2 (in AWS)
    │
    ├─ Has Docker installed
    ├─ Has kubectl installed
    ├─ Builds images
    ├─ Pushes to ECR
    └─ Deploys to EKS

EKS Cluster (in AWS)
    │
    ├─ Pulls images from ECR
    ├─ Runs pods
    └─ Exposes via Load Balancer
```

**You only interact with AWS from your laptop using AWS CLI!**

## Next Steps

1. ✅ Deploy infrastructure
2. ✅ Setup Jenkins
3. ✅ Build and deploy
4. ✅ Access application
5. 🎯 Make code changes and push to GitHub
6. 🎯 Watch Jenkins auto-deploy
7. 🎯 See changes live!

Everything is automated after initial setup! 🚀
