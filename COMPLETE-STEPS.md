# Complete EKS Deployment Steps

## ✅ Step 1: Create EKS Cluster (15-20 minutes)

```bash
eksctl create cluster \
  --name nodejs-eks-cluster \
  --region eu-north-1 \
  --nodegroup-name nodejs-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --managed
```

**Wait for completion.** You'll see:
```
[✔]  EKS cluster "nodejs-eks-cluster" in "eu-north-1" region is ready
```

## ✅ Step 2: Verify Cluster

```bash
# Check nodes
kubectl get nodes

# Should show 2 nodes in Ready state
# NAME                                           STATUS   ROLES    AGE
# ip-192-168-xx-xx.eu-north-1.compute.internal  Ready    <none>   2m
# ip-192-168-xx-xx.eu-north-1.compute.internal  Ready    <none>   2m
```

## ✅ Step 3: Create ECR Repository

```bash
cd nodejs-jenkins-eks-demo

aws ecr create-repository \
  --repository-name nodejs-eks-app \
  --region eu-north-1
```

## ✅ Step 4: Build and Push Initial Docker Image

```bash
# Login to ECR
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 047861165149.dkr.ecr.eu-north-1.amazonaws.com

# Build image
cd app
docker build -t 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:latest .

# Push to ECR
docker push 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:latest
```

**If you don't have Docker locally, skip this step.** We'll use Jenkins to build later.

## ✅ Step 5: Deploy Application to Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Or all at once
kubectl apply -f k8s/
```

## ✅ Step 6: Wait for Load Balancer

```bash
# Watch service creation (takes 2-3 minutes)
kubectl get svc nodejs-app-service --watch

# Wait until EXTERNAL-IP shows (not <pending>)
# Press Ctrl+C when you see the hostname
```

## ✅ Step 7: Get Application URL

```bash
# Get load balancer URL
kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Or
kubectl get svc nodejs-app-service
```

## ✅ Step 8: Test Application

```bash
# Get URL
LB_URL=$(kubectl get svc nodejs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test
curl http://$LB_URL/
curl http://$LB_URL/health
```

## ✅ Step 9: Deploy Jenkins (Optional - for CI/CD)

```bash
# Deploy Jenkins EC2
aws cloudformation deploy \
  --template-file infra/05-jenkins-standalone.yml \
  --stack-name jenkins-eks \
  --capabilities CAPABILITY_NAMED_IAM \
  --region eu-north-1

# Get Jenkins URL
aws cloudformation describe-stacks \
  --stack-name jenkins-eks \
  --query "Stacks[0].Outputs[?OutputKey=='JenkinsURL'].OutputValue" \
  --output text \
  --region eu-north-1
```

## ✅ Step 10: Configure Jenkins (if deployed)

1. **Access Jenkins URL**
2. **Get password:**
   - Go to EC2 Console
   - Select Jenkins instance
   - Connect → Session Manager
   - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

3. **Install plugins:**
   - Suggested plugins
   - Docker Pipeline
   - Kubernetes CLI

4. **Configure kubectl on Jenkins:**
   ```bash
   aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
   kubectl get nodes
   ```

## Useful Commands

### View Resources
```bash
# All resources
kubectl get all

# Pods
kubectl get pods
kubectl get pods -o wide

# Services
kubectl get svc

# Deployments
kubectl get deployments
```

### View Logs
```bash
# Get pod name
kubectl get pods

# View logs
kubectl logs <POD_NAME>

# Follow logs
kubectl logs -f <POD_NAME>

# Logs from deployment
kubectl logs -f deployment/nodejs-app
```

### Scale Application
```bash
# Scale to 5 replicas
kubectl scale deployment nodejs-app --replicas=5

# Verify
kubectl get pods
```

### Update Application
```bash
# After pushing new image to ECR
kubectl rollout restart deployment/nodejs-app

# Check rollout status
kubectl rollout status deployment/nodejs-app
```

### Debug
```bash
# Describe pod
kubectl describe pod <POD_NAME>

# Describe service
kubectl describe svc nodejs-app-service

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it <POD_NAME> -- /bin/sh
```

## Cleanup

### Delete Application
```bash
kubectl delete -f k8s/
```

### Delete Jenkins
```bash
aws cloudformation delete-stack --stack-name jenkins-eks --region eu-north-1
```

### Delete EKS Cluster
```bash
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1
```

This takes 10-15 minutes and removes everything.

## Troubleshooting

### Pods not starting
```bash
kubectl get pods
kubectl describe pod <POD_NAME>
kubectl logs <POD_NAME>
```

### Service has no EXTERNAL-IP
```bash
# Check service
kubectl describe svc nodejs-app-service

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system
```

### Can't access application
```bash
# Check if pods are running
kubectl get pods

# Check if service exists
kubectl get svc

# Check load balancer in AWS Console
# EC2 → Load Balancers
```

## Cost Summary

- **EKS Control Plane**: $73/month
- **Worker Nodes** (2x t3.medium): $60/month
- **Network Load Balancer**: $20/month
- **Jenkins** (if deployed): $30/month
- **Total**: ~$153-183/month

**Remember to delete when done testing!**

## Success Checklist

- ✅ EKS cluster created
- ✅ Nodes are Ready
- ✅ Application deployed
- ✅ Load balancer created
- ✅ Application accessible via URL
- ✅ Can view logs
- ✅ Can scale pods

## Next Steps

1. ✅ Cluster is running
2. ✅ App is deployed
3. 🎯 Setup CI/CD with Jenkins
4. 🎯 Connect GitHub
5. 🎯 Auto-deploy on push
6. 🎯 Add monitoring
7. 🎯 Add auto-scaling

Congratulations! You have a working Kubernetes cluster on AWS! 🎉
