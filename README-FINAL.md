# Node.js EKS CI/CD Pipeline - Complete Setup

## 🎯 Project Overview

A complete CI/CD pipeline for deploying Node.js applications to Amazon EKS using Jenkins, Docker, and ECR.

**Architecture:** GitHub → Jenkins → Docker → ECR → EKS → Load Balancer

---

## ✅ What's Already Deployed

Your infrastructure is **100% ready**:

- ✅ **EKS Cluster:** 2 nodes running (nodejs-eks-cluster)
- ✅ **Jenkins Server:** Configured and running
- ✅ **ECR Repository:** Ready for Docker images
- ✅ **Load Balancer:** Deployed and accessible
- ✅ **IAM Roles:** All permissions configured
- ✅ **VPC & Networking:** Complete setup

---

## 🚀 Complete Setup in 3 Steps (15 minutes)

### Quick Start

1. **Configure kubectl on Jenkins** (5 min)
   ```powershell
   aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1
   ```
   Then in EC2:
   ```bash
   sudo su - jenkins
   aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
   kubectl get nodes
   exit
   ```

2. **Push code to GitHub** (5 min)
   ```powershell
   cd nodejs-jenkins-eks-demo
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/nodejs-jenkins-eks-demo.git
   git push -u origin main
   ```

3. **Create Jenkins pipeline** (5 min)
   - Open http://16.171.58.221:8080
   - New Item → Pipeline → Name: `nodejs-eks-pipeline`
   - Configure with your GitHub repo
   - Build Now!

**See ACTION-PLAN.md for detailed instructions**

---

## 📁 Project Structure

```
nodejs-jenkins-eks-demo/
├── app/                          # Node.js application
│   ├── server.js                 # Express server
│   ├── package.json              # Dependencies
│   └── Dockerfile                # Container image
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # App deployment
│   ├── service.yaml              # Load balancer service
│   └── configmap.yaml            # Configuration
├── jenkins/
│   └── Jenkinsfile               # CI/CD pipeline
├── infra/                        # CloudFormation templates
│   ├── 01-vpc.yml                # VPC setup
│   ├── 02-eks-cluster.yml        # EKS cluster
│   ├── 03-eks-nodegroup.yml      # Worker nodes
│   ├── 04-ecr.yml                # Container registry
│   └── 05-jenkins-standalone.yml # Jenkins server
├── scripts/                      # Helper scripts
│   ├── deploy-all.ps1            # Deploy infrastructure
│   ├── push-to-github.ps1        # Git helper
│   └── configure-jenkins-kubectl.sh
└── docs/                         # Documentation
    ├── ACTION-PLAN.md            # ⭐ Start here
    ├── VISUAL-GUIDE.md           # Step-by-step with visuals
    ├── JENKINS-SETUP-GUIDE.md    # Complete Jenkins guide
    └── NEXT-STEPS-CHECKLIST.md   # Detailed checklist
```

---

## 🔧 Configuration Details

| Resource | Value |
|----------|-------|
| **Jenkins URL** | http://16.171.58.221:8080 |
| **Jenkins EC2** | i-0b73f57d5bc95b311 |
| **EKS Cluster** | nodejs-eks-cluster |
| **ECR Repository** | 047861165149.dkr.ecr.eu-north-1.amazonaws.com/nodejs-eks-app |
| **Load Balancer** | a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com |
| **AWS Account** | 047861165149 |
| **Region** | eu-north-1 |

---

## 📚 Documentation Guide

**Choose your path:**

### 🏃 Quick Start (15 minutes)
→ **ACTION-PLAN.md** - 3 simple steps to get running

### 📸 Visual Learner
→ **VISUAL-GUIDE.md** - Step-by-step with diagrams

### 📋 Detailed Setup
→ **JENKINS-SETUP-GUIDE.md** - Complete configuration guide

### ✅ Checklist Approach
→ **NEXT-STEPS-CHECKLIST.md** - Detailed checklist with troubleshooting

### 🎯 Just the Commands
→ **QUICK-JENKINS-CONFIG.md** - Command reference only

---

## 🔄 CI/CD Pipeline Flow

```
1. Developer pushes code to GitHub
   ↓
2. Jenkins detects change (polling or webhook)
   ↓
3. Jenkins checks out code
   ↓
4. Runs npm install & test
   ↓
5. Builds Docker image
   ↓
6. Pushes image to ECR
   ↓
7. Updates Kubernetes deployment
   ↓
8. Verifies rollout success
   ↓
9. Application updated! ✅
```

---

## 🧪 Testing Your Pipeline

After setup, test the application:

```powershell
# Test the endpoint
curl http://a59daf9ed75434adaafa1e2b58e61f63-4e25befa51c23aee3.elb.eu-north-1.amazonaws.com
```

