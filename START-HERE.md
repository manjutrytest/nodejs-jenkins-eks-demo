# 🚀 Start Here - Simplest Way to Deploy EKS

## What Happened?

CloudFormation for EKS can fail due to IAM permissions or service-linked roles. Don't worry - there's a simpler way!

## Easiest Method: Use eksctl

**eksctl** is AWS's official tool for EKS. It's much simpler than CloudFormation.

### Step 1: Install eksctl (One Time)

```powershell
# Using Chocolatey
choco install eksctl

# Or download from: https://github.com/weaveworks/eksctl/releases
```

### Step 2: Create EKS Cluster (One Command!)

```powershell
eksctl create cluster `
  --name nodejs-eks-cluster `
  --region eu-north-1 `
  --nodegroup-name nodejs-nodes `
  --node-type t3.medium `
  --nodes 2 `
  --managed
```

**This takes 15-20 minutes and creates everything:**
- ✅ VPC
- ✅ EKS Cluster
- ✅ Worker Nodes
- ✅ All IAM roles
- ✅ kubectl configuration (automatic!)

### Step 3: Verify

```powershell
# Check nodes (kubectl is auto-configured!)
kubectl get nodes

# Should show 2 nodes in Ready state
```

### Step 4: Create ECR Repository

```powershell
cd nodejs-jenkins-eks-demo

aws ecr create-repository `
  --repository-name nodejs-eks-app `
  --region eu-north-1
```

### Step 5: Deploy Jenkins

```powershell
aws cloudformation deploy `
  --template-file infra/05-jenkins-standalone.yml `
  --stack-name jenkins-eks `
  --capabilities CAPABILITY_NAMED_IAM `
  --region eu-north-1
```

### Step 6: Get Jenkins URL

```powershell
aws cloudformation describe-stacks `
  --stack-name jenkins-eks `
  --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" `
  --output text `
  --region eu-north-1
```

### Step 7: Setup Jenkins

1. Open Jenkins URL
2. Get password via AWS Systems Manager:
   - Go to EC2 Console
   - Select Jenkins instance
   - Click "Connect" → "Session Manager"
   - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

3. Install plugins:
   - Suggested plugins
   - Docker Pipeline
   - Kubernetes CLI

4. Configure kubectl on Jenkins:
   ```bash
   aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
   kubectl get nodes
   ```

### Step 8: Deploy Application

```powershell
# Deploy to Kubernetes
kubectl apply -f k8s/

# Get service URL
kubectl get svc nodejs-app-service

# Wait for EXTERNAL-IP (takes 2-3 minutes)
```

### Step 9: Test Application

```powershell
# Get the load balancer URL
$LB_URL = kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test
curl http://$LB_URL/
```

## Done! 🎉

Your EKS cluster is running with:
- ✅ Kubernetes cluster
- ✅ 2 worker nodes
- ✅ Application deployed
- ✅ Load balancer created
- ✅ Jenkins ready for CI/CD

## Useful Commands

```powershell
# View pods
kubectl get pods

# View logs
kubectl logs -f deployment/nodejs-app

# Scale application
kubectl scale deployment nodejs-app --replicas=5

# View all resources
kubectl get all

# Describe service
kubectl describe svc nodejs-app-service
```

## Cleanup

```powershell
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete Jenkins
aws cloudformation delete-stack --stack-name jenkins-eks --region eu-north-1

# Delete EKS cluster
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1
```

## Why eksctl is Better for Learning

| Feature | CloudFormation | eksctl |
|---------|----------------|--------|
| Commands | 5+ separate | 1 command |
| Time | 25 minutes | 15 minutes |
| Complexity | High | Low |
| Errors | Common | Rare |
| IAM Setup | Manual | Automatic |
| kubectl Config | Manual | Automatic |

## Cost

- EKS Control Plane: $73/month
- Worker Nodes (2x t3.medium): $60/month
- Jenkins (t3.medium): $30/month
- Load Balancer: $20/month
- **Total: ~$183/month**

**Remember to delete when done testing!**

## Next Steps

1. ✅ Cluster is running
2. ✅ App is deployed
3. 🎯 Setup Jenkins pipeline
4. 🎯 Connect GitHub
5. 🎯 Auto-deploy on push

Check **DEPLOYMENT-GUIDE.md** for Jenkins CI/CD setup!
