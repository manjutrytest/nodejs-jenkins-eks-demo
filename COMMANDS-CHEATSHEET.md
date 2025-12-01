# 📝 Commands Cheat Sheet

## 🎯 The 3 Essential Commands

### 1. Configure kubectl on Jenkins
```powershell
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```
Then in EC2:
```bash
sudo su - jenkins && aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1 && kubectl get nodes && exit
```

### 2. Push to GitHub
```powershell
cd nodejs-jenkins-eks-demo
git init && git add . && git commit -m "Initial commit" && git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
git push -u origin main
```

### 3. Test Application
```powershell
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

---

## 🔧 Jenkins Commands

```powershell
# Open Jenkins
start http://16.171.58.221:8080

# Connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1

# Restart Jenkins (on EC2)
sudo systemctl restart jenkins

# View Jenkins logs (on EC2)
sudo tail -f /var/log/jenkins/jenkins.log

# Check Jenkins status (on EC2)
sudo systemctl status jenkins
```

---

## ☸️ Kubernetes Commands

```powershell
# Get all resources
kubectl get all

# Get pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods -w  # watch mode

# Get services
kubectl get svc
kubectl get svc nodejs-app-service

# Get deployments
kubectl get deployment
kubectl get deployment nodejs-app

# Describe resources
kubectl describe pod POD_NAME
kubectl describe svc nodejs-app-service
kubectl describe deployment nodejs-app

# View logs
kubectl logs POD_NAME
kubectl logs -f POD_NAME  # follow
kubectl logs -f deployment/nodejs-app
kubectl logs --tail=100 POD_NAME

# Execute commands in pod
kubectl exec -it POD_NAME -- /bin/sh
kubectl exec -it POD_NAME -- node -v

# Scale deployment
kubectl scale deployment nodejs-app --replicas=3
kubectl scale deployment nodejs-app --replicas=1

# Rollout management
kubectl rollout status deployment/nodejs-app
kubectl rollout history deployment/nodejs-app
kubectl rollout undo deployment/nodejs-app
kubectl rollout restart deployment/nodejs-app

# Delete resources
kubectl delete pod POD_NAME
kubectl delete deployment nodejs-app
kubectl delete svc nodejs-app-service

# Apply manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/  # all files in directory

# Get cluster info
kubectl cluster-info
kubectl get nodes
kubectl top nodes  # requires metrics server
```

---

## 🐳 Docker Commands (on Jenkins EC2)

```bash
# List images
docker images

# List containers
docker ps
docker ps -a

# Remove images
docker rmi IMAGE_ID
docker image prune -a

# Remove containers
docker rm CONTAINER_ID
docker container prune

# View logs
docker logs CONTAINER_ID

# Login to ECR
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 047861165149.dkr.ecr.eu-north-1.amazonaws.com

# Build image
docker build -t nodejs-app:latest .

# Tag image
docker tag nodejs-app:latest 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:latest

# Push image
docker push 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:latest
```

---

## 🔐 AWS Commands

### EKS
```powershell
# Update kubeconfig
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1

# Describe cluster
aws eks describe-cluster --name nodejs-eks-cluster --region eu-north-1

# List clusters
aws eks list-clusters --region eu-north-1

# Get cluster endpoint
aws eks describe-cluster --name nodejs-eks-cluster --query "cluster.endpoint" --output text --region eu-north-1
```

### ECR
```powershell
# List repositories
aws ecr describe-repositories --region eu-north-1

# List images in repository
aws ecr list-images --repository-name nodejs-eks-app --region eu-north-1

# Describe images
aws ecr describe-images --repository-name nodejs-eks-app --region eu-north-1

# Delete image
aws ecr batch-delete-image --repository-name nodejs-eks-app --image-ids imageTag=TAG --region eu-north-1

# Get login password
aws ecr get-login-password --region eu-north-1
```

### CloudFormation
```powershell
# List stacks
aws cloudformation list-stacks --region eu-north-1

# Describe stack
aws cloudformation describe-stacks --stack-name jenkins-eks --region eu-north-1

# Get stack outputs
aws cloudformation describe-stacks --stack-name jenkins-eks --query "Stacks[0].Outputs" --region eu-north-1

# Delete stack
aws cloudformation delete-stack --stack-name STACK_NAME --region eu-north-1
```

### EC2
```powershell
# List instances
aws ec2 describe-instances --region eu-north-1