**Expected response:**
```json
{
  "message": "Hello from Node.js on EKS!",
  "timestamp": "2024-12-01T10:30:00.000Z",
  "hostname": "nodejs-app-xxxxx"
}
```

Test auto-deployment:
```powershell
# Make a change
echo "// Updated" >> app/server.js
git add .
git commit -m "Test auto-deploy"
git push

# Wait 5 minutes, Jenkins will auto-build and deploy!
```

---

## 🛠️ Useful Commands

### Kubernetes
```powershell
# View pods
kubectl get pods

# View services
kubectl get svc

# View logs
kubectl logs -f deployment/nodejs-app

# Scale deployment
kubectl scale deployment nodejs-app --replicas=3

# Rollback
kubectl rollout undo deployment/nodejs-app
```

### Jenkins
```powershell
# Connect to Jenkins EC2
aws ssm start-session --target i-0b73f57d5bc95b311 --region eu-north-1

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log
```

### AWS
```powershell
# View EKS cluster
aws eks describe-cluster --name nodejs-eks-cluster --region eu-north-1

# View ECR images
aws ecr list-images --repository-name nodejs-eks-app --region eu-north-1

# Update kubeconfig
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

---

## 🆘 Troubleshooting

### Build fails with kubectl error
```bash
# On Jenkins EC2
sudo su - jenkins
aws eks update-kubeconfig --name nodejs-eks-cluster --region eu-north-1
```

### Docker permission denied
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Application not responding
- Wait 2-3 minutes for DNS propagation
- Check pods: `kubectl get pods`
- Check logs: `kubectl logs -l app=nodejs-app`

### Can't push to GitHub
- Verify repository exists
- Check git credentials
- Ensure remote is configured: `git remote -v`

---

## 🎯 Success Criteria

Your pipeline is working when:
- ✅ Jenkins can connect to EKS cluster
- ✅ Code changes trigger automatic builds
- ✅ Docker images pushed to ECR
- ✅ Kubernetes deployments update automatically
- ✅ Application accessible via Load Balancer
- ✅ Zero-downtime rolling updates

---

## 🔐 Security Features

- ✅ Private subnets for EKS nodes
- ✅ IAM roles with least privilege
- ✅ Security groups with minimal access
- ✅ ECR image scanning enabled
- ✅ Jenkins in public subnet with security group
- ✅ EKS API endpoint accessible

---

## 📈 Scaling

```powershell
# Scale application pods
kubectl scale deployment nodejs-app --replicas=5

# Scale EKS nodes (edit node group in AWS Console)
# Or use eksctl:
eksctl scale nodegroup --cluster=nodejs-eks-cluster --name=nodejs-nodegroup --nodes=3 --region=eu-north-1
```

---

## 🧹 Cleanup

To delete all resources:

```powershell
# Delete EKS cluster
eksctl delete cluster --name nodejs-eks-cluster --region eu-north-1

# Delete CloudFormation stacks
aws cloudformation delete-stack --stack-name jenkins-eks --region eu-north-1
aws cloudformation delete-stack --stack-name eks-ecr --region eu-north-1
aws cloudformation delete-stack --stack-name eks-nodegroup --region eu-north-1
aws cloudformation delete-stack --stack-name eks-cluster --region eu-north-1
aws cloudformation delete-stack --stack-name eks-vpc --region eu-north-1
```

---

## 🎓 What You'll Learn

- ✅ EKS cluster management
- ✅ Kubernetes deployments and services
- ✅ Jenkins pipeline as code
- ✅ Docker containerization
- ✅ AWS ECR integration
- ✅ Infrastructure as Code with CloudFormation
- ✅ CI/CD best practices
- ✅ Zero-downtime deployments

---

## 🚀 Next Steps

1. **Complete the 3-step setup** (see ACTION-PLAN.md)
2. **Test the pipeline** with a code change
3. **Setup GitHub webhook** for instant builds
4. **Add monitoring** with CloudWatch
5. **Implement blue-green deployments**
6. **Add automated testing** to pipeline

---

## 📞 Support

**Documentation:**
- ACTION-PLAN.md - Quick start guide
- VISUAL-GUIDE.md - Visual step-by-step
- JENKINS-SETUP-GUIDE.md - Complete setup
- NEXT-STEPS-CHECKLIST.md - Detailed checklist

**Quick Commands:**
- Connect to Jenkins: `aws ssm start-session --target i-0b73f57d5bc95b311`
- Test app: `curl http://[LOAD-BALANCER-URL]`
- View pods: `kubectl get pods`

---

## 🎉 You're Ready!

Everything is deployed and ready. Just follow the **ACTION-PLAN.md** to complete the setup in 15 minutes.

**Your EKS CI/CD pipeline awaits!** 🚀
