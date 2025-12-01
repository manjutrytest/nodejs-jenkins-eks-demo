# 🚀 EKS Quick Start Guide

## Prerequisites (On Your Windows Laptop)

- ✅ AWS CLI configured (you already have this)
- ✅ Git (you already have this)
- ❌ **NO Docker needed** (runs on Jenkins EC2)
- ❌ **NO kubectl needed** (runs on Jenkins EC2)
- ❌ **NO Kubernetes needed** (EKS is in AWS)

**Everything runs in AWS!** You only need AWS CLI to deploy.

## Deploy Infrastructure

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
cd nodejs-jenkins-eks-demo

# Deploy (20-25 minutes)
chmod +x scripts/*.sh
./scripts/deploy-all.sh
```

## Configure kubectl

```bash
# Configure kubectl to use EKS cluster
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Verify nodes are ready
kubectl get nodes
```

## Setup Jenkins

```bash
# Get Jenkins URL
aws cloudformation describe-stacks \
  --stack-name nodejs-eks-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsURL`].OutputValue' \
  --output text \
  --region eu-north-1

# Get initial password
JENKINS_IP=$(aws cloudformation describe-stacks \
  --stack-name nodejs-eks-jenkins \
  --query 'Stacks[0].Outputs[?OutputKey==`JenkinsPublicIP`].OutputValue' \
  --output text \
  --region eu-north-1)

ssh ec2-user@$JENKINS_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

## Build & Deploy

1. **Access Jenkins** and complete setup
2. **Install plugins**: Docker Pipeline, Kubernetes CLI
3. **Create pipeline** job pointing to this repo
4. **Build** to push image to ECR
5. **Deploy to Kubernetes**:

```bash
kubectl apply -f k8s/
```

## Access Application

```bash
# Get LoadBalancer URL
kubectl get svc nodejs-app-service

# Test
curl http://<LOAD_BALANCER_URL>/
```

## Useful Commands

```bash
# View pods
kubectl get pods

# View logs
kubectl logs -f deployment/nodejs-app

# Scale deployment
kubectl scale deployment nodejs-app --replicas=5

# Update deployment
kubectl set image deployment/nodejs-app nodejs-app=<NEW_IMAGE>

# View services
kubectl get svc
```

## Cleanup

```bash
./scripts/cleanup.sh
```

## Cost

- EKS Control Plane: ~$73/month
- Worker Nodes (2x t3.medium): ~$60/month
- Jenkins (t3.medium): ~$30/month
- **Total: ~$163/month**