# Get instance by name
aws ec2 describe-instances --filters "Name=tag:Name,Values=Jenkins-EKS-Server" --region eu-north-1

# Start session
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
```

---

## 📦 Git Commands

```powershell
# Initialize repository
git init

# Add files
git add .
git add FILE_NAME

# Commit
git commit -m "Commit message"

# Check status
git status

# View log
git log
git log --oneline

# Create branch
git branch BRANCH_NAME
git checkout -b BRANCH_NAME

# Switch branch
git checkout BRANCH_NAME

# Merge branch
git merge BRANCH_NAME

# Add remote
git remote add origin URL

# View remotes
git remote -v

# Push
git push
git push -u origin main

# Pull
git pull

# Clone
git clone URL

# View diff
git diff
git diff FILE_NAME
```

---

## 🧪 Testing Commands

```powershell
# Test application endpoint
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com

# Test with verbose output
curl -v http://LOAD_BALANCER_URL

# Test health endpoint
curl http://LOAD_BALANCER_URL/health

# Test multiple times
for ($i=1; $i -le 10; $i++) { curl http://LOAD_BALANCER_URL; Start-Sleep -Seconds 1 }

# Check DNS resolution
nslookup a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com

# Test from within cluster
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://nodejs-app-service
```

---

## 🔍 Debugging Commands

```powershell
# Check pod status
kubectl get pods
kubectl describe pod POD_NAME

# View pod logs
kubectl logs POD_NAME
kubectl logs -f POD_NAME --tail=100

# Check events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'

# Check service endpoints
kubectl get endpoints nodejs-app-service

# Port forward to pod
kubectl port-forward POD_NAME 3000:3000

# Check node status
kubectl get nodes
kubectl describe node NODE_NAME

# Check resource usage
kubectl top pods
kubectl top nodes

# Check deployment status
kubectl rollout status deployment/nodejs-app

# View deployment history
kubectl rollout history deployment/nodejs-app
```

---

## 🚀 Quick Workflows

### Deploy New Version
```powershell
# Make changes to code
git add .
git commit -m "Update feature"
git push
# Jenkins will auto-deploy in 5 minutes
```

### Manual Deploy
```powershell
# Build and push image
docker build -t 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:v2 app/
docker push 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:v2

# Update deployment
kubectl set image deployment/nodejs-app nodejs-app=047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app:v2
kubectl rollout status deployment/nodejs-app
```

### Rollback Deployment
```powershell
kubectl rollout undo deployment/nodejs-app
kubectl rollout status deployment/nodejs-app
```

### Scale Application
```powershell
kubectl scale deployment nodejs-app --replicas=5
kubectl get pods -w
```

### View Application Logs
```powershell
kubectl logs -f deployment/nodejs-app --tail=100
```

---

## 📊 Monitoring Commands

```powershell
# Watch pods
kubectl get pods -w

# Watch all resources
kubectl get all -w

# Check pod resource usage
kubectl top pods

# Check node resource usage
kubectl top nodes

# View cluster events
kubectl get events -w

# Check service status
kubectl get svc -w
```

---

## 🧹 Cleanup Commands

```powershell
# Delete application
kubectl delete deployment nodejs-app
kubectl delete svc nodejs-app-service
kubectl delete configmap nodejs-app-config

# Delete all resources
kubectl delete all --all

# Clean Docker on Jenkins
docker system prune -a -f

# Delete EKS cluster
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1

# Delete CloudFormation stacks
aws cloudformation delete-stack --stack-name jenkins-eks --region eu-north-1
aws cloudformation delete-stack --stack-name eks-ecr --region eu-north-1
```

---

## 💡 Pro Tips

```powershell
# Create alias for kubectl
Set-Alias -Name k -Value kubectl

# Use short names
k get po  # pods
k get svc  # services
k get deploy  # deployments
k get no  # nodes

# Watch resources
k get pods -w

# Get YAML output
k get deployment nodejs-app -o yaml

# Get JSON output
k get deployment nodejs-app -o json

# Use labels
k get pods -l app=nodejs-app
k logs -l app=nodejs-app

# Multiple commands
k get pods; k get svc; k get deploy
```

---

## 🎯 Your Specific URLs

```
Jenkins:        http://16.171.58.221:8080
Application:    http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
ECR:            047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app
Jenkins EC2:    i-0b73f57d5bc95b311
EKS Cluster:    nodejs-eks-cluster
Region:         eu-north-1
```

---

**Bookmark this page for quick reference!** 📌
