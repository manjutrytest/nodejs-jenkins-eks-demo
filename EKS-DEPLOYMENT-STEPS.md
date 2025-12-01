# EKS Deployment Steps - Quick Reference

## Prerequisites
- AWS CLI configured
- Git Bash or PowerShell
- AWS Account with admin access

## Step 1: Install Tools (5 minutes)

```bash
# Install eksctl
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Windows_amd64.zip"
unzip eksctl_Windows_amd64.zip -d eksctl_tmp
mkdir -p ~/bin
mv eksctl_tmp/eksctl.exe ~/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
mv kubectl.exe ~/bin/

# Add to PATH
export PATH=$PATH:~/bin
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc

# Verify
eksctl version
kubectl version --client
```

## Step 2: Create EKS Cluster (15-20 minutes)

```bash
eksctl create cluster \
  --name nodejs-eks-cluster \
  --region eu-north-1 \
  --nodegroup-name nodejs-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --managed
```

**What this creates:**
- VPC with subnets
- EKS control plane
- 2 worker nodes (t3.medium)
- All IAM roles
- kubectl configuration (automatic)

## Step 3: Verify Cluster

```bash
# Check nodes
kubectl get nodes

# Expected output:
# NAME                                           STATUS   ROLES    AGE
# ip-192-168-xx-xx.eu-north-1.compute.internal  Ready    <none>   2m
# ip-192-168-xx-xx.eu-north-1.compute.internal  Ready    <none>   2m
```

## Step 4: Deploy Application

```bash
cd nodejs-jenkins-eks-demo

# Deploy Kubernetes resources
kubectl apply -f k8s/

# Check deployment
kubectl get pods
kubectl get svc
```

## Step 5: Access Application

```bash
# Get load balancer URL
kubectl get svc nodejs-app-service

# Wait for EXTERNAL-IP (2-3 minutes)
# Copy the URL and open in browser
```

## Common Commands

### View Resources
```bash
kubectl get all                    # All resources
kubectl get pods                   # List pods
kubectl get svc                    # List services
kubectl get deployments            # List deployments
```

### View Logs
```bash
kubectl logs <POD_NAME>            # View pod logs
kubectl logs -f deployment/nodejs-app  # Follow logs
```

### Scale Application
```bash
kubectl scale deployment nodejs-app --replicas=5
```

### Update Application
```bash
kubectl apply -f k8s/              # Apply changes
kubectl rollout restart deployment/nodejs-app
```

### Debug
```bash
kubectl describe pod <POD_NAME>    # Pod details
kubectl describe svc nodejs-app-service
kubectl get events                 # Cluster events
```

## Cleanup

```bash
# Delete application
kubectl delete -f k8s/

# Delete cluster (10-15 minutes)
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1
```

## Architecture

```
┌─────────────────────────────────────────┐
│           AWS EKS Cluster               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Control Plane (Managed by AWS)  │ │
│  └───────────────────────────────────┘ │
│                  │                      │
│  ┌───────────────┴───────────────────┐ │
│  │      Worker Nodes (EC2)           │ │
│  │  ┌──────────┐    ┌──────────┐    │ │
│  │  │  Node 1  │    │  Node 2  │    │ │
│  │  │          │    │          │    │ │
│  │  │ ┌──────┐ │    │ ┌──────┐ │    │ │
│  │  │ │ Pod1 │ │    │ │ Pod2 │ │    │ │
│  │  │ └──────┘ │    │ └──────┘ │    │ │
│  │  │ ┌──────┐ │    │ ┌──────┐ │    │ │
│  │  │ │ Pod3 │ │    │ │ Pod4 │ │    │ │
│  │  │ └──────┘ │    │ └──────┘ │    │ │
│  │  └──────────┘    └──────────┘    │ │
│  └─────────────────────────────────┘ │
│                  │                      │
│  ┌───────────────▼───────────────────┐ │
│  │    Load Balancer (NLB)            │ │
│  └───────────────────────────────────┘ │
└─────────────────┬───────────────────────┘
                  │
                  ▼
              Internet
```

## Key Concepts

**EKS (Elastic Kubernetes Service)**
- Managed Kubernetes control plane
- AWS handles upgrades and availability
- Integrates with AWS services

**Pods**
- Smallest deployable unit
- Contains one or more containers
- Ephemeral (can be replaced)

**Deployment**
- Manages replica sets
- Ensures desired number of pods
- Handles rolling updates

**Service (LoadBalancer)**
- Stable endpoint for pods
- Creates AWS Load Balancer
- Routes traffic to healthy pods

**kubectl**
- Command-line tool for Kubernetes
- Manages cluster resources
- Configured automatically by eksctl

## Cost Breakdown

| Component | Cost/Month |
|-----------|------------|
| EKS Control Plane | $73 |
| Worker Nodes (2x t3.medium) | $60 |
| Network Load Balancer | $20 |
| **Total** | **~$153** |

## Troubleshooting

### Pods not starting
```bash
kubectl get pods
kubectl describe pod <POD_NAME>
kubectl logs <POD_NAME>
```

### Service has no EXTERNAL-IP
Wait 2-3 minutes for load balancer creation

### Can't access application
- Check pods are running: `kubectl get pods`
- Check service exists: `kubectl get svc`
- Verify load balancer in AWS Console

### eksctl command not found
```bash
export PATH=$PATH:~/bin
source ~/.bashrc
```

## Success Checklist

- ✅ eksctl and kubectl installed
- ✅ EKS cluster created
- ✅ Nodes are Ready
- ✅ Pods are Running
- ✅ Service has EXTERNAL-IP
- ✅ Application accessible via URL

## Next Steps

1. Add CI/CD with Jenkins
2. Implement auto-scaling (HPA)
3. Add monitoring (Prometheus/Grafana)
4. Configure Ingress Controller
5. Add persistent storage
6. Implement GitOps (ArgoCD)

## Resources

- EKS Documentation: https://docs.aws.amazon.com/eks/
- Kubernetes Docs: https://kubernetes.io/docs/
- eksctl Guide: https://eksctl.io/
- kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
