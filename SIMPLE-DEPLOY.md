# Simple EKS Deployment (Using eksctl)

CloudFormation for EKS can be complex. Let's use **eksctl** - AWS's official EKS CLI tool. It's much simpler!

## Option 1: Use eksctl (Recommended - Easiest)

### Step 1: Install eksctl on Your Laptop

**Windows (using Chocolatey):**
```powershell
choco install eksctl
```

**Or download directly:**
- Go to: https://github.com/weaveworks/eksctl/releases
- Download eksctl_Windows_amd64.zip
- Extract and add to PATH

### Step 2: Create EKS Cluster (One Command!)

```powershell
eksctl create cluster `
  --name nodejs-eks-cluster `
  --region eu-north-1 `
  --nodegroup-name nodejs-nodes `
  --node-type t3.medium `
  --nodes 2 `
  --nodes-min 2 `
  --nodes-max 4 `
  --managed
```

**This takes 15-20 minutes and creates:**
- VPC
- EKS Cluster
- Node Group
- All IAM roles
- kubectl configuration (automatic!)

### Step 3: Verify Cluster

```powershell
# eksctl automatically configures kubectl
kubectl get nodes
```

### Step 4: Deploy ECR

```powershell
aws cloudformation deploy `
  --template-file infra/04-ecr.yml `
  --stack-name nodejs-eks-ecr `
  --region eu-north-1
```

### Step 5: Deploy Jenkins

```powershell
aws cloudformation deploy `
  --template-file infra/05-jenkins-standalone.yml `
  --stack-name nodejs-eks-jenkins `
  --capabilities CAPABILITY_NAMED_IAM `
  --region eu-north-1
```

### Step 6: Deploy Application

```powershell
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Get service URL
kubectl get svc nodejs-app-service
```

## Option 2: Use AWS Console (No CLI Tools Needed)

### Step 1: Create EKS Cluster via Console

1. Go to: https://console.aws.amazon.com/eks/
2. Click "Add cluster" → "Create"
3. Configure:
   - Name: `nodejs-eks-cluster`
   - Kubernetes version: 1.28
   - Cluster service role: Create new role
   - VPC: Create new VPC
4. Click "Create"
5. Wait 10-15 minutes

### Step 2: Add Node Group

1. In cluster, go to "Compute" tab
2. Click "Add node group"
3. Configure:
   - Name: `nodejs-nodes`
   - Node IAM role: Create new role
   - Instance type: t3.medium
   - Desired size: 2
4. Click "Create"
5. Wait 5-10 minutes

### Step 3: Configure kubectl

```powershell
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
kubectl get nodes
```

### Step 4: Deploy Application

```powershell
kubectl apply -f k8s/
kubectl get svc nodejs-app-service
```

## Option 3: Fix CloudFormation Issues

The CloudFormation failure is usually due to:

### Issue 1: Missing Service-Linked Role

**Fix:**
```powershell
aws iam create-service-linked-role --aws-service-name eks.amazonaws.com
```

Then retry CloudFormation deployment.

### Issue 2: Insufficient Permissions

**Fix:** Ensure your IAM user/role has these permissions:
- `AmazonEKSClusterPolicy`
- `AmazonEKSServicePolicy`
- `AmazonEKSVPCResourceController`

### Issue 3: VPC/Subnet Issues

**Fix:** Use the simplified VPC template I'll create below.

## Recommended Approach

**For testing/learning:** Use **eksctl** (Option 1)
- Simplest
- One command
- Handles everything
- Easy to delete

**For production:** Use CloudFormation (after fixing issues)
- Infrastructure as Code
- Version controlled
- Repeatable

## Quick Comparison

| Method | Time | Complexity | Best For |
|--------|------|------------|----------|
| eksctl | 15 min | Easy | Testing/Learning |
| Console | 20 min | Easy | One-time setup |
| CloudFormation | 25 min | Complex | Production/IaC |

## After Cluster is Ready

Regardless of method, once cluster is ready:

1. **Deploy app:**
   ```powershell
   kubectl apply -f k8s/
   ```

2. **Get URL:**
   ```powershell
   kubectl get svc nodejs-app-service
   ```

3. **Test:**
   ```powershell
   curl http://<LOAD_BALANCER_URL>/
   ```

## Cleanup

### If using eksctl:
```powershell
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1
```

### If using Console:
1. Delete node group first
2. Then delete cluster

### If using CloudFormation:
```powershell
aws cloudformation delete-stack --stack-name nodejs-eks-nodegroup --region eu-north-1
aws cloudformation delete-stack --stack-name nodejs-eks-cluster --region eu-north-1
aws cloudformation delete-stack --stack-name nodejs-eks-vpc --region eu-north-1
```

## My Recommendation

**Use eksctl for now!** It's the official AWS tool and much simpler:

```powershell
# Install eksctl
choco install eksctl

# Create cluster (one command!)
eksctl create cluster --name nodejs-eks-cluster --region eu-north-1 --nodes 2

# Deploy app
kubectl apply -f k8s/

# Done!
```

Once you're comfortable with EKS, you can export the configuration and convert to CloudFormation for production use.
